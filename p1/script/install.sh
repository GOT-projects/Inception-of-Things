#!/bin/sh

# Deploy keys to allow all nodes to connect each others as root

chmod 400 ~/.ssh/.id_rsa.pub
chmod 400 ~/.ssh/d_rsa
chown root:root  /home/vagrant/id_rsa.pub
chown root:root  /home/vagrant/id_rsa

cat /home/vagrant/id_rsa.pub >> /root/.ssh/authorized_keys
chmod 400 /home/vagrant/authorized_keys
chown root:root /home/vagrant/authorized_keys

# Add current node in  /etc/hosts
echo "127.0.1.1 $(hostname)" >> /etc/hosts

# Get current IP adress to launch k3S
current_ip=$(/sbin/ip -o -4 addr list eth1 | awk '{print $4}' | cut -d/ -f1)

# If we are on first node, launch k3s with cluster-init, else we join the existing cluster
if [ $(hostname) = "jmilhasS" ]
    then
        curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --bind-address=${current_ip} --flannel-iface=eth1 --write-kubeconfig-mode 644  --no-deploy=traefik" sh -
else
    echo "10.0.0.11  jmilhasK" >> /etc/hosts
    scp -o StrictHostKeyChecking=no root@jmilhasS:/var/lib/rancher/k3s/server/token /tmp/token
    curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --server https://jmilhasS:6443 --token-file /tmp/token --bind-address=${current_ip} --no-deploy=traefik" sh -
fi

# Wait for node to be ready and disable deployments on it
sleep 15
kubectl get node -o wide
