#!/bin/bash

# Set variables
BIGIP_IP="${TF_VAR_bigip_dns}"
URL="https://${TF_VAR_bigip_dns}/mgmt/tm/cm/add-to-trust"
USER="${TF_VAR_username}"
PASS="${TF_VAR_password}"
AUTH="$USER:$PASS"
IP="${TF_VAR_device_ip}"
REMOTE_IP="${TF_VAR_device_ip_remote}"

echo "Sending API to create Trust Domain and Device Group for Sync-Failover"

data_txt="{\"command\":\"run\",\"caDevice\":true,\"device\":\"${REMOTE_IP}\",\"deviceName\":\"${REMOTE_IP}\",\"username\":\"${USER}\",\"password\":\"${PASS}\"}"

response=$(curl -ks \
  --output trust-domain.json \
  --write-out "%{http_code}" \
  --header "Content-Type: application/json" \
  -u "$AUTH" \
  --request POST "$URL" \
  --data "$data_txt")

echo "HTTP_CODE=$response"

if [[ $response != 200 ]]; then
  echo "ERROR - ${HTTP_CODE}"
  echo "Adding to Trust Domain Failed"
  cat "trust-domain.json"
  exit 1
else
  echo "Device added to Trust Domain successfully."
fi

sleep 5 
echo "Waiting for 5 seconds before creating Device Group and Syncing"

URL="https://${TF_VAR_bigip_dns}/mgmt/tm/cm/device-group"

echo "Sending API to create Device Group for Sync-Failover"
echo $URL


data_txt="{\"name\":\"SyncDeviceGroup\",\"type\":\"sync-failover\",\"autoSync\":\"enabled\",\"devices\":[\"${REMOTE_IP}\",\"${IP}\"]}"


response=$(curl -ks \
  --output device-group.json \
  --write-out "%{http_code}" \
  --header "Content-Type: application/json" \
  -u "$AUTH" \
  --request POST "$URL" \
  --data "$data_txt")


echo "HTTP_CODE=$response"


if [[ $response != 200 ]]; then
  echo "ERROR - ${HTTP_CODE}"
  echo "Adding to Device Group  Failed"
  cat "device-group.json"
  exit 1
else
  echo "Device added to Device Group successfully."
fi


sleep 5
echo "Waiting for 5 seconds before syncing devices"

URL="https://${TF_VAR_bigip_dns}/mgmt/tm/cm/config-sync"

echo "Sending API to Config Sync"
echo $URL


data_txt="{\"command\":\"run\",\"options\":[{\"to-group\":\"SyncDeviceGroup\"}]}"

response=$(curl -ks \
  --output device-group.json \
  --write-out "%{http_code}" \
  --header "Content-Type: application/json" \
  -u "$AUTH" \
  --request POST "$URL" \
  --data "$data_txt")


echo "HTTP_CODE=$response"


if [[ $response != 200 ]]; then
  echo "ERROR - ${HTTP_CODE}"
  echo "Syncing Failed"
  cat "syncing.json"
  exit 1
else
  echo "Devices synced successfully."
fi




