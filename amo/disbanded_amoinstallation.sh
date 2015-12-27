#! /bin/bash

# Description: Deployment script for AMO Mozilla addons app. Takes as input : User, AMO version, Port on which AMO will run
# Author: Aditya

# Dependencies #
# Python 2.7 (2.7 -> 2.7.10)
# Node 0.10.x or higher
# MySQL
# ElasticSearch
# libxml2 (for building lxml, used in tests)
# virtualenv and virtualenvwrapper
# RabbitMQ and Celery
# npm
# memcached
# swig
# LESS compiler


usage(){
        echo "Usage: $0 <OPTIONS>"
        echo "________________________________________________________________________________"
        echo "  Required OPTIONS:                            "
        echo "________________________________________________________________________________"
        echo "  -u <user>           Eg adi, nisal etc"
        echo "  -b <dbName>         name for AMO database, format : YYMMDD, eg 150715"
        echo "  -t <amoGitTag>      amo git tag format : YYYY.MM.DD, eg 2015.04.25, 2015.09.10 "
        echo "  -a <amoInstance>    Eg amo_first, amo_second, amo_third etc"
        echo "  -p <amoPort>        Eg 8080, 8081, 8083 etc"
        # echo "  -m <memcachedPort>  Eg 11211, 11212, 11213 etc"
        # echo "  -r <redisPort       Eg 6379, 6380, 6381 etc"
        echo "________________________________________________________________________________"
        exit 1
}

createAMOHome(){
AMO_HOME_DIR="/home/$user/AMOHome"
echo "____________________AMO base directory is : "$AMO_HOME_DIR"____________________" 

if [ ! -d $AMO_HOME_DIR ]; then
	echo "____________________no AMO home directory found.____________________"
        mkdir $AMO_HOME_DIR
	echo "____________________created AMO directory____________________"
fi 
}

installAMOolympiaCode(){
if [ -d $AMO_HOME_DIR/$amoInstance ]; then
    rm -rf $AMO_HOME_DIR/$amoInstance 
fi

git -C $AMO_HOME_DIR clone -b $amoGitTag --single-branch --depth=1 git@github.com:mozilla/olympia.git $amoInstance
# git -C $AMO_HOME_DIR/$amoInstance pull
# git -C $AMO_HOME_DIR/$amoInstance checkout $amoGitTag
git submodule update --init --recursive
}


amoDBsettings(){
mysql -u root << EOF
DROP DATABASE IF EXISTS amo_$dbName;
CREATE DATABASE amo_$dbName DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,CREATE TEMPORARY TABLES,DROP,INDEX,ALTER ON amo_$dbName.* TO 'amouser'@'localhost' IDENTIFIED BY 'amopassword';
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,CREATE TEMPORARY TABLES,DROP,INDEX,ALTER ON test_olympia.* TO 'amouser'@'localhost' IDENTIFIED BY 'amopassword';
EOF
}

configureLocalSettings() {
echo "________________________________________________________________________________"                                                                                                                                                                                                          
echo "                      configuring local_settings.py file                      "
echo "________________________________________________________________________________"                                                                                                                                                                                                          
echo "                      checking if local_settings.py is present"

if [ -f $AMO_HOME_DIR/$amoInstance/local_settings.py ]; then
    echo "________________________________________________________________________________"                                                                                                                                                                                                          
    echo "                  local_settings.py is present, deleting it"
    echo "________________________________________________________________________________"                                                                                                                                                                                                          

    rm $AMO_HOME_DIR/$amoInstance/local_settings.py
fi

touch $AMO_HOME_DIR/$amoInstance/local_settings.py
chmod 755 $AMO_HOME_DIR/$amoInstance/local_settings.py
echo "____________________created new local_settings.py____________________"
cat > $AMO_HOME_DIR/$amoInstance/local_settings.py << EOF
#local_settings.py
#specify the settings for each AMO instance
from settings import *  # noqa

#Database settings
DATABASE_URL = os.environ.get('DATABASE_URL','mysql://amouser:amopassword@localhost/amo_$dbName')
DATABASES = {'default': dj_database_url.parse(DATABASE_URL)}
DATABASES['default']['OPTIONS'] = {'init_command': 'SET storage_engine=InnoDB','sql_mode': 'STRICT_ALL_TABLES'}
DATABASES['default']['TEST_CHARSET'] = 'utf8'
DATABASES['default']['TEST_COLLATION'] = 'utf8_general_ci'

#Memcached
CACHES = {
 	'default': {
		'BACKEND': 'caching.backends.memcached.MemcachedCache',
 		'LOCATION': os.environ.get('MEMCACHE_LOCATION', 'localhost:11211'),     
	}
}

# Elasticsearch

ES_HOSTS = [os.environ.get('ELASTICSEARCH_LOCATION', '127.0.0.1:9200')]
ES_URLS = ['http://%s' % h for h in ES_HOSTS]
ES_INDEXES = {
	'default': 'addons_$amoInstance',
 	'stats': 'addons_stats_$amoInstance',
}

# Celery
BROKER_URL = os.environ.get('BROKER_URL',
            'amqp://olympia:olympia@localhost:5672/$amoInstance')

REDIS_LOCATION = os.environ.get('REDIS_LOCATION', 'localhost:6379')
REDIS_BACKENDS = {
    'master': 'redis://{location}?socket_timeout=0.5'.format(
    location=REDIS_LOCATION)}
EOF
echo "________________________________________________________________________________"                                                                                                                                                                                                          
        		echo "exiting local_settings.py"
echo "________________________________________________________________________________"                                                                                                                                                                                                          

}


