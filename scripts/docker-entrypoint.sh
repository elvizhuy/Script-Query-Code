#!/bin/bash
set -e

sudo rm -fr /tmp && sudo mkdir /tmp && sudo chmod a+trwx /tmp

cd ~/services

binary_file=app.jar

if [ ! -f ${binary_file} ]; then
    echo Not found binary file
    exit 1
fi

sudo chown ${USER:=$(/usr/bin/id -run)}:${USER} ${binary_file}
sudo chown ${USER}:${USER} app.conf
sudo chown ${USER}:${USER} files
sudo chown ${USER}:${USER} log

if [ -f app.conf ]; then
    . app.conf
    config_uri=$(grep -o '\-Dspring\.cloud\.config\.uri=[^ "]*' app.conf | sed 's/-Dspring.cloud.config.uri=//')
fi


if [ -n "$config_uri" ]; then
	MAX_RETRIES=10
	retry_count=0

	while true; do
	    http_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 -f ${config_uri}/login ||:)

	    if [ $http_code -eq 200 ]; then
	        echo "Request config server $config_uri succeeded"
	        break
	    else
	        echo "Request config server: $config_uri failed with HTTP status code $http_code, retrying..."
	        sleep 5
	    fi

	    retry_count=$((retry_count+1))

	    if [ $retry_count -eq $MAX_RETRIES ]; then
	        echo "Maximum number of retries request config server: $config_uri reached, exiting..."
	        exit 1
	    fi
	done
else
	echo Config server uri is null, ignore to verify
fi

if [ -n "${APP_NAME}" ]; then
	cp ${binary_file} ${APP_NAME}.jar
	binary_file=${APP_NAME}.jar
fi

export JAVA_HOME="/opt/java/jdk1.8"

for cacert in ~/services/files/private/cacerts/*
do
	if [ -f "${cacert}" ];then
    	echo Add cacert: ${cacert}
		alias=$(basename -- "$cacert")
		alias="${alias%.*}"
	
		sudo $JAVA_HOME/bin/keytool -import -storepass changeit -noprompt -alias "${alias}" -keystore $JAVA_HOME/jre/lib/security/cacerts -file ${cacert} || true
  	fi
	
done

chmod +x ${binary_file}
eval "java ${JAVA_OPTS} -jar ${binary_file}"