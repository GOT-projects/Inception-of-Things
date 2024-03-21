#!/bin/sh

echo [1] mv id_rsa
mv /home/vagrant/tmp/id_rsa /home/vagrant/.ssh/id_rsa

echo [2] mv id_rsa.pub
mv /home/vagrant/tmp/id_rsa.pub /home/vagrant/.ssh/id_rsa.pub

echo [3] get authorized_keys
cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys

echo [4] chmod
chmod 400 /home/vagrant/.ssh/id_rsa.pub
chmod 400 /home/vagrant/.ssh/id_rsa
chmod 400 /home/vagrant/.ssh/authorized_keys

current_ip=$(/sbin/ip -o -4 addr list eth1 | awk '{print $4}' | cut -d/ -f1)
echo [5] ip ${current_ip}
echo [INFO] hostname $(hostname)

if [ $(hostname) = "rcuminalS" ]
    then
        echo [6] install k3s
        curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--bind-address=${current_ip} --flannel-iface=eth1 --write-kubeconfig-mode 644" sh -
    else
        echo [6] "get token  shh vagrant@192.168.56.110 | install k3s"
        TOKEN=$(ssh -o StrictHostKeyChecking=no -i /home/vagrant/.ssh/id_rsa vagrant@192.168.56.110 "sudo cat /var/lib/rancher/k3s/server/node-token")

        export K3S_TOKEN="$TOKEN"
        export K3S_URL="https://192.168.56.110:6443"
        echo "token ${K3S_TOKEN}"
        export INSTALL_K3S_EXEC="agent --flannel-iface=eth1 "
        curl -sfL https://get.k3s.io |  sh -
fi

echo [7] waiting k3s
sleep 15
