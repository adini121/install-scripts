#! /bin/bash

# Description: Deployment script for Moodle, takes as input : User, Moodle version (without spl chars), Git tag, Moodle instance name
# Author: Aditya
# ChangeLog: 
# Date: 1.09.15

usage(){
        echo "Usage: $0 <OPTIONS>"
        echo "Required options:"
        echo "  -u $USER               user name"
        echo "  -v <MoodleVersion>     Moodle version for database and moodle home (eg 270, 281 etc)"
        echo "  -t <MoodleGitTag>      Moodle git tag eg: v2.7.1, v2.7.0"
        echo "  -m <moodleInstance>    Eg moodle_second, moodle_third"
        exit 1
}

installMoodleCode(){
	echo "................................installing moodle code......................................."
	cd /var/www/
		if [ ! -d /var/www/$moodleInstance ]; then
			git clone git://git.moodle.org/moodle.git $moodleInstance
		fi
 
	cd /var/www/$moodleInstance
	git pull
	git checkout $MoodleGitTag
}

moodleDBsettings(){
	echo "................................moodle database settings......................................."
	mysql -u root << EOF
	CREATE DATABASE IF NOT EXISTS moodle_$MoodleVersion DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
	GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,CREATE TEMPORARY TABLES,DROP,INDEX,ALTER ON moodle_$MoodleVersion.* TO 'moodleuser'@'localhost' IDENTIFIED BY 'moodlepassword';
EOF
}

createMoodleHome(){
	echo "................................Creating moodledata home directory................................"
	if [ ! -d /home/$USER/moodledata_$MoodleVersion ]; then
			mkdir /home/$USER/moodledata_$MoodleVersion
		fi

	chmod 0777 /home/$USER/moodledata_$MoodleVersion

	#mkdir /home/$USER/moodle/moodledata/moodledata_$MoodleVersion
	#chmod 0777 /home/$USER/moodle/moodledata/moodledata_$MoodleVersion

# chmod -R +a "www-admin allow read,delete,write,append,file_inherit,directory_inherit" /path/to/moodledata
}

moodleConfiguration(){
	echo ".......................................Configuring moodle......................................."
	if [ ! -f /var/www/$moodleInstance/config.php ]; then
			cp /home/$USER/config.php /var/www/$moodleInstance/
		fi
	
	#cp /home/$USER/moodle/config.php /var/www/moodle/

	chmod 775 /var/www/$moodleInstance/config.php

	sed -i 's|.*$CFG->dbname    = \x27moodle\x27;.*|$CFG->dbname    = \x27moodle_'$MoodleVersion'\x27;|g' /var/www/$moodleInstance/config.php
	sed -i 's|.*$CFG->wwwroot   = \x27http://localhost/moodle\x27;.*|$CFG->wwwroot   = \x27http://localhost/moodle_'$moodleInstance'\x27;|g' /var/www/$moodleInstance/config.php
	sed -i 's|.*$CFG->dataroot  = \x27/home/adi/moodledata\x27;.*|$CFG->dataroot   = \x27/home/'$USER'/moodledata_'$MoodleVersion'\x27;|g' /var/www/$moodleInstance/config.php
	#sed -i 's|.*$CFG->dataroot  = \x27/home/$USER/moodledata\x27;.*|$CFG->wwwroot   = \x27/home/$USER/moodle/moodledata/moodledata_'$MoodleVersion'\x27;|g' /var/www/$moodleInstance/config.php

}

moodleInstall(){
	echo "................................final moodle installation steps................................"
	sudo /usr/bin/php /var/www/$moodleInstance/admin/cli/install_database.php --adminpass=MOODLE_ADMIN_121 --agree-license 
	sudo /usr/bin/php /var/www/$moodleInstance/admin/cli/cron.php >/dev/null
}

apacheConfiguration() {
	echo ".......................................configuring apache2......................................."
		# ALIASES=$(cat <<EOF
		# Alias /$(moodleInstance) /var/www/$(moodleInstance)
  #       <Directory /var/www/>
  #           Options Indexes FollowSymLinks MultiViews
  #           AllowOverride All
  #           Order allow,deny
  #           allow from all
  #       </Directory>

# EOF
# )
	# if 	[ ! grep -q 'Alias /$moodleInstance /var/www/$moodleInstance' /etc/apache2/sites-available/000-default.conf ];
	# then
	# 	sudo sed -i '/ServerName localhost/r '$ALIASES'' /etc/apache2/sites-available/000-default.conf 
	# fi
	
	 if ! grep -q 'Alias /$moodleInstance /var/www/$moodleInstance' /etc/apache2/sites-available/000-default.conf;
        then
                sudo sed -i "/\<ServerName[[:space:]]localhost\>/a 		Alias /$moodleInstance /var/www/$moodleInstance \\
                <Directory /var/www/>\\
                Options Indexes FollowSymLinks MultiViews\\
                AllowOverride All\\
                Order allow,deny\\
                allow from all\\
                </Directory>\\" /etc/apache2/sites-available/000-default.conf
        fi

}

while getopts ":u:v:t:m:" i; do
    case "${i}" in
        u) USER=${OPTARG}
        ;;
		v) MoodleVersion=${OPTARG}
		;;
        t) MoodleGitTag=${OPTARG}
		;;
		m) moodleInstance=${OPTARG}
    esac
done

shift $((OPTIND - 1))

if [[ $USER == "" || $MoodleVersion == "" || $MoodleGitTag == "" || $moodleInstance == "" ]]; then
        usage
fi

#..........................................function calls...................................

installMoodleCode

moodleDBsettings

createMoodleHome

moodleConfiguration

moodleInstall

apacheConfiguration
