#! /bin/bash
if curl -Is http://134.96.235.47:8001 | head -1 | grep "200 OK"; then
	true
else	
	/home/nisal/tomcat/TomcatInstance8001/bin/startup.sh
	sleep 5
	curl --url "smtps://smtp.gmail.com:465" --ssl-reqd --mail-from "adamsken1221@gmail.com" \
	--mail-rcpt "adityanisal@googlemail.com" --upload-file /home/nisal/email_8001.txt --user \
	"adamsken1221@gmail.com:adsad1221" --insecure
fi