#!/bin/bash

function executeOnServer() {
	ip="$1"
	user="$2"
	pass="$3"
	cmd="$4"
	sshpass -p"$pass" ssh $user@$ip "$cmd"
}

function genPasswords() {
	pass_user=`passwordgen.sh -l=10`
	pass_root=`passwordgen.sh -l=10`
	pass_newuser=`passwordgen.sh -l=10`
	echo "$pass_user" > $labPassDir/user.tmp
	echo "$pass_root" > $labPassDir/root
	echo "$pass_newuser" > $labPassDir/$user

	echo "user: $pass_user"
	echo "root: $pass_root"
	echo "$user: $pass_newuser"
}

ip="$1"
user="$2"
servername="$3"
labPassDir="labauth"

if [ -z "$servername" ]; then servername="server01"; fi
if [ ! -d "$labPassDir" ]; then mkdir "$labPassDir"; fi 
ssh-keygen -R "$ip"
ssh-keyscan -H "$ip" >> ~/.ssh/known_hosts
genPasswords
./login-and-change-passwd.exp "user" "123456" "user@$ip" "$pass_user" \
							"$pass_root" "$user" "$pass_newuser"
testLogin=`executeOnServer "$ip" "$user" "$pass_newuser" "whoami"`
echo "\n\n Checking if user was successfully created..."

if [[ $testLogin == "$user" ]]; then 
		echo "User successfully created"
		echo "$ip $servername" >> $labPassDir/servers
else
		echo "Failed!"
fi

