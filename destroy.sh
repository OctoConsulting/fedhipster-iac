#Destroy ECR repo
#aws ecr delete-repository --repository-name app --force

#Destroy kubernetes objects
export KUBECONFIG=$(pwd)/kubeconfig
kubectl apply -f ./config_map_aws_auth.yaml

kubectl -n default delete po,svc,deployment,rs,secret,configmap --all
kubectl delete namespaces dev stage prod

# Destroy cloud infrastructure created using terraform apply
terraform destroy -auto-approve

# Retry destroy just in case we have any lingering objects
terraform destroy -auto-approve

# Destroy KMS keys
# cd ./terraform-aws-kms/examples/with-default-policy
# terraform destroy -auto-approve
# cd ../../..
