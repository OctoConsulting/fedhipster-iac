#!/bin/bash
function echo_header() {
  echo
  echo "########################################################################"
  echo $1
  echo "########################################################################"
}

function usage {
  echo "Usage: $(basename $0) [ -destroy ]"
  exit
}
if [[ $# -gt 1 ]]; then
  usage
fi
if [[ $# -eq 1 ]]; then
  if [[ "$1" != "-destroy" ]]; then
    usage
  else
    echo_header "Destroying infrastructure"
    chmod u+x destroy.sh
    ./destroy.sh
    exit
  fi
fi
chmod u+x delete-pipeline.sh
echo_header "OneClick Setup: ($(date))"

##### Tools #####
echo "Checking tools"
#Install tools iff they don't exist
if [ ! -x $(command -v brew) ]; then
  yes "" | /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi
if [ ! -x $(command -v createdb) ]; then
  brew install libpq
  brew link --force libpq
  brew install jq
fi

if [ ! -x $(command -v wget) ];                  then brew install wget; fi
if [ ! -x $(command -v aws) ];                   then brew install awscli; fi
if [ ! -x $(command -v aws-iam-authenticator) ]; then brew install aws-iam-authenticator; fi
if [ ! -x $(command -v terraform) ];             then brew install terraform; fi
if [ ! -x $(command -v kubectl) ];               then brew install kubernetes-cli; fi

#Uninstall Helm3, if any, just to make sure we are not using Helm v3, we need Helm v2
brew uninstall kubernetes-helm
brew install helm@2


echo "All necessary tools installed"

##### Prompts #####
read -p "Enter AWS Access Key: " AWS_ACCESS_KEY
read -s -p "Enter AWS Secret Key: " AWS_SECRET_KEY
printf "\n"
read -p "Enter AWS Region (us-east-2 | us-east-2(default)): " AWS_REGION_INPUT
AWS_REGION=${AWS_REGION_INPUT:-"us-east-2"}
printf "\n AWS Region: $AWS_REGION"
export AWS_DEFAULT_REGION=$AWS_REGION
printf "\n"
read -p "Enter GitHub username (not email) with access to repo: " GITHUB_USER
read -s -p "Enter password for GitHub user: " GITHUB_PASS
printf "\n"
#read -p "Enter GitHub Repo URL (for example https://github.com/OctoConsulting/app-name): " GITHUB_REPO

##### Variables #####
AWS_REGION=us-east-2
GITHUB_APP=https://github.com/OctoConsulting/fedhipster-template
GITHUB_MICRO=https://github.com/OctoConsulting/blue-line-micro
IMAGE_APP=octolabs/fedhipster-app
IMAGE_MICRO=octolabs/micro

printf "$AWS_ACCESS_KEY\n$AWS_SECRET_KEY\n$AWS_REGION\n\n" | aws configure
printf "\n"

#IMAGE_REPO=$(aws ecr create-repository --repository-name app | grep repositoryUri | sed 's|.*: \(.*\)|\1|;s/"//g;s/\/.*//')
#echo "Create ECR Repository: $IMAGE_REPO"

#Using Terraform to install and configure the AWS EKS Environment
printf "Using Terraform to install and configure AWS EKS Environment"

#### AWS Terraform #####
terraform init
terraform apply --auto-approve
#Rerun apply to create Elasticsearch resources, if failed in the first run (See https://github.com/terraform-providers/terraform-provider-aws/issues/7725)
terraform apply --auto-approve > /dev/null 2>&1

##### Infrastructure Setup #####
export PGPASSWORD=$(terraform output cluster_master_password)
ECR_APP=$(terraform output ecr-app)
ECR_MICRO=$(terraform output ecr-micro)
IMAGE_REPO=$(echo $ECR_APP | cut -f1 -d'/')

##### Kubernetes Config #####
terraform output kubeconfig > ./kubeconfig
terraform output config_map_aws_auth > ./config_map_aws_auth.yaml
export KUBECONFIG=$(pwd)/kubeconfig
kubectl apply -f ./config_map_aws_auth.yaml

kubectl cluster-info
kubectl cluster-info > outputs.txt
kubectl config get-contexts

kubectl apply -f rbac.yaml
kubectl create rolebinding default-role \
  --clusterrole=cluster-admin \
  --serviceaccount=default:default

##### KMS Terraform #####
# cd ./terraform-aws-kms/examples/with-default-policy
# terraform init
# terraform apply --auto-approve
# cd ../../..

##### CI/CD #####
cd ./cicd/
helm init --service-account tiller
kubectl -n kube-system rollout status deploy/tiller-deploy
helm repo update
sleep 30
chmod u+x *.sh
./cicd-startup.sh default cicd \
  $AWS_ACCESS_KEY $AWS_SECRET_KEY $GITHUB_USER $GITHUB_PASS $IMAGE_REPO $GITHUB_APP $GITHUB_MICRO $AWS_REGION
cd ..

##### Environments #####
for NAMESPACE in {prod,stage,dev}
do
  kubectl create namespace $NAMESPACE

  echo "Creating $NAMESPACE App Database"
  createdb -h $(terraform output cluster_endpoint) -p 5432 -U $(terraform output cluster_master_username) ${NAMESPACE}-db
  echo "Creating $NAMESPACE Micro Database"
  createdb -h $(terraform output cluster_endpoint) -p 5432 -U $(terraform output cluster_master_username) ${NAMESPACE}-micro-db

  #Create kubernetes secrets from terraform outputs
  #Create secrets for RDS
  kubectl -n ${NAMESPACE} create secret generic rds-${NAMESPACE} \
    --from-literal=rds_db=${NAMESPACE}-db \
    --from-literal=rds_endpoint=$(terraform output cluster_endpoint)  \
    --from-literal=rds_password=$(terraform output cluster_master_password) \
    --from-literal=rds_username=$(terraform output cluster_master_username)
  kubectl -n ${NAMESPACE} create secret generic rds-micro-${NAMESPACE} \
    --from-literal=rds_db=${NAMESPACE}-micro-db \
    --from-literal=rds_endpoint=$(terraform output cluster_endpoint)  \
    --from-literal=rds_password=$(terraform output cluster_master_password) \
    --from-literal=rds_username=$(terraform output cluster_master_username)

  #Create secrets for Elasticsearch domains
  kubectl -n ${NAMESPACE} create secret generic elastic-${NAMESPACE} \
    --from-literal=elastic_uri=https://$(terraform output domain_endpoint_${NAMESPACE})

  #Create secrets for API Gateway URLs
  # kubectl -n ${NAMESPACE} create secret generic lambda-${NAMESPACE} \
  #   --from-literal=api_url=$(terraform output retro_api_${NAMESPACE}_url)

  #S3 bucket names
  kubectl -n ${NAMESPACE} create secret generic bucket-${NAMESPACE} \
    --from-literal=bucket_name=$(terraform output ${NAMESPACE}_bucket)

  kubectl -n ${NAMESPACE} create secret generic aws-keys \
    --from-literal=aws_access=$AWS_ACCESS_KEY \
    --from-literal=aws_secret=$AWS_SECRET_KEY

  kubectl -n ${NAMESPACE} create rolebinding ${NAMESPACE}-role \
    --clusterrole=cluster-admin \
    --serviceaccount=default:default \

  # cd ./terraform-aws-kms/examples/with-default-policy
  # kubectl -n ${NAMESPACE} create secret generic kms-key \
  #   --from-literal=kms_key_id=$(terraform output key_id)
  # cd ../../..

  #Install and setup initial environments
  cd ./kompose/
  chmod u+x *.sh
  ./kube-startup.sh $NAMESPACE $AWS_REGION $IMAGE_APP $IMAGE_MICRO
  cd ..
done

##### Data Scraping #####
# cd bin
# chmod u+x ./invokeScrape.sh
# SCRAPE_INTERVAL_SEC=7
# DATA_SOURCE=OneTimeDataSourceUrlLoad_WIKI.csv
# FIRST_SCRAPE_WAIT_MIN=30

# SCRAPE_ENV=dev
# printf "\n Scheduling background scraper process for ${SCRAPE_ENV}. Check ${SCRAPE_ENV}-out.log for the status. \n"
# nohup ./invokeScrape.sh $DATA_SOURCE $SCRAPE_ENV $SCRAPE_INTERVAL_SEC $FIRST_SCRAPE_WAIT_MIN > ${SCRAPE_ENV}-out.log &
# sleep 1

# SCRAPE_ENV=stage
# printf "\n Scheduling background scraper process for ${SCRAPE_ENV}. Check ${SCRAPE_ENV}-out.log for the status. \n"
# nohup ./invokeScrape.sh $DATA_SOURCE $SCRAPE_ENV $SCRAPE_INTERVAL_SEC $FIRST_SCRAPE_WAIT_MIN > ${SCRAPE_ENV}-out.log &
# sleep 1

# SCRAPE_ENV=prod
# printf "\n Scheduling background scraper process for ${SCRAPE_ENV}. Check ${SCRAPE_ENV}-out.log for the status. \n"
# nohup ./invokeScrape.sh $DATA_SOURCE $SCRAPE_ENV $SCRAPE_INTERVAL_SEC $FIRST_SCRAPE_WAIT_MIN > ${SCRAPE_ENV}-out.log &
# sleep 1

# cd ..

#Install and setup monitoring
cd ./monitoring/
chmod u+x *.sh
./monitoring.sh $AWS_REGION
cd ..

##### Environment Output #####
chmod u+x environments.sh
./environments.sh
mv environments.txt iac-output.txt

echo_header "Environment Information"
cat iac-output.txt

#Kube-monkey
kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default
kubectl apply -f kube-monkey/configmap.yaml
kubectl apply -f kube-monkey/deployment.yaml

#Kubernetes Dashboard
kubectl apply -f monitoring/kubernetes-dashboard.yaml
kubectl proxy &

echo "Kubernetes Dashboard localhost URL: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
echo "Use following command to get the token : aws eks get-token --cluster-name eks-cluster-app | jq -r '.status.token'"

exit
