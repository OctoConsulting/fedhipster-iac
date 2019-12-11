# Automated Infrastructure as Code (IaC) script

The instructions below describe the steps needed to run the solution from code to full deployment. After completing the steps , the final  solution and the CI/CD pipeline can be accessed from the latest Firefox or Chrome web browser, with credentials and links output by the single Automated Infrastructure as Code (IaC) script.

## Step 1: Automated Infrastructure as Code (IaC)

This features a single Automated IaC script with a minimum number of commands to create all infrastructure, including CI/CD pipeline, microservice architecture, crypto secure content, machine learning notebooks, and secure web-based application.

### Prerequisites
- **MacOS** - must execute script on a MacOS operating system by a user with administrative permissions
- **AWS** - must use a blank slate AWS account and have Access Key and Secret Key with full administrative access
- **Git** – must have git installed on local computer and use GitHub account with access to RDSO repositories
- **Internet** – must have stable, reliable broadband internet connection without firewall blocking

### Launch the Environment

Launch the Environment

1. Add the `master` branch of the GitHub repository to your local computer by opening the Terminal application and cloning the GitHub repository using the command `git clone https://github.com/OctoConsulting/fedhipster-iac.git` with GitHub username and password of an authorized account.
2. In the Terminal, change the directory to the location of the cloned repository from above `cd fedhipster-iac`
3. To launch the entire infrastructure, run the following command in the Terminal `./iac-auto.sh 2>&1 | tee iac.log`
4. Follow all onscreen prompts and enter the following in the Terminal when prompted:
   - If prompted with `Password:` enter your local Mac account password
   - Enter your `AWS Access Key` for your AWS account
   - Enter your `AWS Secret Key` for your AWS account
   - Enter your `AWS Region` for your AWS account that you want to deploy your solution to
   - Enter your `GitHub username` that has been given access to the GitHub repositories
   - Enter your `GitHub password` that has been given access to the GitHub repositories
   - Enter your `GitHub Repository URL` for the app source code repository that you want to build and deploy
5. The environment launch script takes approximately 30 minutes to run. When completed, the CI/CD Pipeline, web-based application, and interactive notebook are accessible via links and credentials output on screen and provided in a text file named `iac-output.txt` and saved in the same directory as the cloned repository. Provisioning of the environments may take an additional 30 minutes after script completes.

### Teardown & Demolish the Environment

1. The same script used to launch the environment is also used to teardown the environment. To demolish the environment run the following command in the Terminal `./iac-auto.sh -destroy 2>&1 | tee iac-destroy.log`
2. Teardown script takes approximately 30 minutes to run and will output a “Destroy complete!” message at the end
3. The infrastructure demolition in AWS may take several additional hours to fully complete.


### Stop the Environment later Restart

You need to login to AWS as admin user and peform below steps (in the order mentioned) to stop the instances and DB cluster.
1. On "Auto Scaling Group" Dashboard, select "eks-app" and in the "Instances" section, select all Instances and from the Actions dropdown select "Set to Standy". This makes sure that Auto Scaling Group will not do Health Status check on the instances when they are stopped.
2. On "EC2" Dashboard, select all instaces and from the Actions dropdown select "Instance State" > "Stop", to stop all EC2 instances registerd with the EKS cluster.
3. On "RDS Cluster" Dashboard, select cluster with name "app-rds-cluster" and from the Actions dropdown select "Stop" to Stop the RDS cluster.

### Restart the Environment

You need to login to AWS as admin user and peform below steps (in the order mentioned) to restart the instances and DB cluster.
1. On "RDS Cluster" Dashboard, select cluster with name "app-rds-cluster" and from the Actions dropdown select "Start" to restart the RDS cluster. Wait until the cluster status changes to "Started".
2. On "EC2" Dashboard, select all instaces and from the Actions dropdown select "Instance State" > "Start", to start all EC2 instances registerd with the EKS cluster and make sure that all instances are back to "Running" state.
3. On "Auto Scaling Group" Dashboard, select "eks-app" and in the "Instances" section, select all Instances and from the Actions dropdown select "Set to InService". This makes sure that Auto Scaling Group will start performing Health Status check on the instances when they are restarted.


### Troubleshooting

