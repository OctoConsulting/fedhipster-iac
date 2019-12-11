#!/bin/bash
NAMESPACE=$1
HELM_RELEASE=$2

kubectl -n $NAMESPACE delete secret $HELM_RELEASE-jenkins-creds
helm del --purge $HELM_RELEASE-jenkins
helm del --purge $HELM_RELEASE
