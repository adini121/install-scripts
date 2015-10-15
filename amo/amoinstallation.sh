#! /bin/bash

# Description: Deployment script for AMO Mozilla addons app. Takes as input : User, AMO version, Port on which AMO will run
# Author: Aditya



############################################################################################
#############                      DEPENDENCIES                      		 ###############
############################################################################################

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
        echo "Required options:"
        echo "  -u <user>           Eg adi, nisal etc"
        echo "  -b <dbName>         name for AMO database, format : YYMMDD, eg 150715"
        echo "  -t <amoGitTag>      amo git tag format : YYYY.MM.DD, eg 2015.04.25"
        echo "  -a <amoInstance>    Eg amo_first, amo_second, amo_third etc"
        echo "  -p <amoPort>        Eg 8080, 8081, 8083 etc"
        echo " 	-m <memcachedPort>  Eg 11211, 11212, 11213 etc"
        echo "  -r <redisPort       Eg 6379, 6380, 6381 etc"
        exit 1
}

createAMOHome(){
echo "                                             									"                                                                                                                                                                                                          
echo ">>>creating amo home                     					"
echo "                                             									"                                                                                                                                                                                                          

if [ ! -d /home/$user/AMOHome ]; then
	echo ">>>no AMO home directory found."
        mkdir /home/$user/AMOHome
	echo ">>>created AMO directory"
fi 
}

# downloadDependencies (){
# echo "                                             									"                                                                                                                                                                                                          
# echo "                      Download Dependencies                  				"    
# echo "                                             									"                                                                                                                                                                                                          


# 	sudo apt-get install python-dev python-virtualenv npm libxml2-dev libxslt1-dev libmysqlclient-dev memcached libssl-dev swig openssl curl libjpeg-dev zlib1g-dev libsasl2-dev nodejs nodejs-legacy
# 	

# }

installAMOolympiaCode(){
echo "                              												"                                                                                                                                                                         
echo ">>>installing amo code from olympia                     	 "
echo "                                             									"                                                                                                                                                          

		if [ ! -d /home/$user/AMOHome/$amoInstance ]; then
			git clone --recursive git://github.com/mozilla/olympia.git  /home/$user/AMOHome/$amoInstance
		fi
 	
	cd /home/$user/AMOHome/$amoInstance
	git pull
	git checkout $amoGitTag
}

# startElasticSearch(){
# tmux kill-session -t elastic-search 
# echo ".............Elasticsearch.........."
# tmux new -d -A -s elastic-search '
# /home/$user/elasticsearch/bin/elasticsearch
# tmux detach'
# }

amoDBsettings(){
	echo "                                             									"     
	echo ">>> amo database settings          			            "
	echo "                                             									"     
	mysql -u root << EOF
	CREATE DATABASE IF NOT EXISTS amo_$dbName DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
	GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,CREATE TEMPORARY TABLES,DROP,INDEX,ALTER ON amo_$dbName.* TO 'amouser'@'localhost' IDENTIFIED BY 'amopassword';
	GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,CREATE TEMPORARY TABLES,DROP,INDEX,ALTER ON test_olympia.* TO 'amouser'@'localhost' IDENTIFIED BY 'amopassword';
EOF
}

configureLocalSettings() {
echo "                                             									"                                                                                                                                                                                                          
echo ">>>configuring local_settings.py file                      "
echo "                                             									"     
echo ">>>checking if local_settings.py is present"
if [  ! -f /home/$user/AMOHome/$amoInstance/local_settings.py ];
        then 
        		touch /home/$user/AMOHome/$amoInstance/local_settings.py
        		chmod 755 /home/$user/AMOHome/$amoInstance/local_settings.py
        		echo "created local_settings.py"
cat > /home/$user/AMOHome/$amoInstance/local_settings.py << EOF
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
 		'LOCATION': os.environ.get('MEMCACHE_LOCATION', 'localhost:$memcachedPort'),     
	}
}

# Elasticsearch

ES_HOSTS = [os.environ.get('ELASTICSEARCH_LOCATION', '127.0.0.1:9200')]
ES_URLS = ['http://%s' % h for h in ES_HOSTS]
ES_INDEXES = {
	'default': 'addons_$amoInstance',
 	'stats': 'addons_$amoInstance_stats',
}

# Celery
BROKER_URL = os.environ.get('BROKER_URL',
            'amqp://olympia:olympia@localhost:5672/$amoInstance')

REDIS_LOCATION = os.environ.get('REDIS_LOCATION', 'localhost:$redisPort')
REDIS_BACKENDS = {
    'master': 'redis://{location}?socket_timeout=0.5'.format(
    location=REDIS_LOCATION)}
EOF
        		echo "exiting local_settings.py"
fi
}


runAMOinstance(){
echo "                                             									"                                                                                                                                                                                                          
echo ">>>running full_init and server at localhost:"$amoPort"             "
echo "                                             									"                                                                                                                                                                                                          
	curl -sL https://raw.github.com/brainsik/virtualenv-burrito/master/virtualenv-burrito.sh | $SHELL
                                                                                                                                                                                                       
echo "                                             									"                                                                                                                                                                                                          
echo ">>>source virtualenv for "$runAMOinstance"						"				                         
echo "                                             									"                                                                                                                                                                                                          


	source /home/$user/.venvburrito/startup.sh
	sleep 5                                                                                                                                                                                                     
echo "                                             									"                                                                                                                                                                                                          
echo ">>>MAKE virtualenv for "$amoInstance"						"				                         
echo "                                             									"                                                                                                                                                                                                          
	mkvirtualenv $amoInstance
echo "                                             									"                                                                                                                                                                                                          
echo ">>>upgrade pip										"		  		                                                 
echo "                                             									"                                                                                                                                                                                                          
	pip install --upgrade pip #making sure pip is in recent version
	sleep 2
echo "                                             									"                                                                                                                                                                                                          
echo ">>>make full init 									" 		                         
echo "                                             									"                                                                                                                                                                                                          
	workon $amoInstance

	/usr/bin/expect <<EOD
	make full_init
	expect \"Type 'yes' to continue, or 'no' to cancel:\"
	send \"yes\r\"
	expect eof
	expect \"Username:\"
	send \"admin\r"
	expect \"Email:\"
	send \"adamsken1221@gmail.com\r"
	expect \"Password:\"
	send \"adsad121\r"
	expect \"Password (again):\"
	send \"adsad121r\"
	expect eof
	expect \"Are you sure you want to wipe all AMO Elasticsearch indexes? (yes/no):\"
	send \"yes\r"
	expect eof
EOD
	/home/$user/AMOHome/$amoInstance/manage.py activate_user --set-admin admin@admin.com

echo "                                             									"                                                                                                                                                                                                          
echo ">>>runserver at "$amoPort"								" 		                         
echo "                                             									"                                                                                                                                                                                                          
/home/$user/AMOHome/$amoInstance/manage.py runserver localhost:$amoPort
	
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

runAMOinstance
