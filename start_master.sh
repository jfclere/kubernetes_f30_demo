kubeadm reset
systemctl stop firewalld
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
ipvsadm -C
iptables -A INPUT -p tcp --dport 6443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 6443 -m conntrack --ctstate ESTABLISHED -j ACCEPT
swapoff --all
kubeadm init --token=102952.1a7dd4cc8d1f4cc5 --kubernetes-version $(kubeadm version -o short)
rm -rf $HOME/.kube
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl get nodes
kubectl apply -f weave-kube.yaml
