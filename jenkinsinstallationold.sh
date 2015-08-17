#! /bin/bash

user=$1 #eg adi
JenkinsVersion=$2 #eg 1.624
startupPort=$3 #eg 8081
cd
if [ ! -d JenkinsWarFiles ]; then
  mkdir JenkinsWarFiles
fi
cd JenkinsWarFiles
export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-i386
wget https://updates.jenkins-ci.org/download/war/$JenkinsVersion/jenkins.war -O jenkins"$JenkinsVersion".war
cp jenkins"$JenkinsVersion".war /home/$user/TomcatInstance$startupPort/webapps
echo "sleep till war file is unpacked in webapps folder"
sleep 10
#cd /home/$user/$TomcatInstance/webapps/jenkins$JenkinsVersion

if grep -q 'CATALINA_OPTS=\"$CATALINA_OPTS $JPDA_OPTS\"' /home/$user/TomcatInstance$startupPort/bin/catalina.sh;
then 
	sed -i 's|CATALINA_OPTS=\"$CATALINA_OPTS $JPDA_OPTS\"|CATALINA_OPTS=\"-DJENKINS_HOME=/home/'$user'/TomcatInstance'$startupPort'/webapps/jenkins'$JenkinsVersion' -Xmx512m\"|g' /home/$user/TomcatInstance$startupPort/bin/catalina.sh
else 
	sed -i 's|.*"-DJENKINS_HOME=.*|CATALINA_OPTS=\"-DJENKINS_HOME=/home/'$user'/TomcatInstance'$startupPort'/webapps/jenkins'$JenkinsVersion' -Xmx512m\"|g' /home/$user/TomcatInstance$startupPort/bin/catalina.sh
fi

cd /home/$user/TomcatInstance$startupPort/bin/
./catalina.sh
echo "executing the startup script for instance TomcatInstance$startupPort"
./startup.sh
#sleep 2
#firefox localhost:$startupPort/jenkins$JenkinsVersion

