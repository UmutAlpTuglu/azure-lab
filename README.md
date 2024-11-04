# azure-lab

## Prerequisites

If not available already, install the following:

- [Docker](https://docs.docker.com/engine/install/ubuntu/) 
- [K3D](https://k3d.io/v5.6.0/#installation)
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [helm](https://helm.sh/docs/intro/install/)
- [azure cli](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt)

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

## Next steps

- create container registry and super cheap AKS cluster via terraform to practice
- create CI build github actions pipeline which pushes automatically when helm repo is updated to azure container registry
- configure azure_deployment.yaml to work with ros image
- configure azure_deployment.yaml to work with helm images which are pushed there by CI helm pipeline
- compare CD deployment pipelines to ArgoCD
  - because github actions has no idea what the state of the cluster is, it just deploys but does not know if resource was manually modified or removed
    - Argo/Flux ensure that the state of cluster matches with repo at all times 
