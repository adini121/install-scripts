#! /bin/bash

# Description: Deployment script for jenkins, takes as input : User, Jenkins version, Tomcat Port on which Jenkins will run
# Author: Aditya
# ChangeLog: added createJenkinsHome() function - Aug 13
# Date: 11.08.15

echo "running script for creating multiple tomcat instances under the home directory"
usage(){
        echo "Usage: $0 <OPTIONS>"
        echo "Required options:"
        echo "  -u <UID>                user name"
        echo "  -v <JenkinsVersion>     Jenkins version"
        echo "  -s <startupPort>        Tomcat startup port"
        exit 1
}

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

if [ ! -f /home/$user/tomcat/TomcatInstance$startupPort/webapps/jenkins$JenkinsVersion ]; then
cp /home/$user/JenkinsWarFiles/jenkins"$JenkinsVersion".war /home/$user/tomcat/TomcatInstance$startupPort/webapps
fi

echo "sleep till war file is unpacked in webapps folder"
sleep 10
}

tomcatServerXMLconfig(){
echo "TO BE EDITED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
}

jenkinsCatalina_OptsConfig(){
if grep -q 'CATALINA_OPTS=\"$CATALINA_OPTS $JPDA_OPTS\"' /home/$user/tomcat/TomcatInstance$startupPort/bin/catalina.sh;
then
        sed -i 's|CATALINA_OPTS=\"$CATALINA_OPTS $JPDA_OPTS\"|CATALINA_OPTS=\"-DJENKINS_HOME=/home/'$user'/jenkinsHome/jenkinsHome'$JenkinsVersion' -Xmx1024m\"|g' /home/$user/tomcat/TomcatInstance$startupPort/bin/catalina.sh
else
        sed -i 's|.*"-DJENKINS_HOME=.*|CATALINA_OPTS=\"-DJENKINS_HOME=/home/'$user'/jenkinsHome/jenkinsHome'$JenkinsVersion' -Xmx1024m\"|g' /home/$user/tomcat/TomcatInstance$startupPort/bin/catalina.sh
fi
}

jenkinsXMLconfig(){
if [ ! -f /home/$user/tomcat/TomcatInstance$startupPort/conf/Catalina/localhost/jenkins.xml ]; then
	touch /home/$user/tomcat/TomcatInstance$startupPort/conf/Catalina/localhost/jenkins.xml
        cat > /home/$user/tomcat/TomcatInstance$startupPort/conf/Catalina/localhost/jenkins.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<Context docBase="/home/$user/tomcat/TomcatInstance$startupPort/webapps/jenkins"$JenkinsVersion".war">
	<Environment name="JENKINS_HOME" value="/home/$user/jenkinsHome/jenkinsHome$JenkinsVersion" type="java.lang.String" override="true"/>
</Context>
EOF

else
 	sed -i 's|.*docBase=.*|<Context docBase=\"/home/'$user'/tomcat/TomcatInstance'$startupPort'/webapps/jenkins'$JenkinsVersion'\">|g' /home/$user/tomcat/TomcatInstance$startupPort/conf/Catalina/localhost/jenkins.xml
	sed -i 's|.*Environment name=.*|<Environment name=\"JENKINS_HOME\" value=\"/home/'$user'/jenkinsHome/jenkinsHome'$JenkinsVersion'\" type=\"java.lang.String\" override=\"true\"/>|g' /home/$user/tomcat/TomcatInstance$startupPort/conf/Catalina/localhost/jenkins.xml
fi
}

jenkinsAddConfigXMLFile(){
if [ ! -f /home/$user/tomcat/TomcatInstance$startupPort/webapps/jenkins$JenkinsVersion/WEB-INF/context.xml ]; then
        touch /home/$user/tomcat/TomcatInstance$startupPort/webapps/jenkins$JenkinsVersion/WEB-INF/context.xml
	chmod 777 /home/$user/tomcat/TomcatInstance$startupPort/webapps/jenkins$JenkinsVersion/WEB-INF/context.xml
        cat > /home/$user/tomcat/TomcatInstance$startupPort/webapps/jenkins$JenkinsVersion/WEB-INF/context.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<Context docBase="/home/$user/tomcat/TomcatInstance$startupPort/webapps/jenkins"$JenkinsVersion".war">
        <Environment name="JENKINS_HOME" value="/home/$user/jenkinsHome/jenkinsHome$JenkinsVersion" type="java.lang.String" override="true"/>
</Context>
EOF

else
        sed -i 's|.*docBase=.*|<Context docBase=\"/home/'$user'/tomcat/TomcatInstance'$startupPort'/webapps/jenkins'$JenkinsVersion'\">|g' /home/$user/tomcat/TomcatInstance$startupPort/webapps/jenkins$JenkinsVersion/WEB-INF/context.xml
        sed -i 's|.*Environment name=.*|<Environment name=\"JENKINS_HOME\" value=\"/home/'$user'/jenkinsHome/jenkinsHome'$JenkinsVersion'\" type=\"java.lang.String\" override=\"true\"/>|g' /home/$user/tomcat/TomcatInstance$startupPort/webapps/jenkins$JenkinsVersion/WEB-INF/context.xml
fi
}

jenkinsWebXMLconfig(){
if grep -q 'HUDSON_HOME' /home/$user/tomcat/TomcatInstance$startupPort/webapps/jenkins$JenkinsVersion/WEB-INF/web.xml; then
	sed -i 's|<env-entry-name>HUDSON_HOME</env-entry-name>|<env-entry-name>JENKINS_HOME</env-entry-name>|g' /home/$user/tomcat/TomcatInstance$startupPort/webapps/jenkins$JenkinsVersion/WEB-INF/web.xml
fi

	sed -i 's|.*</env-entry-value>*.|<env-entry-value>/home/'$user'/jenkinsHome/jenkinsHome'$JenkinsVersion'</env-entry-value>|g' /home/$user/tomcat/TomcatInstance$startupPort/webapps/jenkins$JenkinsVersion/WEB-INF/web.xml
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

export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-amd64
export PATH=$PATH:$JAVA_HOME

/home/$user/tomcat/TomcatInstance$startupPort/bin/startup.sh

echo "Creating Jenkins Home -------->"
createJenkinsHome

echo "jenkins war download ------------>"
jenkinsWarDownload

echo "tomcat server config-------------->"
tomcatServerXMLconfig

echo "jenkins Path Configurations---------->"
jenkinsCatalina_OptsConfig

jenkinsXMLconfig

jenkinsAddConfigXMLFile

jenkinsWebXMLconfig