#! /bin/bash
echo "running script for creating multiple tomcat instances under the home directory"
#TomcatInstance=$1 #eg tomcat1
user=$1 #eg adi
startupPort=$2 #eg 8081 instead of 8080
shutdownPort=$3 #eg 8006 instead of 8005
connectorPort=$4 #eg 8010 instead of 8009

echo "tomcat installation script. Installing instance TomcatInstance$startupPort"
export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-i386
mkdir /home/$user/tomcat/TomcatInstance$startupPort
cd /home/$user/tomcat/apache-tomcat-8.0.24/
cp -R * /home/$user/tomcat/TomcatInstance$startupPort
echo "cding into instance TomcatInstance$startupPort conf directory"
cd /home/$user/tomcat/TomcatInstance$startupPort/conf
sed -i 's|<Connector port=\"8080\"|<Connector port=\"'$startupPort'\"|g' /home/$user/tomcat/TomcatInstance$startupPort/conf/server.xml
sed -i 's|<Server port=\"8005\"|<Server port=\"'$shutdownPort'\"|g' /home/$user/tomcat/TomcatInstance$startupPort/conf/server.xml 
sed -i 's|<Connector port=\"8009\"|<Connector port=\"'$connectorPort'\"|g' /home/$user/tomcat/TomcatInstance$startupPort/conf/server.xml 
cd /home/$user/tomcat/TomcatInstance$startupPort/bin/
export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-i386
echo "executing the startup script for instance TomcatInstance$startupPort"
./startup.sh

