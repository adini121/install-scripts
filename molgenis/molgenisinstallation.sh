#! /bin/bash

usage(){
        echo "Usage: $0 <OPTIONS>"
        echo "Required options:"
        echo "  -u <UID>                user name (e.g. adi)"
        echo "  -m <molgenisVersion>    Molgenis Version"
        echo "  -s <startupPort>        Tomcat startup port (e.g. 8082)"
        exit 1
}

molgenis_tomcat_home=/home/$user/tomcat/TomcatInstance$startupPort
molgenis_home=/home/$user/.molgenis/omx

molgenisDatabaseCreation(){
if [ ! -f $molgenis_tomcat_home/lib/mysql-connector-java-5.1.24.jar ]; then
    wget http://central.maven.org/maven2/mysql/mysql-connector-java/5.1.24/mysql-connector-java-5.1.24.jar -P $molgenis_tomcat_home/lib
fi
mysql -u root << EOF
DROP DATABASE IF EXISTS omx;
create database omx;
# grant all privileges on omx.* to molgenis@localhost identified by 'molgenis';
# flush privileges;
EOF
}

molgenisHomeConfiguration() {
if [ -d $molgenis_home ]; then
    rm -rf $molgenis_home
fi

mkdir -p $molgenis_home;

touch $molgenis_home/molgenis-server.properties
chmod 777 $molgenis_home/molgenis-server.properties
cat > $molgenis_home/molgenis-server.properties << EOF
db_user=root
db_password=
db_uri=jdbc\:mysql\://localhost/omx
admin.password=admin
user.password=admin
EOF
}

molgenisTomcatConfiguration(){
rm -rf $molgenis_tomcat_home/webapps/*
cp /home/$user/MolgenisWarFiles/molgenis"$molgenisVersion".war $molgenis_tomcat_home/webapps/ROOT.war
sleep 10
sed -i 's|.*CATALINA_OPTS=.*|CATALINA_OPTS=\"-Xmx2g -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -Dmolgenis.home=/home/$user/.molgenis/omx"|g' $molgenis_tomcat_home/bin/catalina.sh
# sed -i '' 's|redirectPort=\"8443\"|redirectPort=\"8443\" maxPostSize=\"33554432\" scheme=\"https\" proxyPort=\"443\" URIEncoding=\"UTF-8\"/>|g' $molgenis_tomcat_home/conf/server.xml
rm -f $molgenis_tomcat_home/logs/catalina.out
export CATALINA_OPTS="-Xmx2g -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -Dmolgenis.home=/home/$user/.molgenis/omx"
sleep 5
$molgenis_tomcat_home/bin/shutdown.sh
sleep 5
$molgenis_tomcat_home/bin/startup.sh
}


while getopts ":u:m:s:" i; do
        case "${i}" in
        u) user=${OPTARG}
        ;;
        m) molgenisVersion=${OPTARG}
        ;;
        s) startupPort=${OPTARG}
        esac
done

shift $((OPTIND - 1))

if [[ $user == "" || $molgenisVersion == "" || $startupPort == "" ]]; then
        usage
fi

#..........................................function calls...................................

molgenisDatabaseCreation

molgenisHomeConfiguration

molgenisTomcatConfiguration