amoFullInit(){
echo "_________________________Wiping current Elasticsearch indices_____________________"                                                                                                                                                                                                       
curl -XDELETE 'http://localhost:9200/addons_*/'

echo "________________________________________________________________________________"                                                                                                                                                                                                          
echo "			making and activating virtualenv "$amoInstance"					"
echo "________________________________________________________________________________"                                                                                                                                                                                                                                                                                                                                                                                                                    
cd $AMO_HOME_DIR/$amoInstance
pip install virtualenv
virtualenv $amoInstance
source $amoInstance/bin/activate

echo "________________________________________________________________________________"                                                                                                                                                                                                                                                                                                                                                                                                                    
echo "								make disbanded install									" 		                         
echo "________________________________________________________________________________"     

workon $amoInstance
sleep 1
pip install --no-deps --exists-action=w -r requirements/dev.txt --find-links https://pyrepo.stage.mozaws.net/wheelhouse/ --find-links https://pyrepo.stage.mozaws.net/wheelhouse/ --find-links https://pyrepo.stage.mozaws.net/ --no-index
npm install
echo "________________________Done: update_deps___________________________"

/usr/bin/expect <<EOD
set timeout 1000
spawn make initialize_db
expect "Type 'yes' to continue, or 'no' to cancel:"
send "yes\r"
expect "Username:"
send "admin\r"
expect "Email:"
send "adamsken1221@gmail.com\r"
expect "Password:"
send "adsad121\r"
expect "Password (again):"
send "adsad121\r"
expect eof
EOD

sleep 2
echo "________________________Done: initialize_db___________________________"

/home/$user/AMOHome/$amoInstance/manage.py generate_addons --app firefox 10
/home/$user/AMOHome/$amoInstance/manage.py generate_addons --app thunderbird 10
/home/$user/AMOHome/$amoInstance/manage.py generate_addons --app android 10
/home/$user/AMOHome/$amoInstance/manage.py generate_addons --app seamonkey 10
/home/$user/AMOHome/$amoInstance/manage.py generate_themes 10

/usr/bin/expect <<EOD
set timeout 300
spawn /home/$user/AMOHome/$amoInstance/manage.py reindex --wipe --force  
expect "Are you sure you want to wipe all AMO Elasticsearch indexes? (yes/no):"
send "yes\r"
expect eof
EOD

/home/$user/AMOHome/$amoInstance/manage.py compress_assets
/home/$user/AMOHome/$amoInstance/manage.py collectstatic --noinput
}

runAMOInstance(){
echo "____________________Setting default admin user___________________________"
$AMO_HOME_DIR/$amoInstance/manage.py activate_user --set-admin adamsken1221@gmail.com

echo "____________________starting tmux session AMO_"$amoInstance"_____________________"
tmux kill-session -t AMO_$amoInstance
tmux new -d -A -s AMO_$amoInstance '
source '$amoInstance'/bin/activate                                                                                                                                                                                              
/home/'$user'/AMOHome/'$amoInstance'/manage.py runserver 134.96.235.47:'$amoPort'
tmux detach'
}

activateAMObanner() {
echo "________________________________________________________________________________"                                                                                                                                                                                                                                                                                                                                                                                                                    
echo "                              creating amo banner"
echo "________________________________________________________________________________"                                                                                                                                                                                                                                                                                                                                                                                                                    

if [ ! -d $AMO_HOME_DIR/AMO-banner-launch ]; then
 	git -C $AMO_HOME_DIR/ clone https://github.com/adini121/AMO-banner-launch.git
fi

sleep 2
sed -i 's|.*URL=.*|URL=http://134.96.235.47:'$amoPort'/en-US/|g' $AMO_HOME_DIR/AMO-banner-launch/src/main/resources/amo.properties
cd $AMO_HOME_DIR/AMO-banner-launch
export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-amd64
git pull
mvn clean install 
}

while getopts ":u:b:t:a:p:m:r:" i; do
    case "${i}" in
        u) user=${OPTARG}
        ;;
        b) dbName=${OPTARG}
        ;;
        t) amoGitTag=${OPTARG}
        ;;
        a) amoInstance=${OPTARG}
        ;;
        p) amoPort=${OPTARG}
        ;;
        m) memcachedPort=${OPTARG}
        ;;
        r) redisPort=${OPTARG}

    esac
done

shift $((OPTIND - 1))

if [[ $user == "" || $dbName == "" || $amoGitTag == "" || $amoInstance == "" || $amoPort == "" || memcachedPort == "" || redisPort == "" ]]; then
        usage
fi

#                      function calls                      

createAMOHome

installAMOolympiaCode

# startElasticSearch

amoDBsettings

configureLocalSettings

amoFullInit

runAMOInstance

activateAMObanner
