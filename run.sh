#!/bin/bash

if [ "$#" -eq "0" ]; then
  echo "Invalid cli arguments. ERR #1"
  exit 1
fi

while [[ "$#" > "0" ]]
do
  case $1 in
    (*=*) eval $1;;
  esac
shift
done

if [ -z "$PX_API_KEY" ] || [ -z "$PX_CLUSTER_NAME" ]
then
  echo "Invalid cli arguments. ERR #2"
  exit 1
fi

echo "checking kube api connectivity"
#if ! kubectl cluster-info; then
#    echo "Unable to connect to kube api. ERR #3"
#    exit 1
#else
#    echo "kube api reachable"
#fi


echo "checking helm binary"
if ! helm version; then
    echo "helm not available. ERR #4"
    exit 1
else
    echo "helm binary found."
fi


echo "checking jq command"
if ! jq --help; then
    echo "jq not available. ERR #5"
    exit 1
else
    echo "jq binary found."
fi

echo "fetching cluster_key"
cluster_key=$(curl -s "http://api.avinpx07.getanton.com/v1/p/auth/login?apikey=$PX_API_KEY&clusterName=$PX_CLUSTER_NAME" | jq -r '.payload.operatorAuth.cluster_key')

if [ -z "$cluster_key" ]
then
  echo "cluster_key Error. ERR #6"
  exit 1
fi

helm dependency update helm-charts
 helm --install  \
 --set=image.tag=latest \
 upgrade $APP_NAME \
  -f ./helm-charts/$ENV.yaml ./helm-charts/ \
  --create-namespace \
  --namespace zerok-cli 