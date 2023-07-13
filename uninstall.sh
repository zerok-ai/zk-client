#!/bin/bash

kubectl delete namespace zk-client --grace-period=0 --force
kubectl delete namespace pl --grace-period=0 --force
kubectl delete namespace olm --grace-period=0 --force
kubectl delete namespace px-operator --grace-period=0 --force
kubectl delete crd zerokops.operator.zerok.ai --cascade=false --force
