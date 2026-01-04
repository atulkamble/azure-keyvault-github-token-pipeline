RG=myKVRG
LOC=eastus
KVNAME=kvatultest597690bjbkbk

az group create -n $RG -l $LOC

az keyvault create \
 -n $KVNAME \
 -g $RG
 -l $LOC
 --enable-rbac-authorization true
