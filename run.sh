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

if [ -z "$PX_API_KEY" ] || [ -z "$PX_CLUSTER_NAME" ] || [ -z "$PX_DEPLOYMENT_KEY" ] || [ -z "$PX_CLOUD_CLUSTER" ]
then
  echo "Invalid cli arguments. ERR #2"
  exit 1
fi

#echo "checking kube api connectivity"
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
cluster_key=$(curl --insecure -s "https://api.$PX_CLOUD_CLUSTER.getanton.com/v1/p/auth/login?apikey=$PX_API_KEY&clusterName=$PX_CLUSTER_NAME" | jq -r '.payload.operatorAuth.cluster_key')

if [ -z "$cluster_key" ]
then
  echo "cluster_key Error. ERR #6"
  exit 1
fi
echo "cluster_key $cluster_key"
echo "PX_DEPLOYMENT_KEY $PX_DEPLOYMENT_KEY"
echo "PX_API_KEY $PX_API_KEY"

echo "installing zk-client"
helm repo add zk-client https://helm.zerok.ai/zk-client
helm repo update
helm --install  --set=global.data.cluster_key=$cluster_key --set=global.data.PX_API_KEY=$PX_API_KEY upgrade $APP_NAME zk-client/zk-operator --create-namespace --namespace zk-client 
echo "installing pixie"
helm repo add pixie-operator https://pixie-operator-charts.storage.googleapis.com
# Get latest information about Pixie chart.
helm repo update
helm --install --set=deployKey=$PX_DEPLOYMENT_KEY --set=clusterName=$PX_CLUSTER_NAME  upgrade pixie pixie-operator/pixie-operator-chart  --namespace pl --create-namespace

