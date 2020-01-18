# prepare the 2 nodes
TOKEN=`kubeadm token create --print-join-command`
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

ssh blue kubeadm reset -f
ssh blue setenforce 0
ssh blue swapoff --all
ssh blue iptables -F
ssh blue iptables -t nat -F
ssh blue iptables -t mangle -F
ssh blue iptables -X
ipvsadm -C

# start new stuff.
ssh green ${TOKEN}
ssh blue ${TOKEN}
