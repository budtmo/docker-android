# Kubernetes & Azure (AKS, Terraform, Kompose, Kubectl, Azure CLI)

  - Azure CLI configuration
  - Infrastructure as code for Azure
  - Generating Kubernetes configuration files with Kompose (Services, Deployments, Pods & Persistent volumes)
  - Terraform with Azure Provider
  - Kubectl configuration

## Setting up Azure CLI 

 - Install Azure CLI -> https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest
 - Execute ```sh $ az login ``` and authenticate with your Azure account
 - Execute ```sh $ az account show --query "{subscriptionId:id, tenantId:tenantId"  ``` . Then copy subscriptionId and tenantId
 - Execute ```sh $ az account set --subscription="${SUBSCRIPTION_ID}" ``` . Replace ${SUBSCRIPTION_ID} for your subscriptionId copied

## Create infrastucture in Azure (AKS Service with node master)

Terraform version >= v0.11.7

 - Install Terraform -> https://www.terraform.io/downloads.html
 - Edit vars with Azure Account values in ```sh terraform.tfvars ```
 - After that:

 ```sh
 $ terraform init
 $ terraform plan
 $ terraform apply
 ```

## Setting up Kubectl with Azure account

 - For apply Kubernetes files:

 First configurate azure-cli with Azure account and install kubernetes tools with az: 

 ```sh 
 $ az aks install-cli 
 ```

 Then log in in to the Azure Container Registry (if you're using it, but dockerhub or other):

 ```sh
 $ az acr login
 ```

 After that, connect to cluster with Kubectl:

 ```sh
 $  az aks get-credentials --resource-group docker-android --name k8s-docker-android
 ``` 

## Running with custom K8s files (Recommended)

 - You can use this approach or Kompose (Next 2 steps)

 ```sh
 $ kubectl create -f volumes.yaml
 $ kubectl create -f services_deployments.yaml
 ```

## Generate Kube files with Kompose

 - Install Kompose -> https://github.com/kubernetes/kompose

 Kompose version: >= 1.1.0

 - For convert to Kompose:

 ```sh
 $ cd kompose
 $ kompose convert -f ../kompose.yml
 ```

## Execute Kube files (Kompose)

 - First create Persistent Volume Claims, then Services; finally Deployments files. For example:

 ```sh 
 $ cd kompose
 $ kubectl create -f nexus-7.1.1-claim0-persistentvolumeclaim.yaml 
 $ kubectl create -f nexus-7.1.1-claim1-persistentvolumeclaim.yaml 
 $ kubectl create -f nexus-7.1.1-service.yaml 
 $ kubectl create -f nexus-7.1.1-deployment.yaml 
 ```


