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

# Sample Shell script to show the right setup 
# of environment variables needed to run the create-release.sh script,
# dependent to folders of the PC where this script is run.

export TEMP_DIR=/tmp
export OPT=/opt

# export ANT_HOME=$OPT/apache-ant-1.10.12
export ANT_HOME=$OPT/apache-ant-1.10.14
# export JAVA_HOME=$OPT/jdk1.8.0_131
export JAVA_HOME=$OPT/jdk-11
# export MAVEN_HOME=$OPT/apache-maven-3.6.3
export MAVEN_HOME=$OPT/apache-maven-3.9.5

export JAVALIB_DIR=$OPT/javalib

export JUNIT_LIB=$JAVALIB_DIR/junit-4.13.2.jar:$JAVALIB_DIR/hamcrest-core-1.3.jar
export MAVEN_ANT_TASKS_LIB=$JAVALIB_DIR/maven-ant-tasks-2.1.3.jar
export RAT_LIB=$JAVALIB_DIR/apache-rat-0.13.jar

export GPG_KEY_EMAIL=smartini@apache.org


# Setup CLASSPATH
export CLASSPATH=.
export CLASSPATH=$CLASSPATH:$JUNIT_LIB
export CLASSPATH=$CLASSPATH:$MAVEN_ANT_TASKS_LIB
export CLASSPATH=$CLASSPATH:$RAT_LIB

# export CLASSPATH=$CLASSPATH:$JAVA_HOME/lib/tools.jar
export CLASSPATH=$CLASSPATH:$JAVA_HOME/jre/lib/javaws.jar
export CLASSPATH=$CLASSPATH:$JAVA_HOME/jre/lib/plugin.jar


# Setup PATH
export PATH=$JAVA_HOME/bin:$ANT_HOME/bin:$MAVEN_HOME/bin:$PATH


# Show current settings
printf "Show current settings, CLASSPATH:\n%s \n" $CLASSPATH
printf "Show current settings, PATH:\n%s \n" $PATH

printf "Show current settings, GPG_KEY_EMAIL:\n%s \n" $GPG_KEY_EMAIL


# Verify that Java (from a JDK) is in PATH
java -version

# Verify that Ant is in PATH
ant -version

# Verify that Maven is in PATH
mvn -version


