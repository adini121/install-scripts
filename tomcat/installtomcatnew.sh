#! /bin/bash

# Description
# Author: Adi
# ChangeLog: 
# Date: 11.08.15

echo "running script for creating multiple tomcat instances under the home directory"
usage(){
        echo "Usage: $0 <OPTIONS>"
        echo "Required options:"
        echo "  -u <UID>                user name"
        echo "  -s <startupPort>        Tomcat startup port"
        echo "  -e <shutdownPort>       Tomcat shutdown port"
        echo "  -c <connectorPort>      Tomcat connector port"
        exit 1
}

export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-i386

tomcatInstanceCreation(){
echo "tomcat instance creation script. Installing instance TomcatInstance$startupPort"
if [ ! -d /home/$user/tomcat/TomcatInstance$startupPort ]; then
	mkdir /home/$user/tomcat/TomcatInstance$startupPort
else 
	echo "Tomcat instance TomcatInstance$startupPort already exists"
fi
        cp -R /home/$user/tomcat/apache-tomcat-7.0.63/* /home/$user/tomcat/TomcatInstance$startupPort
}


changingTomcatConf() {
sed -i 's|<Connector port=\"8080\"|<Connector port=\"'$startupPort'\"|g' /home/$user/tomcat/TomcatInstance$startupPort/conf/server.xml
sed -i 's|<Server port=\"8005\"|<Server port=\"'$shutdownPort'\"|g' /home/$user/tomcat/TomcatInstance$startupPort/conf/server.xml
sed -i 's|<Connector port=\"8009\"|<Connector port=\"'$connectorPort'\"|g' /home/$user/tomcat/TomcatInstance$startupPort/conf/server.xml
/home/$user/tomcat/TomcatInstance$startupPort/bin/startup.sh
}


while getopts ":u:s:e:c:" i; do
        case "${i}" in
        u) user=${OPTARG}
        ;;
        s) startupPort=${OPTARG}
        ;;
        e) shutdownPort=${OPTARG}
        ;;
        c) connectorPort=${OPTARG}
        esac
done

shift $((OPTIND - 1))

if [[ $user == "" || $startupPort == "" || $shutdownPort == "" || $connectorPort == ""  ]]; then
        usage
fi


tomcatInstanceCreation

changingTomcatConf
