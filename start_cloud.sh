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
ssh master service rngd start
#/sbin/rngd -f -r /dev/urandom -o /dev/random

# reset old conf.
ssh master kubeadm reset -f
ssh master systemctl stop firewalld
ssh master iptables -F
ssh master iptables -t nat -F
ssh master iptables -t mangle -F
ssh master iptables -X
ssh master ipvsadm -C
ssh master iptables -A INPUT -p tcp --dport 6443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
ssh master iptables -A OUTPUT -p tcp --sport 6443 -m conntrack --ctstate ESTABLISHED -j ACCEPT
ssh master swapoff --all
ssh master modprobe br_netfilter

# start new one.
echo ""
echo "starting with kubeadm init!!!"
echo ""
ssh master kubeadm init
rm -rf $HOME/.kube
mkdir -p $HOME/.kube
scp root@master:/etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f weave-kube.yaml

echo ""
echo "Checking master"
echo ""
while true
do
  kubectl get nodes | grep master | grep NotReady
  if [ $? -ne 0 ]; then
    echo "master ready..."
    break
  sleep 5
  fi
done
kubectl get nodes

# prepare the 2 nodes
ssh master rm -rf $HOME/.kube
ssh master mkdir -p $HOME/.kube
ssh master cp /etc/kubernetes/admin.conf $HOME/.kube/config

TOKEN=`ssh master kubeadm token create --print-join-command`
echo "Using: ${TOKEN}"

# stop old running kubernetes on nodes.
ssh green kubeadm reset -f
ssh green setenforce 0
ssh green swapoff --all
ssh green iptables -F
ssh green iptables -t nat -F
ssh green iptables -t mangle -F
ssh green iptables -X
ssh green ipvsadm -C
ssh green modprobe br_netfilter

ssh blue kubeadm reset -f
ssh blue setenforce 0
ssh blue swapoff --all
ssh blue iptables -F
ssh blue iptables -t nat -F
ssh blue iptables -t mangle -F
ssh blue iptables -X
ssh blue ipvsadm -C
ssh blue modprobe br_netfilter

# start new stuff.
ssh green ${TOKEN}
ssh blue ${TOKEN}

echo ""
echo "Checking nodes"
echo ""
kubectl get nodes
