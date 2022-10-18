# kubernetes

## Ubuntu20.04.5 基于 docker 安装 kubernetes v1.24+

### 1. 安装 docker/kubelet/kubeadm/kubectl
kubernetes 集群所有节点都需要安装

```
###Step1. 指定要安装的docker的版本
export DOCKER_VERSION=20.10.18

###Step2. 最后一个参数 1.24.6，用来指定 kubernetes 的版本，支持 v1.24+ 的版本
curl -sSL https://raw.githubusercontent.com/changgecloud/kubernetes/main/docker_kubernetes_v1.24.sh | sh -s 1.24.6
```
### 2. 初始化 master 节点

```



```

#### kubeadm 重置
如果我们初始化节点时报错，需要做一下重置防止有数据残留可能还会报错。

```
###@ 1.24 版本之后需要增加 --cri-socket
kubeadm reset --cri-socket unix:///run/cri-dockerd.sock
```

### 3. 初始化 work 节点





