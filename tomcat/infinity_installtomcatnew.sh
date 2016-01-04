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
export tomcat_home=/home/$user/tomcat/TomcatInstance$startupPort
tomcatInstanceCreation(){
echo "tomcat instance creation script. Installing instance TomcatInstance$startupPort"
if [ ! -d $tomcat_home ]; then
	mkdir $tomcat_home
else 
	echo "Tomcat instance TomcatInstance$startupPort already exists"
fi
        cp -R /home/$user/tomcat/apache-tomcat-7.0.63/* $tomcat_home
        sleep 2
}
changingTomcatConf() {
touch $tomcat_home/bin/setenv.sh
chmod 777 $tomcat_home/bin/setenv.sh
cat > $tomcat_home/bin/setenv.sh << EOF
JAVA_OPTS="-Xms128m -Xmx512m"
EOF
sed -i 's|<Connector port=\"8080\"|<Connector port=\"'$startupPort'\"|g' $tomcat_home/conf/server.xml
sed -i 's|<Server port=\"8005\"|<Server port=\"'$shutdownPort'\"|g' $tomcat_home/conf/server.xml
sed -i 's|<Connector port=\"8009\"|<Connector port=\"'$connectorPort'\"|g' $tomcat_home/conf/server.xml
sed -i 's|redirectPort=\"8443\"|redirectPort=\"8443\" URIEncoding=\"UTF-8\"/>|g' $tomcat_home/conf/server.xml
$tomcat_home/bin/startup.sh
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
