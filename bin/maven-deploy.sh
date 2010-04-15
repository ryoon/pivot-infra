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

VERSION=$1
if [ "$VERSION" = "" ]; then
    echo maven-deploy.sh: Must specify version number
    exit
fi

BUNDLE_ROOT=maven/bundle

sign_file() {
    local NAME=$1
    gpg --passphrase $PASSPHRASE --armor --detach-sig --quiet --yes $NAME &> /dev/null
    openssl sha1 $NAME | sed 's/.*(\(.*\))= \(.*\)$/\2/' > $NAME.sha1
}

sign_pom_bundle() {
    local NAME=$1
    sign_file $BUNDLE_ROOT/$NAME/pom.xml
    cp $BUNDLE_ROOT/$NAME/pom.xml.asc $BUNDLE_ROOT/$NAME/$NAME-$VERSION.pom.asc
    rm $BUNDLE_ROOT/$NAME/pom.xml.asc    
    cp $BUNDLE_ROOT/$NAME/pom.xml.sha1 $BUNDLE_ROOT/$NAME/$NAME-$VERSION.pom.sha1
    rm $BUNDLE_ROOT/$NAME/pom.xml.sha1
}

sign_jar_bundle() {
    local NAME=$1
    sign_pom_bundle $NAME
    sign_file $BUNDLE_ROOT/$NAME/$NAME-$VERSION.jar
}

create_bundle() {
    local NAME=$1
    jar -cvf maven/$NAME-$VERSION-bundle.jar -C $BUNDLE_ROOT/$NAME/ . &> /dev/null
}

create_project_bundle() {
    local NAME=$1    
    mkdir $BUNDLE_ROOT/pivot-$NAME
    cp $NAME/pom.xml $BUNDLE_ROOT/pivot-$NAME/
    cp lib/pivot-$NAME-$VERSION.jar $BUNDLE_ROOT/pivot-$NAME/
    sign_jar_bundle pivot-$NAME
    create_bundle pivot-$NAME
}


# Get the GPG passphrase
printf "Enter GPG passphrase: "
read -s PASSPHRASE
echo

ant clean package

rm -Rf $BUNDLE_ROOT
mkdir -p $BUNDLE_ROOT

# Generate root bundle
mkdir $BUNDLE_ROOT/pivot
cp pom.xml $BUNDLE_ROOT/pivot/
sign_pom_bundle pivot
create_bundle pivot

# Generate project bundles
create_project_bundle core
create_project_bundle web
create_project_bundle web-server
create_project_bundle wtk
create_project_bundle wtk-terra
create_project_bundle charts
