NAMESPACE=$1

kubectl -n $NAMESPACE delete --all configmap
kubectl -n $NAMESPACE delete --all deploy
kubectl -n $NAMESPACE delete --all svc
