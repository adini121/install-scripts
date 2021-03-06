#! /bin/bash

# Description: Deployment script for Moodle, takes as input : User, Moodle version (without spl chars), Git tag, Moodle instance name
# Author: Aditya
# ChangeLog: 
# Date: 1.09.15

usage(){
        echo "Usage: $0 <OPTIONS>"
        echo "Required options:"
        echo "root user Required"
        echo "  -u $USER               user name"
        echo "  -v <MoodleVersion>     Moodle version for database and moodle home (eg 270, 281 etc)"
        echo "  -t <MoodleGitTag>      Moodle git tag eg: v2.7.1, v2.7.0"
        echo "  -m <moodleInstance>    Eg moodle_second, moodle_third"
        echo "  -i <moodle_ip>			Eg 134.96.222.14"
        exit 1
}

installMoodleCode(){
	echo "................................installing moodle code......................................."

		if [ ! -d /var/www/$moodleInstance ]; then
			git -C /var/www/ clone git://git.moodle.org/moodle.git $moodleInstance
		fi
 
	git -C /var/www/$moodleInstance pull
	git -C /var/www/$moodleInstance checkout $MoodleGitTag
}

moodleDBsettings(){
	echo "................................moodle database settings......................................."
	mysql -u root << EOF
	DROP DATABASE IF EXISTS moodle_$MoodleVersion;
	CREATE DATABASE moodle_$MoodleVersion DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
	GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,CREATE TEMPORARY TABLES,DROP,INDEX,ALTER ON moodle_$MoodleVersion.* TO 'moodleuser'@'localhost' IDENTIFIED BY 'moodlepassword';
EOF
}

createMoodleHome(){
	echo "................................Creating moodledata home directory................................"
	mkdir -p /home/$USER/MooodleData
	if [ -d /home/$USER/MooodleData/moodledata_$MoodleVersion ]; then
			rm -rf /home/$USER/MooodleData/moodledata_$MoodleVersion
	fi
	mkdir -p /home/$USER/MooodleData/moodledata_$MoodleVersion
	

	chmod 0777 /home/$USER/MooodleData/moodledata_$MoodleVersion

	#mkdir /home/$USER/moodle/moodledata/moodledata_$MoodleVersion
	#chmod 0777 /home/$USER/moodle/moodledata/moodledata_$MoodleVersion

# chmod -R +a "www-admin allow read,delete,write,append,file_inherit,directory_inherit" /path/to/moodledata
}

moodleConfiguration(){
	echo ".......................................Configuring moodle......................................."
	CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
	cp $CURRENT_DIR/config.php /var/www/$moodleInstance/
	chmod 775 /var/www/$moodleInstance/config.php

	sed -i 's|.*$CFG->dbname    = \x27moodle\x27;.*|$CFG->dbname    = \x27moodle_'$MoodleVersion'\x27;|g' /var/www/$moodleInstance/config.php
	sed -i 's|.*$CFG->wwwroot   = \x27http://localhost/moodle\x27;.*|$CFG->wwwroot   = \x27http://'$moodle_ip':8000/'$moodleInstance'\x27;|g' /var/www/$moodleInstance/config.php
	sed -i 's|.*$CFG->dataroot  = \x27/home/adi/moodledata\x27;.*|$CFG->dataroot   = \x27/home/'$USER'/MooodleData/moodledata_'$MoodleVersion'\x27;|g' /var/www/$moodleInstance/config.php
	#sed -i 's|.*$CFG->dataroot  = \x27/home/$USER/moodledata\x27;.*|$CFG->wwwroot   = \x27/home/$USER/moodle/moodledata/moodledata_'$MoodleVersion'\x27;|g' /var/www/$moodleInstance/config.php

}

moodleInstall(){
	echo "................................final moodle installation steps................................"
	/usr/bin/php /var/www/$moodleInstance/admin/cli/install_database.php --agree-license --adminpass=MOODLE_admin_121 
	/usr/bin/php /var/www/$moodleInstance/admin/cli/cron.php >/dev/null
}

apacheConfiguration() {
	echo ".......................................configuring apache2......................................."

	 if ! grep -q "Alias /$moodleInstance /var/www/$moodleInstance" /etc/apache2/sites-available/000-default.conf;
        then
                sed -i "/\<ServerName[[:space:]]localhost\>/a 	\        Alias /$moodleInstance /var/www/$moodleInstance\\
                <Directory /var/www/> \\
                Options Indexes FollowSymLinks MultiViews\\
                AllowOverride All\\
                Order allow,deny\\
                allow from all\\
                </Directory>\\" /etc/apache2/sites-available/000-default.conf
        fi
    echo "now we here"
    if grep -q "Alias /$moodleInstance /var/www/$moodleInstance" /etc/apache2/sites-available/000-default.conf;		
     	then 
     			sed -i 's|\\||g' /etc/apache2/sites-available/000-default.conf
		fi
	service apache2 restart	
}

while getopts ":u:v:t:m:i:" i; do
    case "${i}" in
        u) USER=${OPTARG}
        ;;
		v) MoodleVersion=${OPTARG}
		;;
        t) MoodleGitTag=${OPTARG}
		;;
		m) moodleInstance=${OPTARG}
		;;
		i) moodle_ip=${OPTARG}
    esac
done

shift $((OPTIND - 1))

if [[ $USER == "" || $MoodleVersion == "" || $MoodleGitTag == "" || $moodleInstance == "" || $moodle_ip = "" ]]; then
        usage
fi

#..........................................function calls...................................

installMoodleCode

moodleDBsettings

createMoodleHome

moodleConfiguration

moodleInstall

apacheConfiguration
