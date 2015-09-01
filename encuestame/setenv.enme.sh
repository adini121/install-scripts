#! /bin/sh
export CATALINA_OPTS="-Dencuestame.home=/home/nisal/encuestame/encuestame_home/enme1.5.0"
JAVA_OPTS="$JAVA_OPTS -Dorg.apache.el.parser.SKIP_IDENTIFIER_CHECK=true"
export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-amd64
