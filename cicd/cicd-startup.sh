#!/bin/bash
NAMESPACE=$1
HELM_RELEASE=$2
AWS_ACCESS_KEY=$3
AWS_SECRET_KEY=$4
GITHUB_USER=$5
GITHUB_PASS=$6
IMAGE_REPO=$7
GITHUB_APP=$8
GITHUB_MICRO=$9
AWS_REGION=$10

mv credentials.xml credentials-tmp.xml
cat credentials-tmp.xml | sed "s|{{AWS_ACCESS_KEY}}|$AWS_ACCESS_KEY|g; \
                               s|{{AWS_SECRET_KEY}}|$AWS_SECRET_KEY|g; \
                               s|{{GITHUB_USER}}|$GITHUB_USER|g; \
                               s|{{GITHUB_PASS}}|$GITHUB_PASS|g" > credentials.xml
kubectl -n $NAMESPACE create secret generic $HELM_RELEASE-jenkins-creds --from-file=credentials.xml
mv credentials-tmp.xml credentials.xml

kubectl -n $NAMESPACE apply -f ./maven-pod-pvc.yaml

mv values.yaml values-tmp.yaml
cat values-tmp.yaml | sed "s|{{IMAGE_REPO}}|$IMAGE_REPO|g; \
                           s|{{GITHUB_APP}}|$GITHUB_APP|g; \
                           s|{{GITHUB_MICRO}}|$GITHUB_MICRO|g; \
                           s|{{AWS_REGION}}|$AWS_REGION|g" > values.yaml

helm install --namespace $NAMESPACE --name $HELM_RELEASE-jenkins stable/jenkins --version 1.5.1 -f values.yaml \
--set master.servicePort=80 \
--set master.installPlugins[0]=kubernetes:1.21.3 \
--set master.installPlugins[1]=workflow-job:2.33 \
--set master.installPlugins[2]=workflow-aggregator:2.6 \
--set master.installPlugins[3]=credentials-binding:1.19 \
--set master.installPlugins[4]=git:3.11.0 \
--set master.installPlugins[5]=amazon-ecr:1.6 \
--set master.installPlugins[6]=htmlpublisher:1.18 \
--set master.installPlugins[7]=github-oauth:0.33 \
--set master.credentialsXmlSecret=$HELM_RELEASE-jenkins-creds

mv values-tmp.yaml values.yaml

helm install --namespace $NAMESPACE --name $HELM_RELEASE stable/sonarqube --version 2.1.4 \
--set service.externalPort=80 \
--set plugins.install[0]="https://binaries.sonarsource.com/Distribution/sonar-html-plugin/sonar-html-plugin-3.1.0.1615.jar" \
--set plugins.install[1]="https://binaries.sonarsource.com/Distribution/sonar-java-plugin/sonar-java-plugin-5.14.0.18788.jar" \
--set plugins.install[2]="https://binaries.sonarsource.com/Distribution/sonar-javascript-plugin/sonar-javascript-plugin-5.2.1.7778.jar" \
--set plugins.install[3]="https://binaries.sonarsource.com/Distribution/sonar-typescript-plugin/sonar-typescript-plugin-1.9.0.3766.jar" \
--set plugins.install[4]="https://binaries.sonarsource.com/Distribution/sonar-jacoco-plugin/sonar-jacoco-plugin-1.0.2.475.jar"

echo "Jenkins Info"
JENKINS_URL=$(kubectl -n $NAMESPACE get svc $HELM_RELEASE-jenkins -o json | grep hostname | sed 's|.*: \(.*\)|\1|;s/"//g')
for i in {1..10}
do
  if [ -z $JENKINS_URL ]; then
    sleep 5
    JENKINS_URL=$(kubectl -n $NAMESPACE get svc $HELM_RELEASE-jenkins -o json | grep hostname | sed 's|.*: \(.*\)|\1|;s/"//g')
    echo "Loop $i of 10, waited $(expr $i \* 5) seconds for ELB"
  else
    break
  fi
done
echo "${JENKINS_URL}"
JENKINS_PASS=$(kubectl -n $NAMESPACE get secret $HELM_RELEASE-jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode)
echo "admin"
echo "$JENKINS_PASS"

echo "SonarQube Info"
SONAR_URL=$(kubectl -n $NAMESPACE get svc $HELM_RELEASE-sonarqube -o json | grep hostname | sed 's|.*: \(.*\)|\1|;s/"//g')
for i in {1..10}
do
  if [ -z $SONAR_URL ]; then
    sleep 5
    SONAR_URL=$(kubectl -n $NAMESPACE get svc $HELM_RELEASE-sonarqube -o json | grep hostname | sed 's|.*: \(.*\)|\1|;s/"//g')
    echo "Loop $i of 10, waited $(expr $i \* 5) seconds for ELB"
  else
    break
  fi
done
echo "${SONAR_URL}"
echo "admin"
echo "admin"
