# azure-lab

## Prerequisites

If not available already, install the following:

- [Docker](https://docs.docker.com/engine/install/ubuntu/) 
- [K3D](https://k3d.io/v5.6.0/#installation)
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [helm](https://helm.sh/docs/intro/install/)

## Repo structure

There is a [ros 2 pointcloud dummy package](ws/src/pointcloud_detection) inside ws folder. When you open this folder the entire dev docker environment is configured in [.devcontainer](ws/.devcontainer/) and can be used via `Dev Containers` Extensions in vscode. Debugging setup can also be found inside [.vscode](ws/.vscode/). 

The entire application and build pipeline is developed in the [orchestration-lab](https://github.com/UmutAlpTuglu/orchestration-lab) repo and the newest image version gets automatically pushed to a public Docker Hub repo, which is configured in mentioned repo. 
This image is also referenced in the [Pointcloud Helm package](ws/src/pointcloud-detection-helm) and can be tested in a simple k3d setup with [Dummy publisher](ws/src/ros_pub_sub.yaml).

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


## Next steps

- create container registry and super cheap AKS cluster via terraform to practice
- create CI build github actions pipeline which pushes automatically when helm repo is updated to azure container registry
- configure azure_deployment.yaml to work with ros image
- configure azure_deployment.yaml to work with helm images which are pushed there by CI helm pipeline
- compare CD deployment pipelines to ArgoCD
  - because github actions has no idea what the state of the cluster is, it just deploys but does not know if resource was manually modified or removed
    - Argo/Flux ensure that the state of cluster matches with repo at all times 
