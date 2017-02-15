#!/bin/bash

function executeOnServer() {
	ip="$1"
	user="$2"
	pass="$3"
	cmd="$4"
	sshpass -p"$pass" ssh $user@$ip "$cmd"
}

function randomPassword() {
	cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c "$1"
}

function genPasswords() {
	pass_user=`randomPassword 10`
	pass_root=`randomPassword 10`
	pass_newuser=`randomPassword 10`
	echo "$pass_user" > "$labPassDir/$servername-user.tmp"
	echo "$pass_root" > "$labPassDir/$servername-root"
	echo "$pass_newuser" > "$labPassDir/$servername-$user"
}

function setServerName() {
	if [ -z "$servername" ]; then servername="default"; fi
	serverfile=`cat $labPassDir/servers` 2> /dev/null
	serverfile=`echo -e "$serverfile" | grep -v " $servername$"` # Overwrites server name if it exists
	serverfile=`echo -e "$serverfile\n$ip $servername"`
	echo -e "$serverfile" > $labPassDir/servers 
}

function testThatUserWasCreated() {
	testLogin=`executeOnServer "$ip" "$user" "$pass_newuser" "whoami"`
	if [[ $testLogin == "$user" ]]; then 
			echo $?
	else
		echo $?
	fi
}

function setupEnv() {
	ip="$1"
	user="$2"
	servername="$3"
	labPassDir="$HOME/.labauth"
	errorFile="$labPassDir/errors.log"
	if [ ! -d "$labPassDir" ]; then mkdir "$labPassDir"; fi 

	ssh-keygen -R "$ip" > /dev/null 2> /dev/null
	ssh-keyscan -H "$ip" >> ~/.ssh/known_hosts 2> /dev/null
}

function isServerUp() {
	resp=`nmap -p22 "$ip" 2> /dev/null | grep open`
	if [ -n "$resp" ]; then
		echo $?
	else
		echo $?
	fi
}

function waitForServer() {
	stopwatch=`date +%s`
	while [[ `isServerUp` -eq 1 ]]; do
		newtime=`date +%s`  
		echo -ne "Waiting for server... $((newtime-stopwatch))\r"
		sleep 5
	done
	export -f executeOnServer
	until ((exitStatus==124)); do # timeout will return exit status of 124 on failure because of timeout but 255 on failure because of hostname not found
		echo "Checking that the service is responding to our SSH request"  # This will at least tell us that the server is up and responding to SSH requests
		noTTYConnection=`timeout 3 bash -c "executeOnServer $ip user 123456 2> /dev/null"`
		exitStatus=$?
		sleep 1
	done
	echo -e "\nLooks like server is up"
}

function newlab() {
	setupEnv "$@"
	waitForServer
	genPasswords
	echo "Starting the script"
	./login-and-change-passwd.exp \
		"user" "123456" "user@$ip" "$pass_user" \
		"$pass_root" "$user" "$pass_newuser"  > /dev/null 2> $errorFile

	echo "root: $pass_root"
	echo "$user: $pass_newuser"
	echo "Checking if user was successfully created..."
	if [[ `testThatUserWasCreated` -eq 0 ]]; then 
		echo "User successfully created"
		setServerName
	else
		echo "Failed! Perhaps check the error file: $errorFile"
	fi
}

newlab "$@"
