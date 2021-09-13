# make sure to have entropy...
service rngd start
#/sbin/rngd -f -r /dev/urandom -o /dev/random

# reset old conf.
kubeadm reset -f
systemctl stop firewalld
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
ipvsadm -C
iptables -A INPUT -p tcp --dport 6443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 6443 -m conntrack --ctstate ESTABLISHED -j ACCEPT
swapoff --all
modprobe br_netfilter
modprobe overlay
echo "1" > /proc/sys/net/bridge/bridge-nf-call-iptable

# start new one.
echo ""
echo "starting with kubeadm init!!!"
echo ""
#kubeadm init --token=102952.1a7dd4cc8d1f4cc5 --kubernetes-version $(kubeadm version -o short)
kubeadm init --config kubeadm-config.yaml

rm -rf $HOME/.kube
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl get nodes

#Network 10.32.0.0/12 overlaps with existing route 10.33.144.0/24 on host
#  kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')&env.IPALLOC_RANGE=10.32.0.0/16"
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')&env.IPALLOC_RANGE=10.32.0.0/16"
