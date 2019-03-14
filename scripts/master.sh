#!/bin/bash

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository    "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"


curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat << EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt-get update
sudo apt-get install -y docker-ce=18.06.1~ce~3-0~ubuntu kubelet=1.12.2-00 kubeadm=1.12.2-00 kubectl=1.12.2-00
sudo apt-mark hold docker-ce kubelet kubeadm kubectl

echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# need python for ansible
apt install -y python

# Create User for deployment
groupadd ${kub_admin_group}
useradd -m -g ${kub_admin_group} -s /bin/bash ${kub_admin_user}
echo "${kub_admin_user}:${kub_admin_pass}" | chpasswd

cat <<-__FILE_CONTENTS__ > /etc/sudoers.d/${kub_admin_user}
${kub_admin_user} ALL=(ALL:ALL) NOPASSWD:ALL
#Defaults:${kub_admin_user} env_keep += "HOME"
Defaults:${kub_admin_user} !requiretty
Defaults:${kub_admin_user} !env_reset
__FILE_CONTENTS__

chown root:root /etc/sudoers.d/${kub_admin_user}
chmod 0440 /etc/sudoers.d/${kub_admin_user}

sed -i 's/PasswordAuthentication\ no/PasswordAuthentication\ yes/g' /etc/ssh/sshd_config
systemctl restart sshd

sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=${public_ip}
mkdir -p /home/${kub_admin_user}/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/${kub_admin_user}/.kube/config
sudo chown ${kub_admin_user}:${kub_admin_group} /home/${kub_admin_user}/.kube/config


sudo -H -u ${kub_admin_user} bash -c  'kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml'

# This keeps ssh key-pair updated
# mkdir -vp /home/${kub_admin_user}/.ssh
# cp /tmp/kubadmin.pub /home/${kub_admin_user}/.ssh/authorized_keys
# chmod 0600 /home/${kub_admin_user}/.ssh/authorized_keys
# chmod 0700 /home/${kub_admin_user}/.ssh
# chown -R ${kub_admin_user}:${kub_admin_group}  /home/${kub_admin_user}
