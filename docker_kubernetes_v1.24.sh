#!/bin/bash

###基于Docker安装 kubernetes_v1.24
#操作系统 Ubuntu20.04.5

##Step1. 关闭防火墙
ufw disable
ufw status

##Step2.关闭swap分区
swapoff -a
sed -i '/swap/s/^/#/' /etc/fstab

##Step3. 配置网桥过滤及内核转发
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl params without reboot
sysctl --system

##Step4. 安装docker-ce
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common

curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"

sudo apt-get -y update

sudo apt-get -y install docker-ce=5:${DOCKER_VERSION}~3-0~ubuntu-$(lsb_release -cs)


##Step5. 配置docker-ce
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://registry.aliyuncs.com",
  "https://docker.mirrors.ustc.edu.cn",
  "https://hub-mirror.c.163.com",
  "https://reg-mirror.qiniu.com",
  "https://registry.docker-cn.com"
  ],
  "insecure-registries": ["http://harbor.jnhgsz.com"],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

sudo systemctl daemon-reload
sudo systemctl restart docker


##Step6. 安装kubeadm、kubelet、kubectl
apt-get update && apt-get install -y apt-transport-https
curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add - 
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF

sudo apt-get -y update

sudo apt-get install -y kubelet=${1}-00 kubeadm=${1}-00 kubectl=${1}-00

##Step7. 安装 cri-dockerd
curl -LO https://github.com/Mirantis/cri-dockerd/releases/download/v0.2.6/cri-dockerd_0.2.6.3-0.ubuntu-$(lsb_release -cs)_amd64.deb

dpkg -i cri-dockerd_0.2.6.3-0.ubuntu-$(lsb_release -cs)_amd64.deb

##Step8. 配置cri-dockerd
sed -ri -e 's,^(ExecStart=.*),\1 --pod-infra-container-image registry.aliyuncs.com/google_containers/pause:3.7,' /lib/systemd/system/cri-docker.service
systemctl daemon-reload && systemctl enable --now cri-docker.service && systemctl restart cri-docker.service

kubelet --version
docker --version
