#!/bin/bash



systemctl enable kubelet.service

###Step1. 实现 kubectl kubeadm 命令补全
echo "source <(kubectl completion bash)" >> ~/.bashrc
echo "source <(kubeadm completion bash)" >> ~/.bashrc
sudo source ~/.bashrc


###Setp2. 提前下载集群所需镜像
# kubeadm config images list --kubernetes-version ${1} --image-repository registry.aliyuncs.com/google_containers
# for i in $(kubeadm config images list --kubernetes-version ${1} --image-repository registry.aliyuncs.com/google_containers) ;do docker pull $i ;done


kubeadm config images pull --kubernetes-version=v${1} --image-repository registry.aliyuncs.com/google_containers --cri-socket unix:///run/cri-dockerd.sock

###Step3. 初始化 master
kubeadm init --control-plane-endpoint=${KUBEAPI_IP} \
--kubernetes-version=v${1} \
--pod-network-cidr=${POD_NETWORK_CIDR} \
--service-cidr=${SERVICE_CIDR} \
--token-ttl=0 \
--cri-socket unix:///run/cri-dockerd.sock \
--image-repository registry.aliyuncs.com/google_containers \
--upload-certs

###Step4. 配置 kubectl
rm -rf /root/.kube/
mkdir /root/.kube/
cp -i /etc/kubernetes/admin.conf /root/.kube/config

###Step5. 验证
kubectl get nodes

