#! /bin/bash

# Description: Deployment script for jenkins, takes as input : User, Jenkins version, Tomcat Port on which Jenkins will run
# Author: Aditya
# ChangeLog: added createJenkinsHome() function - Aug 13
# Date: 11.08.15

usage(){
        echo "Usage: $0 <OPTIONS>"
        echo "<<<<<<<<<<< Please set JAVA_HOME Environment Variable >>>>>>>>>"
        echo "!!!!!!!!!!! Only ONE Jenkins Instance per Tomcat Instance !!!!!!!!!!!"
        echo "Required options:"
        echo "  -u <UID>                user name (e.g. adi)"
        echo "  -v <JenkinsVersion>     Jenkins version (e.g. 1.600, 1.615)"
        echo "  -s <startupPort>        Tomcat startup port (e.g. 8082)"
        exit 1
}

createJenkinsHome(){
echo "..............................................createJenkinsHome.............................................."

if [ ! -d /home/$user/jenkinsHome ]; then
	echo 'no jenkins home directory found.'
        mkdir -p /home/$user/jenkinsHome
	echo 'created new directory'
fi 

JENKINS_HOME_DIR="/home/$user/jenkinsHome/jenkinsHome$JenkinsVersion"

if [ ! -d $JENKINS_HOME_DIR ]; then
        mkdir -p $JENKINS_HOME_DIR
	echo "created JENKINS_HOME_DIR"
elif [[ -d $JENKINS_HOME_DIR ]]; then
        echo "removing already present JENKINS_HOME_DIR at "$JENKINS_HOME_DIR""
        rm -r $JENKINS_HOME_DIR
        mkdir -p $JENKINS_HOME_DIR
        echo "created clean JENKINS_HOME_DIR"

fi

}

increaseMavenHeapSpace(){
export MAVEN_OPTS="-Xmx1024M"
}

