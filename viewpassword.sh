#!/bin/bash
user="$1"
servername="$2"

labPassDir="$HOME/.labauth"
cat $labPassDir/$servername-$user

