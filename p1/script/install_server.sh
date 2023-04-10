#!/usr/bin/env sh

sudo -s
IP_ADRR=$(/sbin/ip -o -4 addr list eth1 | awk '{print $4}' | cut -d / -f1)
echo "[3] export ip ${IP_ADRR}"

export INSTALL_K3S_EXEC="--bind-address=${IP_ADRR} --flannel-iface=eth1 --write-kubeconfig-mode 644"
echo "[4] config K3S: ${INSTALL_K3S_EXEC}"

echo "[5] Install k3s"
curl -sfL https://get.k3s.io | sh -s


echo "[6] Waiting k3s running"
sleep 10
kubeclt get nodes -o wide