jenkinsWarDownload(){
echo "..............................................jenkinsWarDownload.............................................."

if [ ! -d /home/$user/JenkinsWarFiles ]; then
	mkdir -p /home/$user/JenkinsWarFiles
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
# ..............................................tomcatServerXMLconfig..............................................

# tomcatServerXMLconfig(){
# echo "TO BE EDITED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
# }


jenkinsCatalina_OptsConfig(){
echo ".............................................jenkinsCatalina_OptsConfig.............................................."

if grep -q 'CATALINA_OPTS=\"$CATALINA_OPTS $JPDA_OPTS\"' /home/$user/tomcat/TomcatInstance$startupPort/bin/catalina.sh;
then
        sed -i 's|CATALINA_OPTS=\"$CATALINA_OPTS $JPDA_OPTS\"|CATALINA_OPTS=\"-DJENKINS_HOME=/home/'$user'/jenkinsHome/jenkinsHome'$JenkinsVersion' -Xmx1024m\"|g' /home/$user/tomcat/TomcatInstance$startupPort/bin/catalina.sh
else
        sed -i 's|.*"-DJENKINS_HOME=.*|CATALINA_OPTS=\"-DJENKINS_HOME=/home/'$user'/jenkinsHome/jenkinsHome'$JenkinsVersion' -Xmx1024m\"|g' /home/$user/tomcat/TomcatInstance$startupPort/bin/catalina.sh
fi
}

jenkinsXMLconfig(){
echo "..............................................jenkinsXMLconfig.............................................."

if [ ! -f /home/$user/tomcat/TomcatInstance$startupPort/conf/Catalina/localhost/jenkins.xml ]; then
	touch /home/$user/tomcat/TomcatInstance$startupPort/conf/Catalina/localhost/jenkins.xml
        cat > /home/$user/tomcat/TomcatInstance$startupPort/conf/Catalina/localhost/jenkins.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<Context docBase="/home/$user/tomcat/TomcatInstance$startupPort/webapps/jenkins"$JenkinsVersion".war">
	<Environment name="JENKINS_HOME" value="$JENKINS_HOME_DIR" type="java.lang.String" override="true"/>
</Context>
EOF

else
 	sed -i 's|.*docBase=.*|<Context docBase=\"/home/'$user'/tomcat/TomcatInstance'$startupPort'/webapps/jenkins'$JenkinsVersion'\">|g' /home/$user/tomcat/TomcatInstance$startupPort/conf/Catalina/localhost/jenkins.xml
	sed -i 's|.*Environment name=.*|<Environment name=\"JENKINS_HOME\" value=\"/home/'$user'/jenkinsHome/jenkinsHome'$JenkinsVersion'\" type=\"java.lang.String\" override=\"true\"/>|g' /home/$user/tomcat/TomcatInstance$startupPort/conf/Catalina/localhost/jenkins.xml
fi
}


jenkinsAddConfigXMLFile(){
echo "..............................................jenkinsAddConfigXMLFile.............................................."

if [ ! -f /home/$user/tomcat/TomcatInstance$startupPort/webapps/jenkins$JenkinsVersion/WEB-INF/context.xml ]; then
        touch /home/$user/tomcat/TomcatInstance$startupPort/webapps/jenkins$JenkinsVersion/WEB-INF/context.xml
	chmod 777 /home/$user/tomcat/TomcatInstance$startupPort/webapps/jenkins$JenkinsVersion/WEB-INF/context.xml
        cat > /home/$user/tomcat/TomcatInstance$startupPort/webapps/jenkins$JenkinsVersion/WEB-INF/context.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<Context docBase="/home/$user/tomcat/TomcatInstance$startupPort/webapps/jenkins"$JenkinsVersion".war">
        <Environment name="JENKINS_HOME" value="$JENKINS_HOME_DIR" type="java.lang.String" override="true"/>
</Context>
EOF

else
        sed -i 's|.*docBase=.*|<Context docBase=\"/home/'$user'/tomcat/TomcatInstance'$startupPort'/webapps/jenkins'$JenkinsVersion'\">|g' /home/$user/tomcat/TomcatInstance$startupPort/webapps/jenkins$JenkinsVersion/WEB-INF/context.xml
        sed -i 's|.*Environment name=.*|<Environment name=\"JENKINS_HOME\" value=\"/home/'$user'/jenkinsHome/jenkinsHome'$JenkinsVersion'\" type=\"java.lang.String\" override=\"true\"/>|g' /home/$user/tomcat/TomcatInstance$startupPort/webapps/jenkins$JenkinsVersion/WEB-INF/context.xml
fi
}

jenkinsWebXMLconfig(){
echo "..............................................jenkinsWebXMLconfig.............................................."

if grep -q 'HUDSON_HOME' /home/$user/tomcat/TomcatInstance$startupPort/webapps/jenkins$JenkinsVersion/WEB-INF/web.xml; then
	sed -i 's|<env-entry-name>HUDSON_HOME</env-entry-name>|<env-entry-name>JENKINS_HOME</env-entry-name>|g' /home/$user/tomcat/TomcatInstance$startupPort/webapps/jenkins$JenkinsVersion/WEB-INF/web.xml
fi

sed -i 's|.*</env-entry-value>*.|<env-entry-value>/home/'$user'/jenkinsHome/jenkinsHome'$JenkinsVersion'</env-entry-value>|g' /home/$user/tomcat/TomcatInstance$startupPort/webapps/jenkins$JenkinsVersion/WEB-INF/web.xml
}

finalsteps(){
echo "..............................................finalsteps.............................................."

        export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-amd64
        export PATH=$PATH:$JAVA_HOME
        # /home/$user/tomcat/TomcatInstance$startupPort/bin/startup.sh
        if [[ ! -f $JENKINS_HOME_DIR/plugins/form-element-path.hpi ]];
        then
                wget https://updates.jenkins-ci.org/latest/form-element-path.hpi -P $JENKINS_HOME_DIR/plugins/
        fi
        /home/$user/tomcat/TomcatInstance$startupPort/bin/startup.sh
        sleep 2
        /home/$user/tomcat/TomcatInstance$startupPort/bin/shutdown.sh
        sleep 2
        /home/$user/tomcat/TomcatInstance$startupPort/bin/startup.sh

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



createJenkinsHome

jenkinsWarDownload

increaseMavenHeapSpace

# tomcatServerXMLconfig

jenkinsCatalina_OptsConfig

jenkinsXMLconfig

jenkinsAddConfigXMLFile

jenkinsWebXMLconfig

finalsteps