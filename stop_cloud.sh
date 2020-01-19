# stop nodes and master

ssh green kubeadm reset -f

ssh blue kubeadm reset -f

ssh master kubeadm reset -f

ssh green init 0
ssh blue init 0
ssh master init 0
