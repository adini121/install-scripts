#! /bin/bash
echo "checking if local_settings.py is present"
if [  ! -f /Users/adityanisal/Desktop/install-scripts/amo/local_settings.py ];
        then 
        		touch /Users/adityanisal/Desktop/install-scripts/amo/local_settings.py
        		chmod 755 /Users/adityanisal/Desktop/install-scripts/amo/local_settings.py
        		echo "created local_settings.py"
        		cat > /Users/adityanisal/Desktop/install-scripts/amo/local_settings.py << EOF
               	#local_settings.py 
				#specify the settings for each AMO instance
				from settings import *  # noqa

				#Database settings
				DATABASE_URL = os.environ.get('DATABASE_URL','mysql://amo:amopassword@localhost/olympia_instance')
				DATABASES = {'default': dj_database_url.parse(DATABASE_URL)}
				DATABASES['default']['OPTIONS'] = {'init_command': 'SET storage_engine=InnoDB','sql_mode': 'STRICT_ALL_TABLES'}
				DATABASES['default']['TEST_CHARSET'] = 'utf8'
				DATABASES['default']['TEST_COLLATION'] = 'utf8_general_ci'

				#Memcached
				CACHES = {
 				   'default': {
				        'BACKEND': 'caching.backends.memcached.MemcachedCache',
				        'LOCATION': os.environ.get('MEMCACHE_LOCATION', 'localhost:11212'),
 				   }
				}

				# Elasticsearch
				ES_HOSTS = [os.environ.get('ELASTICSEARCH_LOCATION', '127.0.0.1:9200')]
				ES_URLS = ['http://%s' % h for h in ES_HOSTS]
				ES_INDEXES = {
				    'default': 'addons_instance',
 				   'stats': 'addons_instance_stats',
				}

				# Celery
				BROKER_URL = os.environ.get('BROKER_URL',
                            'amqp://olympia:olympia@localhost:5672/olympia_instance')

				REDIS_LOCATION = os.environ.get('REDIS_LOCATION', 'localhost:6380')
				REDIS_BACKENDS = {
    				'master': 'redis://{location}?socket_timeout=0.5'.format(
        				location=REDIS_LOCATION)}
EOF
        		echo "exiting"
        fi