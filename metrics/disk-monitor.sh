#!/bin/bash

get_usage() {
  device=${1}
  usage=$(df -h | grep ${device} | awk '{print $5}')
  echo "${usage//%}"
}

collect_metrics() {
  rootUsage=$(get_usage "/dev/root")
  sda2Usage=$(get_usage "/dev/sda2")
  echo "{\"metrics\":[{\"/dev/root\":\"${rootUsage}\"},{\"/dev/sda2\":\"${sda2Usage}\"}]}"
}

send_metrics() {
  metrics=${1}
  curl --header "Content-Type: application/json" \
       --header "x-api-key: ${API_KEY}" \
       --request POST \
       --data $metrics \
       ${API_URL}
}

send_metrics $(collect_metrics)
