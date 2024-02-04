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
    KEYRING_DIR="/etc/apt/keyrings"
    if [ ! -d "$KEYRING_DIR" ]; then
        sudo mkdir -p "$KEYRING_DIR"

        # Tải và cài đặt khóa GPG
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o "$KEYRING_DIR/docker.gpg"

        # Thêm nguồn cho APT
        echo "deb [arch=$(dpkg --print-architecture) signed-by=$KEYRING_DIR/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        echo "Đã tạo thư mục và cài đặt khóa GPG thành công."
    else
        echo "Thư mục $KEYRING_DIR đã tồn tại. Bỏ qua bước tạo thư mục và cài đặt khóa GPG."
    fi
}
KeyRing

function install_containerd () 
{
    apt-get update && apt-get install containerd.io -y
    containerd config default | tee /etc/containerd/config.toml
    sed -e 's/SystemdCgroup = false/SystemdCgroup = true/g' -i /etc/containerd/config.toml
    systemctl restart containerd
}
install_containerd

function install_kubeadm ()
{
    if dpkg -l | grep -E '^ii' | grep -q 'kubeadm'; then
        echo "Kubeadm đã được cài đặt. Bỏ qua bước cài đặt."
        return 0
    fi
    sudo sh -c 'echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list'
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    sudo apt-get update
    sudo apt-get install -y kubeadm=1.27.1-00 kubelet=1.27.1-00 kubectl=1.27.1-00
    sudo apt-mark hold kubelet kubeadm kubectl
}
install_kubeadm

# function createKubeConfigFile ()
# {
# cat <<EOF > kubeadm-config.yaml
# apiVersion: kubeadm.k8s.io/v1beta3
# kind: ClusterConfiguration
# kubernetesVersion: 1.27.1
# controlPlaneEndpoint: "k8s-master.huynn.local:6443"
# networking:
#   podSubnet: 192.168.0.0/16
# EOF
# }
# createKubeConfigFile

# if [ -f "kubeadm-config.yaml" ]; then
#     echo "File kubeadm-config.yaml đã được tạo thành công."
# else
#     echo "Có lỗi xảy ra khi tạo file kubeadm-config.yaml."
# fi

# kubeadm init --config=kubeadm-config.yaml --upload-certs | tee kubeadm-init.out

# function setup_kubeconfig() {
#     KUBE_DIR=$HOME/.kube

#     # Kiểm tra xem thư mục ~/.kube đã tồn tại chưa
#     if [ ! -d "$KUBE_DIR" ]; then
#         # Nếu không tồn tại, tạo thư mục
#         mkdir -p $KUBE_DIR
        
#         # Sao chép file cấu hình admin.conf vào ~/.kube/config
#         sudo cp -i /etc/kubernetes/admin.conf $KUBE_DIR/config
        
#         # Cấp quyền sở hữu cho người dùng hiện tại cho file config
#         sudo chown $(id -u):$(id -g) $KUBE_DIR/config
        
#         # Hiển thị nội dung của file config
#         # less $KUBE_DIR/config

#         echo "Đã cài đặt và cấu hình thành công."
#     else
#         echo "Thư mục $KUBE_DIR đã tồn tại. Bỏ qua bước cài đặt."
#     fi
# }
# setup_kubeconfig






