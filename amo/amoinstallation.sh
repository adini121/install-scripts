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
	DROP DATABASE IF EXISTS amo_$dbName;
	CREATE DATABASE amo_$dbName DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
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


amoFullInit(){
echo "                                             									"                                                                                                                                                                                                          
echo ">>>running full_init            "
echo "                                             									"                                                                                                                                                                                                          
	curl -sL https://raw.github.com/brainsik/virtualenv-burrito/master/virtualenv-burrito.sh | $SHELL
                                                                                                                                                                                                       
echo "                                             									"                                                                                                                                                                                                          
echo ">>>source virtualenv for "$amoInstance"						"				                         
echo "                                             									"                                                                                                                                                                                                          


	source /home/$user/.venvburrito/startup.sh
	sleep 5                                                                                                                                                                                                     
echo "                                             									"                                                                                                                                                                                                          
echo ">>>MAKE clean virtualenv for "$amoInstance"						"				                         
echo "                                             									"                                                                                                                                                                                                          
	#rmvirtualenv $amoInstance
	mkvirtualenv $amoInstance
	curl -XDELETE 'http://localhost:9200/addons_'$amoInstance'-*/'
# # echo "                                             									"                                                                                                                                                                                                          
# # echo ">>>upgrade pip										"		  		                                                 
# # echo "                                             									"                                                                                                                                                                                                          
# 	#pip install --upgrade pip #making sure pip is in recent version
# 	sleep 2
echo "                                             									"                                                                                                                                                                                                          
echo ">>>make full init 									" 		                         
echo "                                             									"                                                                                                                                                                                                          
	
workon $amoInstance
sleep 1
/usr/bin/expect <<EOD
set timeout 540
spawn make full_init
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
expect "Are you sure you want to wipe all AMO Elasticsearch indexes? (yes/no):"
send "yes\r"
expect eof
EOD
}

startAMO_SeleniumNode(){
	echo "starting tmux session selenium-node-AMO-AMO"
	tmux kill-session -t selenium-node-AMO
	tmux new -d -A -s selenium-node-AMO '
	export DISPLAY=:0.0
	sleep 3
	/usr/bin/java -jar /home/'$USER'/selenium-server-standalone-2.47.1.jar -role node -hub http://localhost:4444/grid/register -browser browserName=firefox -platform platform=LINUX 2>&1 | tee '$AMOBaseDir'/AMO-test-reports/test_log_from_SeNode_'$AMOGitTag'.log
	sleep 2
	tmux detach'
	# sleep 5
	# echo "exiting tmux session selenium-node-AMO"
}

runAMOInstance(){
echo "Setting default admin user"
/home/$user/AMOHome/$amoInstance/manage.py activate_user --set-admin adamsken1221@gmail.com

echo "starting tmux session selenium-node-AMO-AMO"
	tmux kill-session -t selenium-node-AMO
	tmux new -d -A -s selenium-node-AMO '                                                                                                                                                                                              
	/home/'$user'/AMOHome/'$amoInstance'/manage.py runserver localhost:'$amoPort'
	tmux detach'
	
}

activateAMObanner() {
 echo "creating amo banner"
 if [ ! -d /home/$user/AMOHome/AMO-banner-launch ];
 	then
 	git -C /home/$user/AMOHome/ clone https://github.com/adini121/AMO-banner-launch.git
 fi

 	sleep 2
 	sed -i 's|.*URL=.*|URL=http://localhost:'$amoPort'/en-US/|g' /home/$user/AMOHome/AMO-banner-launch/src/main/resources/amo.properties
 	cd /home/$user/AMOHome/AMO-banner-launch
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
