# Cheap AKS Cluster via Terraform

First steps in a Infrastructure as Code (IaC) in a cloud environment, exciting

I am following the official [azure guide](https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-terraform?pivots=development-environment-azure-cli) for creating `AKS` with `Terraform`.

Lets create

1. Login into az and initialize a working directory containing Terraform configuration files -> creates .terraform directory, downloads required providers, sets up backend for state.
```shell
az login
terraform init
```
2. Create an execution plan, which lets you preview the changes that Terraform plans to make to your infrastructure -> reads configuration files, compares with current state and executes the plan:
```shell
terraform plan -out main.tfplan
```
3. Apply the configuration -> takes the plan, creates/updates resources, saves new state:
```shell
terraform apply main.tfplan
```
4. Get cluster credentials and test if it worked:
```shell
az aks get-credentials --resource-group aks-demo-rg --name aks-demo --overwrite-existing
kubectl get nodes
```

Terraform keeps track of created resources in state file, stored in terraform.tfstate. Needs to be in gitignore, same with main.tfplan and .terraform!!

> Stop and start the cluster and destroy entire Terraform project:
```shell
az aks stop --resource-group aks-demo-rg --name aks-demo  # Stops cluster -> in Azure this will show up: This cluster is stopping...
# VM costs stop (~90% cost reduction), you still pay for storage and some other minor resources
az aks start --resource-group aks-demo-rg --name aks-demo # Starts cluster
terraform destroy # Delete everything if costs get too high
```
