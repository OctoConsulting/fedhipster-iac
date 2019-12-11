#Destroy ECR repo

cp ./kubeconfig ./cicd/
cd cicd
./cicd-delete.sh default cicd
kubectl delete namespace dev
kubectl delete namespace stage
kubectl delete namespace prod
