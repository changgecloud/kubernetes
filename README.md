# kubernetes

## Ubuntu20.04.5 基于 docker 安装 kubernetes v1.24+

```
###Step1. 指定要安装的docker的版本
export DOCKER_VERSION=20.10.18

###Step2. 最后一个参数 1.24.6，用来指定 kubernetes 的版本，支持 v1.24+ 的版本
curl -sSL https://raw.githubusercontent.com/changgecloud/kubernetes/main/docker_kubernetes_v1.24.sh | sh -s 1.24.6
```
