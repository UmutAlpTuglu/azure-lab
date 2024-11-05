# azure-lab

Kubernetes, Helm, ROS related testings in an Azure Cloud environment with focus on pipelines.

## Prerequisites

If not available already, install the following:

- [Docker](https://docs.docker.com/engine/install/ubuntu/) 
- [K3D](https://k3d.io/v5.6.0/#installation)
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [helm](https://helm.sh/docs/intro/install/)
- [azure cli](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt)
- [terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

## Repo structure

### Pointcloud ROS app

There is a [ros 2 pointcloud dummy package](ws/src/pointcloud_detection) inside ws folder. When you open this folder in vscode the entire dev docker environment is configured in [.devcontainer](ws/.devcontainer/) and can be used via `Dev Containers` Extensions in vscode. Debugging setup can also be found inside [.vscode](ws/.vscode/).

In the [ros package folder](ws/src/pointcloud_detection) you can find the entire package setup and how to test the code can be found as comments at the top of this [file](ws/src/pointcloud_detection/pointcloud_detection/pointcloud_detection.py). You can test the application in the docker development environment with three terminals, or you can build the [pointcloud.Dockerfile image](ws/pointcloud.Dockerfile) locally or you can run it via the [CI ros build pipeline](.github/workflows/ros_build.yml), which just builds the package and pushes it to a public ocker Hub image registry. Its triggered when one of the crucial files is changed and there is a push to the main branch. So any code changes relative to the python code, the dockerfile or the CI pipeline creates a new image pushed to Docker Hub.

This image is also referenced in the [Pointcloud Helm Chart](ws/src/pointcloud-detection-helm) and can be tested in a simple k3d setup with a [Dummy ROS publisher](ws/src/ros_pub_sub.yaml).

Create local cluster, install helm release and test application with dummy ros-publisher:
```shell
k3d cluster create test
helm install test ws/src/pointcloud-detection-helm/
kubectl apply -f ws/src/ros_pub_sub.yaml/
```

And then check logs before and after of ros pointcloud publisher:
```shell
kubectl logs -f "pod name of ros app"
```

### Pipelines

#### ros_docker_build.yml

Builds the docker ros image and pushes it to a public Docker Hub image registry.
> UPDATE: Multi Platform : linux/amd64,linux/arm64

Builds for two platforms because AKS cluster runs on different architecture than my k3d setup on my server. 
With `image.pullPolicy: Always` in the helm chart, it ensures that always the newest version is downloaded.

#### ros_helm_build.yml

The goal is to create Azure Container Registry as a registry for Helm charts with the `oci://` scheme. For that first create a container registry with a basic plan (cheapest option). 
Before deep diving into the pipeline, lets test this setup locally:
1. The [azure service principal script](azure_scripts/ACR_Helm_setup.sh) creates service principal logins which are outputed to the terminal. In the top of the script you can need to set your resource group, registry name in azure and subscription ID and then execute script and then copy ID and password from terminal
2. Login to ACR via helm:
```shell
helm registry login <REGISTRY_NAME>.azurecr.io --username <SP_PUSH_ID> --password <SP_PUSH_PASSWORD>
``` 
3. package and push the image:
```shell
helm package ws/src/pointcloud-detection-helm/
helm push pointcloud-detection-helm-0.1.0.tgz oci://<REGISTRY_NAME>.azurecr.io/helm
```
4. Pull to test if it worked
```shell
helm pull oci://<REGISTRY_NAME>.azurecr.io/helm/pointcloud-detection-helm --version 0.1.0
```

The pipeline combines the first three steps, but before it logs in with [connection-json](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure-secret). Create the needed secrets and the pipeline even fetches the newest chart version. If there are changes to the helm chart, you should change chart version in [Chart.yaml](ws/src/pointcloud-detection-helm/Chart.yaml) so a new package appears in container registry. 

#### ros_helm_deploy.yml

Fetches newest helm package from ACR and installs it directly to the cluster with the test ros publisher.

### Infrastructure as Code (IaC)

In this Repo there is a cheap Azure Kubernetes Service [implementation](terraform-aks) via Terraform. The [docs](terraform-aks/README.md) and the implementation contain a basic setup with basic loadbalancer, kubelet networking and the cheapest VM size I found in the azure portal.


## Next steps

- create super cheap AKS cluster via terraform to practice
- create CI build github actions pipeline which pushes automatically when helm repo is updated to azure container registry
- configure azure_deployment.yaml to work with ros image
- configure azure_deployment.yaml to work with helm images which are pushed there by CI helm pipeline
- compare CD deployment pipelines to ArgoCD, CI can stay
  - because github actions has no idea what the state of the cluster is, it just deploys but does not know if resource was manually modified or removed
    - Argo/Flux ensure that the state of cluster matches with repo at all times 
      - Terraform in comparision is not aware of application health
        - Flux and Argo are better suited for continuous delivery as they have schedulers to detect changes and drift. For example of someone goes in and scales a deployment from 1 to 2. Flux will go in and change it back. Terraform won't detect this until you apply which in an automated fashion won't happen until the next commit/git trigger configured. 

- `optimal setup`:
  - github actions for CI pipelines like pushing images and helm packages to docker hub or azure container registry
  - ArgoCD for managing CD part with 
