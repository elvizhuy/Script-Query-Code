#!/bin/bash

is_ubuntu=`awk -F '=' '/PRETTY_NAME/ { print $2 }' /etc/os-release | egrep Ubuntu -i`
is_centos=`awk -F '=' '/PRETTY_NAME/ { print $2 }' /etc/os-release | egrep CentOS -i`

echo "run with user root"
echo "nameserver 8.8.8.8" >> /etc/resolv.conf

function ubuntu_basic_install()
{
	sudo apt -y update	
	sudo apt -y install git wget telnet rsync sysstat lsof nfs-common cifs-utils iptables chrony
	timedatectl set-timezone Asia/Ho_Chi_Minh
    ufw disable 
	systemctl start chronyd
	systemctl restart chronyd
	chronyc sources
	timedatectl set-local-rtc 0
}

function centos_basic_install()
{
  yum update -y
  yum install -y epel-release
  yum groupinstall 'Development Tools' -y
	timedatectl set-timezone Asia/Ho_Chi_Minh 
	yum install -y git wget telnet rsync sysstat lsof nfs-utils cifs-utils iptables-services chrony
	systemctl stop firewalld
	systemctl disable firewalld
	systemctl mask --now firewalld
	systemctl enable iptables
	systemctl start iptables
	systemctl enable chronyd
	systemctl restart chronyd
	chronyc sources
	timedatectl set-local-rtc 0
}

#Linux install basic tools
echo "Linux install basic tools"
if [ ! -z "$is_ubuntu" ]; then
	ubuntu_basic_install
elif [ ! -z "$is_centos" ]; then
	centos_basic_install
fi

echo "Enable limiting resources"
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
echo 'GRUB_CMDLINE_LINUX="cdgroup_enable=memory swapaccount=1"' | sudo tee -a /etc/default/grub
sudo update-grub

echo "Hostname: "
read hostname
hostnamectl set-hostname $hostname

#Create user isofh

function create_user() {
    read -p "Do you want to create a user? [y/n]: " adduser
    if [ "$adduser" == 'y' ]; then
        read -p "Username: " user
        if [ "$user" == 'isofh' ]; then
            useradd -ms /bin/bash isofh
            echo "isofh ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

            # Set the password for the user isofh
            read -s -p "Set the password for the user isofh: " userpassword
            echo -e "\n$userpassword\n$userpassword" | passwd isofh
            echo "Created the user 'isofh' and set the password successfully."
        elif [ "$user" != 'isofh' ]; then
            echo "Invalid username, exiting."
            exit
        fi
    fi
}
create_user

function setupSSHkey() 
{
    mkdir -p /home/isofh/.ssh && cd /home/isofh/.ssh && touch authorized_keys && chmod 700 /home/isofh/.ssh && chmod 600 /home/isofh/.ssh/authorized_keys
    echo "#Jenkins52" >> /home/isofh/.ssh/authorized_keys
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFwLR6DpxhpkEWUTpYgBfjS2++FknUWTZJzkAALwijP0d2kSr0Q0jipKWRX1KtqOOsb/ZFwRr7MLmfqJ8x+Dl+81fbE5PX8eifLwAaD6RyAS4xo87eS8xIvLmavL6gELP5Dm6y1npnNIkEiXMYYKDFm8nb3xlQv89EdBMV+2jCdfhwRKFk8l4O3Yw3klL5Kvs4d2T/n/3zYOgfmh/8XXuXraBJIyEVOGzQcd+0xzz4+vs9u6IAgxXaknPoksycsTjCENaN4Fy8ylpKYrYOzLZkSh7IEjUoXHEXwvfWNc7jNW1KbRRrVSmusBDDC+eNbjw7tlp1LACjzoHQQOnHBLFb @isofh-jenkins52" >> /home/isofh/.ssh/authorized_keys
    echo "#Minh-CTO" >> /home/isofh/.ssh/authorized_keys
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC2VWlYeeDegqIDIQbQh/PZgouGv7LYmUMEOZEQPwSKuYg+teuyBcTNYqRdzjS0dDX1PPPS39xgHm5sa0G6L73L9hRONTMBicqXMdO7aNEFPucfBkfhJ8tDok5xE1e+dtMwwybqmUjfRi6fxao/AM606FOUa1MN4d9w3Qhu1NyiAlCjcyw+qeAGnD1yz3LRxKEq0H5uGSKW672fwx7UvX91wByw+WqYo2UkwVKW9vqa4jvAi0haPJPvENlFpJ3jQ+hJ+ewZWSi4YXmZ8cQkBNWGdZzuOb3VOTWyJIAjiBpeti+arChguoMmFeY3WNFlICfLZ4IbmRtIh3FL/QexYBJYKhjML+Ub3AgUU9t63Lj+9WD7s4QOejH5s3x/V8eP/ZomJetnB6x5zmbu+d6/znoe2J/PIUjHsp7b0qu4XP0/dIY/YqdIjOgOVckHCmjekXnOuXmdxvUOn7GO4uSgHcUh15eCJss1Jahl8q2xrnB8JCEbSMi/PAasKRAxZEKECxigkE7cvbF0UlsYJrFtWY+56BsqTH+64mN/0EtP4bnkoc/2SBt0WBIX6WJfptnfyhd02D0SvEpl22r443JaW2HhL7QUZMwmKm1ZU1rra8oYqB18mG1f4RJlpn9fgvskDFNxGuhoiVMZdWeM935UaO2O+v8LwLO5K8LIpK/avwXw6Q== vanminh.ph23@gmail.com" >> /home/isofh/.ssh/authorized_keys
}
echo "Setup ssh key for user 'isofh'"
setupSSHkey

