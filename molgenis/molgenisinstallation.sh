#! /bin/bash

usage(){
        echo "Usage: $0 <OPTIONS>"
        echo "Required options:"
        echo "  -u <UID>                user name (e.g. adi)"
        echo "  -m <molgenisVersion>    Molgenis Version"
        echo "  -s <startupPort>        Tomcat startup port (e.g. 8082)"
        exit 1
}
echo "USER is : $user"
TomcatHome=/home/$user/tomcat/TomcatInstance$startupPort
MolgenisHome=/home/$user/.molgenis/omx

molgenisDatabaseCreation(){
if [ ! -f $TomcatHome/lib/mysql-connector-java-5.1.24.jar ]; then
    wget http://central.maven.org/maven2/mysql/mysql-connector-java/5.1.24/mysql-connector-java-5.1.24.jar -P $TomcatHome/lib
fi
mysql -u root << EOF
DROP DATABASE IF EXISTS omx;
create database omx;
# grant all privileges on omx.* to molgenis@localhost identified by 'molgenis';
# flush privileges;
EOF
}

molgenisHomeConfiguration() {
if [ -d $MolgenisHome ]; then
    rm -rf $MolgenisHome
fi

mkdir -p $MolgenisHome;

touch $MolgenisHome/molgenis-server.properties
chmod 777 $MolgenisHome/molgenis-server.properties
cat > $MolgenisHome/molgenis-server.properties << EOF
db_user=root
db_password=
db_uri=jdbc\:mysql\://localhost/omx
admin.password=admin
user.password=admin
EOF
}

molgenisTomcatConfiguration(){
rm -rf $TomcatHome/webapps/*
cp /home/$user/MolgenisWarFiles/molgenis"$molgenisVersion".war $TomcatHome/webapps/ROOT.war
sleep 10
sed -i 's|.*CATALINA_OPTS=.*|CATALINA_OPTS=\"-Xmx2g -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -Dmolgenis.home=/home/$user/.molgenis/omx"|g' $TomcatHome/bin/catalina.sh
# sed -i '' 's|redirectPort=\"8443\"|redirectPort=\"8443\" maxPostSize=\"33554432\" scheme=\"https\" proxyPort=\"443\" URIEncoding=\"UTF-8\"/>|g' $TomcatHome/conf/server.xml
rm -f $TomcatHome/logs/catalina.out
export CATALINA_OPTS="-Xmx2g -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -Dmolgenis.home=/home/$user/.molgenis/omx"
sleep 5
$TomcatHome/bin/shutdown.sh
sleep 5
$TomcatHome/bin/startup.sh
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
