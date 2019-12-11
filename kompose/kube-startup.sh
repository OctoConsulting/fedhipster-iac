NAMESPACE=$1
DEFAULT_REGION=$2
IMAGE_APP=$3
IMAGE_MICRO=$4

#keycloak
kubectl -n $NAMESPACE create configmap keycloak-map --from-file realm-config
kubectl -n $NAMESPACE apply -f keycloak-deployment.yaml -f keycloak-service.yaml

#elasticsearch
#kubectl -n $NAMESPACE apply -f postgresql-deployment.yaml -f postgresql-service.yaml

#postgresql
#kubectl -n $NAMESPACE apply -f elasticsearch-deployment.yaml -f elasticsearch-service.yaml

#jhipster-registry
KEYCLOAK_URL=$(kubectl -n $NAMESPACE get svc/keycloak -o json | grep hostname | sed 's|.*: \(.*\)|\1|;s/"//g')
for i in {1..50}
do
  if [ -z $KEYCLOAK_URL ]; then
    sleep 5
    KEYCLOAK_URL=$(kubectl -n $NAMESPACE get svc/keycloak -o json | grep hostname | sed 's|.*: \(.*\)|\1|;s/"//g')
    echo "Loop $i of 50, waited $(expr $i \* 5) seconds for ELB"
  else
    break
  fi
done
echo ${KEYCLOAK_URL}
kubectl -n $NAMESPACE apply -f jhipster-registry-claim0-persistentvolumeclaim.yaml
cat jhipster-registry-deployment.yaml | sed "s/{{KEYCLOAK_URL}}/$KEYCLOAK_URL/g" | kubectl -n $NAMESPACE apply -f -
kubectl -n $NAMESPACE apply -f jhipster-registry-service.yaml

#app deployment
cat app-deployment.yaml | sed "s|{{KEYCLOAK_URL}}|$KEYCLOAK_URL|g; \
                               s|{{NAMESPACE}}|$NAMESPACE|g; \
                               s|{{DEFAULT_REGION}}|$DEFAULT_REGION|g; \
                               s|{{IMAGE_APP}}|$IMAGE_APP|g" | kubectl -n $NAMESPACE apply -f -
kubectl -n $NAMESPACE apply -f app-service.yaml
APP_URL=$(kubectl -n $NAMESPACE get svc/app -o json | grep hostname | sed 's|.*: \(.*\)|\1|;s/"//g')
for i in {1..50}
do
  if [ -z $APP_URL ]; then
    sleep 5
    APP_URL=$(kubectl -n $NAMESPACE get svc/app -o json | grep hostname | sed 's|.*: \(.*\)|\1|;s/"//g')
    echo "Loop $i of 50, waited $(expr $i \* 5) seconds for ELB"
  else
    break
  fi
done
echo ${APP_URL}

#micro deployment
cat micro-app-deployment.yaml | sed "s|{{KEYCLOAK_URL}}|$KEYCLOAK_URL|g; \
                                     s|{{NAMESPACE}}|$NAMESPACE|g; \
                                     s|{{DEFAULT_REGION}}|$DEFAULT_REGION|g; \
                                     s|{{IMAGE_MICRO}}|$IMAGE_MICRO|g" | kubectl -n $NAMESPACE apply -f -
kubectl -n $NAMESPACE apply -f micro-app-service.yaml
MICRO_URL=$(kubectl -n $NAMESPACE get svc/micro -o json | grep hostname | sed 's|.*: \(.*\)|\1|;s/"//g')
for i in {1..50}
do
  if [ -z $MICRO_URL ]; then
    sleep 5
    MICRO_URL=$(kubectl -n $NAMESPACE get svc/micro -o json | grep hostname | sed 's|.*: \(.*\)|\1|;s/"//g')
    echo "Loop $i of 50, waited $(expr $i \* 5) seconds for ELB"
  else
    break
  fi
done
echo ${MICRO_URL}

#replace redirect uri with app url
cp realm-config/jhipster-realm.json realm-config/jhipster-realm-tmp.json
sed -i "" -e "s|http://.*:8080|http://$APP_URL|g" realm-config/jhipster-realm.json
kubectl -n $NAMESPACE create configmap keycloak-map --from-file realm-config -o yaml --dry-run | kubectl replace -f -

kubectl scale deployment keycloak --replicas=0 -n $NAMESPACE
sleep 5
kubectl scale deployment keycloak --replicas=1 -n $NAMESPACE

mv realm-config/jhipster-realm-tmp.json realm-config/jhipster-realm.json

echo "Kube $NAMESPACE environment initial setup complete"
