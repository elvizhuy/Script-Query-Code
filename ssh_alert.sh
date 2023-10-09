#!/bin/bash

USERID="-815609975"
TOKEN="6588801252:AAFJD4d1WW0L36mS_HfRlzTBIy3B7KJkIvc"
TIMEOUT="10"

URL="https://api.telegram.org/bot$TOKEN/sendMessage"
DATE_EXEC="$(date "+%d %b %Y %H:%M")"
HOST_NAME=`hostnamectl | grep "Static hostname" | awk -F ": " '{print $2}'`

IP=$(echo $SSH_CLIENT | awk '{print $1}')
PORT=$(echo $SSH_CLIENT | awk '{print $3}')
HOSTNAME=$(hostname -f)
IPADDR=$(hostname -I | awk '{print $1}')
TMPFILE='/tmp/ipinfo-$DATE_EXEC.txt'
TEXT="$DATE_EXEC: ${USER} logged in to $HOSTNAME ($IPADDR) from $IP - $ORG - $CITY, $REGION, $COUNTRY on port $PORT"


if [ -n "$SSH_CLIENT" ]; then
	curl http://ipinfo.io/$IP -s -o $TMPFILE
	CITY=$(cat $TMPFILE | jq '.city' | sed 's/"//g')
	REGION=$(cat $TMPFILE | jq '.region' | sed 's/"//g')
	COUNTRY=$(cat $TMPFILE | jq '.country' | sed 's/"//g')
	ORG=$(cat $TMPFILE | jq '.org' | sed 's/"//g')
	curl -s --max-time $TIMEOUT -d "chat_id=$USERID&disable_web_page_preview=1&text=$TEXT" $URL > /dev/null
	rm $TMPFILE
fi

if [[ ${USER} != 'ucmea']]; then
	curl -s -X POST --max-time $TIMEOUT $URL -d "chat_id=$USERID" -d text="$TEXT" > /dev/null 
fi