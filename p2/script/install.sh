#!/bin/sh

current_ip=$(/sbin/ip -o -4 addr list eth1 | awk '{print $4}' | cut -d/ -f1)
echo [1] ip ${current_ip}
echo [INFO] hostname $(hostname)
echo [2] install k3s
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--bind-address=${current_ip} --flannel-iface=eth1 --write-kubeconfig-mode 644" sh -

sleep 42;

echo [3] deploy services app1
kubectl apply -f ./deploy_app.yml

echo [4] deploy services app2
kubectl apply -f ./deploy_app1.yml

echo [5] deploy services ingress
kubectl apply -f ./deploy_ingress.yml

echo [6] waiting k3s
kubectl wait --for=condition=Ready --timeout=600s pod --all 
