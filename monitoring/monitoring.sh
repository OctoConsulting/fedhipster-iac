AWS_REGION=$1
NAMESPACE=grafana

kubectl create namespace $NAMESPACE

#Prometheus
helm install stable/prometheus \
  --name prometheus \
  --namespace $NAMESPACE

#Grafana
kubectl -n $NAMESPACE create configmap kube-resources --from-file=kube-resources.json
kubectl -n $NAMESPACE label configmap kube-resources grafana-dashboard=1

helm install stable/grafana \
  --name grafana \
  --namespace $NAMESPACE \
  --set datasources."datasources\.yaml".apiVersion=1 \
  --set datasources."datasources\.yaml".datasources[0].name=Prometheus \
  --set datasources."datasources\.yaml".datasources[0].type=prometheus \
  --set datasources."datasources\.yaml".datasources[0].url=http://prometheus-server.${NAMESPACE}.svc.cluster.local \
  --set datasources."datasources\.yaml".datasources[0].access=proxy \
  --set datasources."datasources\.yaml".datasources[0].isDefault=true \
  --set sidecar.dashboards.enabled=true \
  --set sidecar.dashboards.label=grafana-dashboard \
  --set service.type=LoadBalancer

#CloudWatch Logs
curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/master/k8s-yaml-templates/quickstart/cwagent-fluentd-quickstart.yaml \
  | sed "s/{{cluster_name}}/eks-cluster/;s/{{region_name}}/$AWS_REGION/" | kubectl apply -f -
