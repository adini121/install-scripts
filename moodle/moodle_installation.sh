#! /bin/bash

# Description: Deployment script for jenkins, takes as input : User, Jenkins version, Tomcat Port on which Jenkins will run
# Author: $USERtya
# ChangeLog: added createJenkinsHome() function - Aug 13
# Date: 11.08.15

echo "running script for creating multiple tomcat instances under the home directory"
usage(){
        echo "Usage: $0 <OPTIONS>"
        echo "Required options:"
        echo "  -u $USER               user name"
        echo "  -v <MoodleVersion>     Moodle version for database and moodle home (eg 270, 281 etc)"
        echo "  -t <MoodleGitTag>      Moodle git tag eg: v2.7.1, v2.7.0"
        echo "  -m <moodleInstance>    Eg moodle_second, moodle_third"
        exit 1
}
# $MoodleGitTag: git tag to checkout 
# $MoodleVersion : A plain number, such as 222
# $USER 
# $moodleInstance : moodle or moodle_second

installMoodleCode(){
	cd /var/www/
		if [ ! -d /var/www/$moodleInstance ]; then
			git clone git://git.moodle.org/moodle.git $moodleInstance
		fi
 
	cd /var/www/$moodleInstance
	git pull
	git checkout tag $MoodleGitTag
}

moodleDBsettings(){
	mysql -u root << EOF
	CREATE DATABASE moodle_$MoodleVersion DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
	GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,CREATE TEMPORARY TABLES,DROP,INDEX,ALTER ON moodle_$MoodleVersion.* TO ‘moodleuser’@’localhost’ IDENTIFIED BY 'moodlepassword';
	EOF
}

createMoodleHome(){
	mkdir /home/$USER/moodle/moodledata/moodledata_$MoodleVersion
	chmod 0777 /home/$USER/moodle/moodledata/moodledata_$MoodleVersion

# chmod -R +a "www-admin allow read,delete,write,append,file_inherit,directory_inherit" /path/to/moodledata
}

moodleConfiguration(){
	cp /home/$USER/moodle/config.php /var/www/moodle/
	chmod 755 /var/www/moodle/config.php

	sed -i 's|.*$CFG->dbname    = \x27moodle\x27;.*|$CFG->dbname    = \x27moodle_$MoodleVersion\x27;|g' /var/www/$moodleInstance/config.php
	sed -i 's|.*$CFG->wwwroot   = \x27http://localhost/moodle\x27;.*|$CFG->wwwroot   = \x27http://localhost/moodle_$MoodleVersion\x27;|g' /var/www/$moodleInstance/config.php
	sed -i 's|.*$CFG->dataroot  = \x27/home/$USER/moodledata\x27;.*|$CFG->wwwroot   = \x27/home/$USER/moodle/moodledata/moodledata_$MoodleVersion\x27;|g' /var/www/$moodleInstance/config.php
}

moodleInstall(){
	/usr/bin/php /var/www/$moodleInstance/admin/cli/install_database.php --adminpass=admin --agree-license 
	/usr/bin/php /var/www/$moodleInstance/admin/cli/cron.php >/dev/null
}

apacheConfiguration() {
	if 	grep -q 'Alias /'$moodleInstance' /var/www/'$moodleInstance'' /etc/apache2/sites-available/000-default.conf;
	then
		sed -i '/ServerName localhost/r /home/'$USER'/moodle/add.txt' /etc/apache2/sites-available/000-default.conf 
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

