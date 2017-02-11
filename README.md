### LinuxAcademy Lab Setup
These scripts automate the first steps that must be executed for every new LinuxAcademy lab server which are:    
- Login with the default user
- Change the default user's password
- Login as root
- Change root's password
- Create a new user that's not the default user
- Set the new user's password
- Delete the default user

### Usage
The new lab script takes the lab ip address, the username to use, and a nickname for the lab server. The nickname given will be used later for logging in.   
`./newlab.sh "lab ip" "new username" "a name for the lab server"`

Then login by passing the username and nickname to loginlab    
`./loginlab "username" "labserver name"`

### Requirements
expect   
sshpass   
nmap

### Warnings
These scripts are inherently insecure and shouldn't be used for any non-dev servers. There are serious risks involved with passing passwords as command line arguments (passwords are exposed by ps) as well as storing passwords in flatfiles. 
