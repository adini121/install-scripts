# /bin/sh

#Installation script for Encuestame Web app
$user
$version #git tag
$dbname

##grant privileges
mysql -u root;
grant all privileges on $dbname.* to 'encuestame'@'localhost' identified by 'encuestame';
flush privileges;

mkdir /home/$user/encuestame
cd /home/$user/encuestame
git clone --recursive https://github.com/encuestame/encuestame.git
cd /home/$user/encuestame/encuestame
git submodule update --init
git checkout $version # example : 1.5.0 (tag)
export MAVEN_OPTS="-Xmx1024M"
mvn clean install 
mkdir /home/$user/encuestame/enme_home
mkdir /home/$user/encuestame/enme_home/enme_VERSION
cp /home/$user/scripts/install-scripts/encuestame-config.xml /home/$user/encuestame/enme_home/enme_$version
## open encuestame-config.xml and CHANGE the version in XML file to $version

mysql -u root
CREATE USER 'encuestame'@'localhost' identified by 'encuestame';
grant all privileges on $dbname.* to 'encuestame'@'localhost' identified by 'encuestame';
create database $dbname #eg enme_150
grant all privileges on enme_152.* to 'encuestame'@'localhost' identified by 'encuestame';
 
cp /repository-home/server.enme.xml /home/$user/tomcat/TomcatInstanceXXXX/conf/server.xml 
#### cp /repository-home/setenv.enme.sh /home/adi/tomcat/TomcatInstance8083/bin/setenv.sh
cp /repository-home/encuestame-config.xml /home/adi/encuestame/enme_home/enme_1.5.0/

sed EDIt the version field of config file

cp /encuestame/encuestame/enme-war/web-app/tomcat-webapp/target/encuestame.war /home/adi/tomcat/TomcatInstance8085/webapps/encuestame152.war

# sleep until WAR file is unpacked
#copy config file 
cp ~/scripts/encuestame-config-custom.properties /home/adi/tomcat/TomcatInstance8085/webapps/encuestame152/WEB-INF/classes/

#copy database connectors mysql 
 cp /home/adi/tomcat/TomcatInstance8083/webapps/encuestame150/WEB-INF/lib/mysql-connector-java-5.1.13.jar /home/adi/tomcat/TomcatInstance8083/lib/


#sed change encuestame home

sed ..command .. /REPLACE/encuestame.home=/home/adi/encuestame/enme_home/enme_1.5.0/  path=/home/adi/tomcat/TomcatInstance8083/webapps/encuestame150/WEB-INF/classes/

WITHOUT #ised JUST COMMENT ALL POSTGRES AND HSQL PREEMTIVELY






