#/usr/bin/bash
# > date 2022-1-12
# > BY hukenis

yum -y  install git wget

sudo wget https://hub.fastgit.org/cloudflare/cfssl/releases/download/1.2.0/cfssl_linux-amd64 -O /usr/local/bin/cfssl

sudo wget https://hub.fastgit.org/cloudflare/cfssl/releases/download/1.2.0/cfssljson_linux-amd64 -O /usr/local/bin/cfssljson

sudo chmod a+x /usr/local/bin/cfssl*

sudo mkdir -p /etc/etcd/ssl

git clone https://hub.fastgit.org/hlions/k8scerts.git

