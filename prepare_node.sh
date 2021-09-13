kubeadm reset -f
systemctl stop firewalld
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
ipvsadm -C
iptables -A INPUT -p tcp --dport 6443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 6443 -m conntrack --ctstate ESTABLISHED -j ACCEPT
swapoff --all
modprobe br_netfilter
modprobe overlay
echo "1" > /proc/sys/net/bridge/bridge-nf-call-iptables

rm -f /opt/cni/bin/weave*
