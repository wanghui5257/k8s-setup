# 安装k8s

## 说明

基于当前v1.13.3版本
基于ubuntu
All in ONE
绝对不翻墙！
我用的机器是一台老笔记本ThinkPad X201，4核8GB，标准的Java虚机配置，用来跑kubernetes尚可。操作系统是ubuntu 16.04 Desktop版本，更新到最新。这台机器特意没有配置任何翻墙工具。

## 准备工作

### 1)更换apt源为163

```bash
$ cat /etc/apt/sources.list
deb http://mirrors.163.com/ubuntu/ xenial main
deb-src http://mirrors.163.com/ubuntu/ xenial main

deb http://mirrors.163.com/ubuntu/ xenial-updates main
deb-src http://mirrors.163.com/ubuntu/ xenial-updates main

deb http://mirrors.163.com/ubuntu/ xenial universe
deb-src http://mirrors.163.com/ubuntu/ xenial universe
deb http://mirrors.163.com/ubuntu/ xenial-updates universe
deb-src http://mirrors.163.com/ubuntu/ xenial-updates universe

deb http://mirrors.163.com/ubuntu/ xenial-security main
deb-src http://mirrors.163.com/ubuntu/ xenial-security main
deb http://mirrors.163.com/ubuntu/ xenial-security universe
deb-src http://mirrors.163.com/ubuntu/ xenial-security universe
```

### 2)安装docker

```bash
apt install docker.io -y
```

### 3)增加kubernetes aliyun镜像源

``` bash
apt-get update && apt-get install -y apt-transport-https
curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add - 
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF
```

## 开始安装

### 第一步 安装kubeadm/kubelet/kubectl

```bash
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
如果你有多台机器，非master节点不需要安装kubeadm/kubectl。当然装了也没啥坏处.。
```

### 第二步 关闭swap

```bash
kubernetes要求必须关闭swap。
swapoff -a
```

### 第三步 配置docker mirror

```bash
创建（或修改）/etc/docker/daemon.json。官方中国镜像速度还行。
{
"registry-mirrors": ["https://registry.docker-cn.com"]
}
重启docker服务 
systemctl restart docker
```

### 第四步 拉取k8s的对应版本的包

```bash
首先查询下当前版本需要哪些docker image。
$ kubeadm config images list --kubernetes-version 1.13.3
k8s.gcr.io/kube-apiserver-amd64:1.13.3
k8s.gcr.io/kube-controller-manager-amd64:1.13.3
k8s.gcr.io/kube-scheduler-amd64:1.13.3
k8s.gcr.io/kube-proxy-amd64:1.13.3
k8s.gcr.io/pause:3.1
k8s.gcr.io/etcd-amd64:3.2.18
k8s.gcr.io/coredns:1.1.3
必须要指定版本，这样kubeadm才不会去连k8s.io。kubeadm init同理。

推荐使用anjia0532的docker镜像，机器人自动跟官方同步，非常及时。
docker pull anjia0532/google-containers.kube-controller-manager-amd64:1.13.3
docker pull anjia0532/google-containers.kube-apiserver-amd64:1.13.3
docker pull anjia0532/google-containers.kube-scheduler-amd64:1.13.3
docker pull anjia0532/google-containers.kube-proxy-amd64:1.13.3
docker pull anjia0532/google-containers.pause:3.1
docker pull anjia0532/google-containers.etcd-amd64:3.2.18
docker pull anjia0532/google-containers.coredns:1.1.3
重新打包本地docker镜像，主要与kubeadm安装时默认镜像一致
docker tag anjia0532/google-containers.kube-controller-manager-amd64:1.13.3 k8s.gcr.io/kube-controller-manager-amd64:1.13.3
docker tag anjia0532/google-containers.kube-apiserver-amd64:1.13.3 k8s.gcr.io/kube-apiserver-amd64:1.13.3
docker tag anjia0532/google-containers.kube-scheduler-amd64:1.13.3 k8s.gcr.io/kube-scheduler-amd64:1.13.3
docker tag anjia0532/google-containers.kube-proxy-amd64:1.13.3 k8s.gcr.io/kube-proxy-amd64:1.13.3
docker tag anjia0532/google-containers.pause:3.1 k8s.gcr.io/pause:3.1
docker tag anjia0532/google-containers.etcd-amd64:3.2.18 k8s.gcr.io/etcd-amd64:3.2.18
docker tag anjia0532/google-containers.coredns:1.1.3 k8s.gcr.io/coredns:1.1.3
删除不需要的本地镜像
docker rmi anjia0532/google-containers.kube-controller-manager-amd64:1.13.3
docker rmi anjia0532/google-containers.kube-apiserver-amd64:1.13.3
docker rmi anjia0532/google-containers.kube-scheduler-amd64:1.13.3
docker rmi anjia0532/google-containers.kube-proxy-amd64:1.13.3
docker rmi anjia0532/google-containers.pause:3.1
docker rmi anjia0532/google-containers.etcd-amd64:3.2.18
docker rmi anjia0532/google-containers.coredns:1.1.3
```

### 第五步 开始通过kubeadm安装

```bash
kubeadm init --kubernetes-version 1.13.3
我这里准备使用weave Network（主要是想用下weave scope，它只支持weave类型的网络）。
注意如果是flannel网络方案，必须要设置--pod-network-cidr 10.244.0.0/16，其他类型的网络，请参考官方的说明。
安装成功后，按照提示执行下面的命令
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### 第六步 部署flannel网络

```bash
sysctl net.bridge.bridge-nf-call-iptables=1 -w
kubectl apply -f kube-flannel.yaml
```
