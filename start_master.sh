ping -c 1 -w 10 green
if [ $? -ne 0 ]; then
  echo "Node: green not up, please check..."
  exit 1
fi
ping -c 1 -w 10 blue
if [ $? -ne 0 ]; then
  echo "Node: blue not up, please check..."
  exit 1
fi
ping -c 1 -w 10 master
if [ $? -ne 0 ]; then
  echo "Node: master (self) not up, please check..."
  exit 1
fi

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

# start new one.
echo ""
echo "starting with kubeadm init!!!"
echo ""
#kubeadm init --token=102952.1a7dd4cc8d1f4cc5 --kubernetes-version $(kubeadm version -o short)
kubeadm init
rm -rf $HOME/.kube
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl get nodes
kubectl apply -f weave-kube.yaml
