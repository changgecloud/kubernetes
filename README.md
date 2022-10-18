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
在初始化 master 之前，我们需要在 kubernetes 集群所有节点的 /etc/hosts 文件中配置解析

```
cat >> /etc/hosts <<EOF
192.168.31.100 kubeapi.org
192.168.31.123 ubuntu2004
EOF
```

```
# 只在 master 节点执行
# 单 master 节点时，KUBEAPI_IP 可以为 master 节点 IP
# 多 master 节点高可用时，KUBEAPI_IP 可以为一个代理的 VIP（keepalived+haproxy）
# 当然 KUBEAPI_IP 也可以是一个域名，如果是域名，需要在 /etc/hosts 设置解析
# export 命令只在当前 shell 会话中有效，开启新的 shell 窗口后，如果要继续安装过程，请重新执行此处的 export 命令
export KUBEAPI_IP=192.168.31.100

# Kubernetes 容器组所在的网段，该网段安装完成后，由 kubernetes 创建，事先并不存在于您的物理网络中
export POD_NETWORK_CIDR=10.244.0.0/16

# Kubernetes service 所在的网段
export SERVICE_CIDR=172.10.0.0/16

curl -sSL https://raw.githubusercontent.com/changgecloud/kubernetes/main/init_master.sh | sh -s 1.24.6
```

#### kubeadm 重置
如果我们初始化节点时报错，需要做一下重置防止有数据残留可能还会报错。

```
###@ 1.24 版本之后需要增加 --cri-socket
kubeadm reset --cri-socket unix:///run/cri-dockerd.sock
```

### 3. 初始化 work 节点

#### 获取 join 命令参数
只在 master 节点上执行
```
kubeadm token create --print-join-command
```

可获取kubeadm join 命令及参数，如下所示
--cri-socket 是必须要加的
```
kubeadm join 192.168.31.100:6443 --token b8hev0.kcizwazm0it5ciof \
	--discovery-token-ca-cert-hash sha256:19485e2268a941bdf5c4822554e734d7bc4780e3d4f34fb72102e3121871b9f6 \
  --cri-socket unix:///run/cri-dockerd.sock
```




