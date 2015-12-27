#!/bin/bash

declare -a arr=( "1.582" "1.584" "1.586" "1.588" "1.590" "1.592" "1.594" "1.598" "1.600" "1.602" "1.604" "1.606" "1.611" "1.613" "1.615" "1.617" "1.619" "1.621" "1.623" "1.627" "1.629" "1.631" "1.633" "1.635" "1.637" "1.640")

## now loop through the above array
for JenkinsVersion in "${arr[@]}"
do
   	if [ ! -f  /home/nisal/JenkinsWarFiles/jenkins"$JenkinsVersion".war ]; then
	wget https://updates.jenkins-ci.org/download/war/$JenkinsVersion/jenkins.war -O /home/nisal/JenkinsWarFiles/jenkins"$JenkinsVersion".war
	fi
   echo "$JenkinsVersion"
done
