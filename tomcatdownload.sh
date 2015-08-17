#!/bin/bash

# Description
# Author: Aditya
# ChangeLog: modified to download tomcat 7 instead of 8 
# Date: 14.08.15

echo "running script for downloading tomcat v8.0.24 under the home directory"
usage(){
        echo "Usage: $0 <OPTIONS>"
        echo "Required options:"
        echo " -u <UID> user name"
        exit 1
}


export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-i386

tomcatDownload(){
cd  /home/$user/
wget http://mirrors.ae-online.de/apache/tomcat/tomcat-7/v7.0.63/bin/apache-tomcat-7.0.63.tar.gz
mkdir /home/$user/tomcat
tar xvfz apache-tomcat-7.0.63.tar.gz -C /home/$user/tomcat
echo "extracted tomcat to directory : /home/$user/tomcat/ "
}

while getopts ":u:" i; do
        case "${i}" in
        u) user=${OPTARG}
        esac
done

shift $((OPTIND - 1))

if [[ $user == "" ]]; then
        usage
fi

tomcatDownload
