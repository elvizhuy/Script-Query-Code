#! /bin/bash

apt-get update && apt-get upgrade -y
apt-get install -y vim

apt install curl apt-transport-https vim git wget \
software-properties-common lsb-release ca-certificates -y

swapoff -a
modprobe overlay
modprobe br_netfilter

cat << EOF | tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sysctl --system

function KeyRing ()
{
    sudo mkdir-p /etc/apt/keyrings
    curl-fsSL https://download.docker.com/linux/ubuntu/gpg \
    | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
}
KeyRing

function install Containerd () 
{
    apt-get update && apt-get install containerd.io -y
    containerd config default | tee /etc/containerd/config.toml
    sed -e 's/SystemdCgroup = false/SystemdCgroup = true/g' -i /etc/containerd/config.toml
    systemctl restart containerd
}
install Containerd

touch /etc/apt/sources.list.d/kubernetes.list
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" >> /etc/apt/sources.list.d/kubernetes.list
curl -s \
https://packages.cloud.google.com/apt/doc/apt-key.gpg \
| apt-key add -
apt-get update
apt-get install -y kubeadm=1.27.1-00 kubelet=1.27.1-00 kubectl=1.27.1-00
apt-mark hold kubelet kubeadm kubectl

function createKubeConfigFile ()
{
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
kubernetesVersion: 1.27.1
controlPlaneEndpoint: "k8s-master.huynn.local:6443"
networking:
    podSubnet: 192.168.0.0/16
}