- If script is not found, then change directory (`cd`) to ensure the script is run from the cloned folder
- If computer malfunctions (Internet connection, loss of power, etc.) simply restart the Automated IaC script.
- If permission is denied, then first run `chmod u+x iac-auto.sh` and then try again by re-running `./iac-auto.sh` to launch the environment or `./iac-auto.sh -destroy` to teardown and demolish the environment.
- If script does not run, users may have input incorrect AWS Credentials (Access Key, Secret Key) or GitHub credentials (Username, Password) – input valid credentials to resolve

### Single Automated IaC Description

The following describes the infrastructure components and processes that are installed as part of the Automated IaC script. The following dependencies are installed first:

- Homebrew
- Wget
- Terraform
- AWS CLI
- AWS IAM Authenticator
- LibPQ
- jq

Upon entering your credentials, the following Terraform steps are executed:

- **AWS VPC, Route Table, Security Groups & Roles, IAM Policies, and Role Policies and other AWS core networking functions** - creates these components, which are prerequisites for the integration of subsequent features and are created by the EKS instance
- **AWS Elastic Kubernetes Service (EKS)** – creates five cluster and worker nodes to manage Kubernetes Clusters necessary for Zero Downtime Deployments (ZDD)
- **Kubernetes CLI** – installed and configured
- **AWS RDS Aurora** - instance is created to host 3 PostgreSQL databases, one for each environment (DEV, STAGE, and PROD)
- **Kubernetes security** constraints – generates configuration files and security constraints
- **AWS Elasticsearch** – creates three APIs to enable fuzzy style searching

The Terraform component of the Automated IaC script ends and the remaining components are executed:
- **Helm** – installed locally to assist with the deployment of Jenkins
- **Tiller** – installed on the EKS clusters to allow for the installation of Helm charts
- **Jenkins** - installed and configured to deploy the CI/CD pipeline
- **AWS KMS** – content encryption keys are generated
- **JHipster** - application deployed via the Jenkins pipeline

## Step 2: Automated CI/CD Pipeline

The automated CI/CD pipeline is initiated when a pull request is merged to the `dev` / `stage` branch in GitHub, which has a trigger to start the automated build process. A git hook is sent to Jenkins, triggering a build for that branch in the `app-dev` / `app-stage` pipeline & deploying to the DEV / STAGE environment.

For the PROD environment, a developer signs in to Jenkins and manually starts a build in the `app-prod` pipeline. Production deployments are not initiated by a git hook trigger to give greater control to stakeholders over the release of functionality to production.

When a build is initiated in the `app-dev` or `app-stage` pipelines, Maven compiles the code, downloads dependencies, and executes unit tests. JUnit (backend) and Jasmine (frontend) tests ensure individual units of code function as designed, with failing tests breaking the build. SonarQube is used for static code analysis and reports code quality, including unit test coverage, duplicate lines, code smells, and cyclomatic complexity.

Once the build passes through all gates, the application is containerized as a Docker image, tagged with a version number, and pushed to the Docker container registry, AWS Elastic Container Registry (ECR). AWS ECR provides a highly available, scalable infrastructure in which to store, manage, and deploy Docker images. Security is built in to AWS ECR with Docker images securely transferred and auto-encrypted at rest. The Docker image is then deployed to the AWS Elastic Kubernetes Service (EKS) Kubernetes Cluster, which is configured for Zero Downtime Deployments (ZDD). AWS EKS provides a platform from which manage the Kubernetes Cluster. AWS EKS provides auto-patching and auto-maintenance of the infrastructure on which the Kubernetes cluster is hosted. This ensures the application is always capable of being deployed and that no security vulnerabilities will be introduced by infrastructure.

Post-deployment testing includes: pa11y for accessibility and Section 508 compliance, **OWASP ZAP** for penetration testing, **Selenium** for integration testing, and **JMeter** for performance testing. Each of the post-deployment tests output a report which is stored in Jenkins.

## Step 5: Secure Sign In

To access the application as a user, navigate to one of the environments as generated by the one-click script. The user is re-directed, via Zuul, to a secure web-based application. The user clicks the “Sign In” button on the App homepage and is directed to a Sign In page. Enter the Username and Password for a given user from the table below and click the Sign In button. The application redirects the user to the appropriate page based on their access role.

|Role|Username|Password|
|------|-------|--------|
|Conference Planner User|emily.user|user123!|
|Business Supervisor|joseph.bizvisor|bizvisor123!|
|Systems Administrator|matt.devops|devops123!|
