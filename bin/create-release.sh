#!/bin/bash
###
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file except in
# compliance with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
###

version=$1
if [ "$version" = "" ]; then
    echo $0: Must specify version number
    exit
fi

bundle_root=maven/bundle

sign_file() {
    local name=$1
    gpg --passphrase $passphrase --armor --detach-sig --quiet --yes $name &> /dev/null
    openssl sha1 $name | sed 's/.*(\(.*\))= \(.*\)$/\2/' > $name.sha1
}

sign_pom_bundle() {
    local name=$1
    sign_file $bundle_root/$name/pom.xml
    cp $bundle_root/$name/pom.xml.asc $bundle_root/$name/$name-$version.pom.asc
    rm $bundle_root/$name/pom.xml.asc    
    cp $bundle_root/$name/pom.xml.sha1 $bundle_root/$name/$name-$version.pom.sha1
    rm $bundle_root/$name/pom.xml.sha1
}

sign_jar_bundle() {
    local name=$1
    sign_pom_bundle $name
    sign_file $bundle_root/$name/$name-$version.jar
    sign_file $bundle_root/$name/$name-$version-sources.jar
}

create_bundle() {
    local name=$1
    jar -cvf maven/$name-$version-bundle.jar -C $bundle_root/$name/ . &> /dev/null
}

create_project_bundle() {
    local name=$1    
    mkdir $bundle_root/pivot-$name
    cp $name/pom.xml $bundle_root/pivot-$name/
    cp lib/pivot-$name-$version.jar $bundle_root/pivot-$name/
    cp lib/pivot-$name-$version-sources.jar $bundle_root/pivot-$name/
    sign_jar_bundle pivot-$name

    create_bundle pivot-$name
}

create_release() {
    ## TODO Check existence of JAVA_HOME

    ## TODO Check existence of RAT_LIB

    ## TODO Check that we're in the right folder

    ## TODO Check for conflicting release.tar.gz
    rm -f release.tar.gz

    ## Location where we'll store the artifacts
    tmp="/tmp/$(basename $0).$$.tmp"

    ## TODO Check for existing tmp dir

    ## TODO test that GPG keys are set up

    ## Get the GPG passphrase
    printf "Enter GPG passphrase: "
    read -s passphrase
    echo

    ## Create the source distribution
    printf "%-*s" 50 "Building source distribution..."
    ant clean dist &> /dev/null
    if [ $? -ne 0 ]; then
        echo "error"
        echo "Build failed"
        echo
        exit 1
    else
        echo "done"
    fi

    ## Switch to the dist folder
    pushd dist &> /dev/null

    ## Get the source release name
    src_release=`find . -name apache-pivot\* -type d | xargs basename`

    ## Ascii-armor the release artifacts
    printf "%-*s" 50 "Signing source artifacts..."
    gpg --batch --passphrase $passphrase --armor --output $src_release.zip.asc \
        --detach-sig $src_release.zip &> /dev/null
    gpg --batch --passphrase $passphrase --armor --output $src_release.tar.gz.asc \
        --detach-sig $src_release.tar.gz &> /dev/null
    if [ $? -ne 0 ]; then
        echo "error"
        echo "GPG signing failed"
        echo
        exit 1
    else
        echo "done"
    fi

    ## Copy the source artifacts to our tmp dir
    mkdir $tmp
    cp $src_release.* $tmp

    ## Run the RAT reports
    printf "%-*s" 50 "Generating source RAT reports..."
    pushd $src_release &> /dev/null
    $JAVA_HOME/bin/java -jar $RAT_LIB . > $tmp/$src_release.rat.txt
    $JAVA_HOME/bin/java -jar $RAT_LIB -x . > $tmp/$src_release.rat.xml
    echo "done"

    ## Return to the base dir
    popd &> /dev/null
    popd &> /dev/null

    ## Create the binary distribution
    printf "%-*s" 50 "Building binary distribution..."
    ant clean install &> /dev/null
    if [ $? -ne 0 ]; then
        echo "error"
        echo "Build failed"
        echo
        exit 1
    else
        echo "done"
    fi

    ## Switch to the install folder
    pushd install &> /dev/null

    ## Get the binary release name
    bin_release=`find . -name apache-pivot\* -type d | xargs basename`

    ## Ascii-armor the release artifacts
    printf "%-*s" 50 "Signing binary artifacts..."
    gpg --batch --passphrase $passphrase --armor --output $bin_release.zip.asc \
        --detach-sig $bin_release.zip &> /dev/null
    gpg --batch --passphrase $passphrase --armor --output $bin_release.tar.gz.asc \
        --detach-sig $bin_release.tar.gz &> /dev/null
    if [ $? -ne 0 ]; then
        echo "error"
        echo "GPG signing failed"
        echo
        exit 1
    else
        echo "done"
    fi

    ## Copy the binary artifacts to our tmp dir
    cp $bin_release.* $tmp

    ## Run the RAT reports
    printf "%-*s" 50 "Generating binary RAT reports..."
    pushd $bin_release &> /dev/null
    $JAVA_HOME/bin/java -jar $RAT_LIB . > $tmp/$bin_release.rat.txt
    $JAVA_HOME/bin/java -jar $RAT_LIB -x . > $tmp/$bin_release.rat.xml
    echo "done"

    ## Return to the base dir
    popd &> /dev/null
    popd &> /dev/null
    
    ## Generate the Maven bundles
    printf "%-*s" 50 "Generating Maven bundles..."
    ant package-sources &> /dev/null

    ## Clean up any previous Maven artifacts    
    rm -Rf $bundle_root
    mkdir -p $bundle_root
    
    # Generate the root Maven bundle
    mkdir $bundle_root/pivot
    cp pom.xml $bundle_root/pivot/
    sign_pom_bundle pivot
    create_bundle pivot
    
    # Generate the Maven project bundles
    create_project_bundle core
    create_project_bundle web
    create_project_bundle web-server
    create_project_bundle wtk
    create_project_bundle wtk-terra
    create_project_bundle charts
    echo "done"

    ## Bundle up the release artifacts
    printf "%-*s" 50 "Packaging release..."
    basedir=$PWD
    pushd $tmp &> /dev/null
    tar -cf $basedir/release.tar *
    gzip $basedir/release.tar
    popd &> /dev/null
    echo "done"

    ## Remove the tmp folder
    rm -rf $tmp

    echo
    echo "'release.tar.gz' created!"
    echo
}

create_release $*
