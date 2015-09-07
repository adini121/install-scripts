#! /bin/bash

# Description: Deployment script for jenkins, takes as input : User, Jenkins version, Tomcat Port on which Jenkins will run
# Author: Aditya
# ChangeLog: added createJenkinsHome() function - Aug 13
# Modified for tomcat7 installed via apt-get package
# Date: 14.08.15

echo "running script for creating multiple tomcat instances under the home directory"
usage(){
        echo "Usage: $0 <OPTIONS>"
        echo "Required options:"
        echo "  -u <UID>                user name"
        echo "  -v <JenkinsVersion>     Jenkins version"
        echo "  -s <startupPort>        Tomcat startup port"
        exit 1
}

export CATALINA_BASE=/var/lib/tomcat7
export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-i386

createJenkinsHome(){
if [ ! -d /home/$user/jenkinsHome ]; then
	echo 'no jenkins home directory found.'
        mkdir /home/$user/jenkinsHome
	echo 'created new directory'
fi 

if [ ! -d /home/$user/jenkinsHome/jenkinsHome$JenkinsVersion ]; then
        mkdir /home/$user/jenkinsHome/jenkinsHome$JenkinsVersion
	echo "created the folder with version name"
fi

}

jenkinsWarDownload(){
echo "downloading jenkins war file"
if [ ! -d /home/$user/JenkinsWarFiles ]; then
	mkdir /home/$user/JenkinsWarFiles
fi

if [ ! -f /home/$user/JenkinsWarFiles/jenkinsPortMapping.txt ]; then
	touch /home/$user/JenkinsWarFiles/jenkinsPortMapping.txt
fi

echo " Jenkins Version: '$JenkinsVersion' at tomcat port: '$startupPort'" >> /home/$user/JenkinsWarFiles/jenkinsPortMapping.txt
if [ ! -f  /home/$user/JenkinsWarFiles/jenkins"$JenkinsVersion".war ]; then
wget https://updates.jenkins-ci.org/download/war/$JenkinsVersion/jenkins.war -O /home/$user/JenkinsWarFiles/jenkins"$JenkinsVersion".war
fi

echo "unpacking jenkins war to webapps folder" 
if [ ! -f /var/lib/tomcat7/webapps/jenkins$JenkinsVersion ]; then
sudo cp /home/$user/JenkinsWarFiles/jenkins"$JenkinsVersion".war /var/lib/tomcat7/webapps/
fi

echo "sleep till war file is unpacked in webapps folder"
sleep 10
}

jenkinsPathConfig(){
export CATALINA_BASE=/var/lib/tomcat7
export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-i386
if grep -q 'CATALINA_OPTS=\"$CATALINA_OPTS $JPDA_OPTS\"' /usr/share/tomcat7/bin/catalina.sh;
then
	sudo sed -i 's|CATALINA_OPTS=\"$CATALINA_OPTS $JPDA_OPTS\"|CATALINA_OPTS=\"-DJENKINS_HOME=/home/'$user'/jenkinsHome/jenkinsHome'$JenkinsVersion' -Xmx1024m\"|g' /usr/share/tomcat7/bin/catalina.sh
else
	sudo  sed -i 's|.*"-DJENKINS_HOME=.*|CATALINA_OPTS=\"-DJENKINS_HOME=/home/'$user'/jenkinsHome/jenkinsHome'$JenkinsVersion' -Xmx1024m\"|g' /usr/share/tomcat7/bin/catalina.sh
fi
#echo "modified catalina.sh script for instance TomcatInstance$startupPort"
#sudo /usr/share/tomcat7/bin/catalina.sh start
#echo "executing the startup script for instance TomcatInstance$startupPort"
sudo /usr/share/tomcat7/bin/startup.sh

if [ ! -f /var/lib/tomcat7/conf/Catalina/localhost/jenkins.xml ]; then
	sudo touch /var/lib/tomcat7/conf/Catalina/localhost/jenkins.xml
        sudo chmod 777 /var/lib/tomcat7/conf/Catalina/localhost/jenkins.xml
	sudo cat > /var/lib/tomcat7/conf/Catalina/localhost/jenkins.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<Context docBase="/var/lib/tomcat7/webapps/jenkins"$JenkinsVersion".war">
	<Environment name="JENKINS_HOME" value="/home/$user/jenkinsHome/jenkinsHome$JenkinsVersion" type="java.lang.String" override="true"/>
</Context>
EOF

else
 	sudo sed -i 's|.*docBase=.*|<Context docBase=\"/var/lib/tomcat7/webapps/jenkins'$JenkinsVersion'\">|g' /var/lib/tomcat7/conf/Catalina/localhost/jenkins.xml
	sudo sed -i 's|.*Environment name=.*|<Environment name=\"JENKINS_HOME\" value=\"/home/'$user'/jenkinsHome/jenkinsHome'$JenkinsVersion'\" type=\"java.lang.String\" override=\"true\"/>|g' /var/lib/tomcat7/conf/Catalina/localhost/jenkins.xml
fi

sudo service tomcat7 restart
}

while getopts ":u:v:s:" i; do
        case "${i}" in
        u) user=${OPTARG}
        ;;
	v) JenkinsVersion=${OPTARG}
	;;
        s) startupPort=${OPTARG}
        esac
done

shift $((OPTIND - 1))

if [[ $user == "" || $JenkinsVersion == "" || $startupPort == "" ]]; then
        usage
fi

echo $JenkinsVersion
echo $user
echo $startupPort 

#export CATALINA_BASE=/var/lib/tomcat7
#export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-i386
#export JENKINS_HOME=/home/$user/jenkinsHome/JenkinsHome$JenkinsVersion
#export PATH=$PATH:$JENKINS_HOME

#echo $PATH
#echo $JENKINS_HOME

echo "Creating Jenkins Home -------->"
createJenkinsHome

echo "jenkins war download ------------>"
jenkinsWarDownload

echo "jenkins Path ---------->"
jenkinsPathConfig