#install node_exporter
echo "install node_exporter"
sudo useradd --no-create-home --shell /bin/false node_exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz
tar xvf node_exporter-1.0.1.linux-amd64.tar.gz
sudo cp -prn node_exporter-1.0.1.linux-amd64/node_exporter /usr/local/bin
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
rm -rf node_exporter-0.16.0.linux-amd64.tar.gz node_exporter-0.16.0.linux-amd64
sudo touch /etc/systemd/system/node_exporter.service

echo "[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/node_exporter.service

systemctl daemon-reload
systemctl start node_exporter
systemctl enable node_exporter


echo "fs.file-max=100000
vm.swappiness=10" | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
echo "* soft nofile 100000" | sudo tee -a /etc/security/limits.conf
echo "* hard nofile 100000" | sudo tee -a /etc/security/limits.conf


echo "alias dils='docker image ls'
alias dirm='docker image rm'

alias dcls='docker container ls -a --size'
alias dcrm='docker container rm'

alias dcb='docker build . -t'

alias dr='docker restart'

alias dl='docker logs'

alias ds='docker stats'

alias din='docker inspect'

alias dcc='docker cp'

alias dload='docker load -i'

alias dlf='docker logs -f --tail 100'

function dcl() {
        sudo truncate -s 0 $(docker inspect --format='{{.LogPath}}' $1)
}

function drun() {
        docker run --rm $3 --name $2 -it $1 /bin/bash
}

function drun_network_host() {
        docker run --rm --network=host $3 --name $2 -it $1 /bin/bash
}

function dsave() {
        docker docker save -o $2 $1
}


function dexec() {
        container=$1

        docker exec -it $container /bin/bash
}

function dt() {
        for i in $( docker container ls --format "{{.Names}}" ); do
                echo Container: $i
                docker top $i -eo pid,ppid,cmd,uid
        done
}" | sudo tee -a /etc/bashrc


#Install docker
if [ ! -z "$is_ubuntu" ]; then
	is_docker_exist=`dpkg -l | grep docker -i`
elif [ ! -z "$is_centos" ]; then
	is_docker_exist=`rpm -qa | grep docker`
else
	echo "Error: Current Linux release version is not supported, please use either centos or ubuntu. "
	exit
fi

if [ ! -z "$is_docker_exist" ]; then
	echo "Warning: docker already exists. "
fi

function ubuntu_docker_install()
{
	#Install docker
	sudo apt-get -y update
	sudo apt-get remove docker docker-engine docker.io containerd runc 
	sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common  git vim 
	
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
	echo \
		"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
		$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get -y update
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io
	sudo bash -c 'touch /etc/docker/daemon.json' && sudo bash -c "echo -e \"{\n\t\\\"bip\\\": \\\"55.55.1.1/24\\\"\n}\" > /etc/docker/daemon.json"

	sudo systemctl enable docker.service
	sudo systemctl start docker
	usermod -aG docker isofh
		
#	is_docker_success=`sudo docker run hello-world | grep -i "Hello from Docker"`
#	if [ -z "$is_docker_success" ]; then
#		echo "Error: Docker installation Failed."
#		exit
#	fi
	
	echo "Docker has been installed successfully."
}

function centos_docker_install()
{
	#Install docker
	sudo yum install -y yum-utils device-mapper-persistent-data lvm2 git vim 
	sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
	sudo yum -y install docker-ce docker-ce-cli containerd.io
	sudo bash -c 'touch /etc/docker/daemon.json' && sudo bash -c "echo -e \"{\n\t\\\"bip\\\": \\\"55.55.1.1/24\\\"\n}\" > /etc/docker/daemon.json"

	sudo systemctl enable docker.service
	sudo systemctl start docker
	
	is_docker_success=`sudo docker run hello-world | grep -i "Hello from Docker"`
	if [ -z "$is_docker_success" ]; then
		echo "Error: Docker installation Failed."
		exit
	fi

	usermod -aG docker isofh

	echo "Docker has been installed successfully."		
}

function docker_compose_install()
{
	# Install docker-compose
	COMPOSE_VERSION=`git ls-remote https://github.com/docker/compose | grep refs/tags | grep -oE "[0-9]+\.[0-9][0-9]+\.[0-9]+$" | sort --version-sort | tail -n 1`
	sudo sh -c "curl -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose"
	sudo chmod +x /usr/local/bin/docker-compose
	sudo sh -c "curl -L https://raw.githubusercontent.com/docker/compose/${COMPOSE_VERSION}/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose"
	docker-compose --version
	echo "Docker-compose has been installed successfully."
}

function docker_install()
{
	if [ ! -z "$is_ubuntu" ]; then
		ubuntu_docker_install
	elif [ ! -z "$is_centos" ]; then
		centos_docker_install
	fi
}

function reboot_server()
{
	read -p "Please reboot for apply all config. [y/n]: " -n 1 -r
	echo    
	if [[ $REPLY =~ ^[Yy]$ ]]; then
	    /sbin/reboot
	fi
}

echo "Do you want install docker & docker compose? [y/n]: "
read docker
if [ $docker == 'y' ]; then
	docker_install
	docker_compose_install
elif [ $docker != 'y' ]; then
	echo "Docker not installed"
fi

reboot_server
