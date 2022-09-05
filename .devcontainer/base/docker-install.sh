apt-get update

# 一時フォルダ作成
mkdir /tmp/itoc-docker

# 依存関係インストール
apt-get install -y iptables=1.8.4-3ubuntu2 libdevmapper1.02.1=2:1.02.167-1ubuntu1
# パッケージファイルDL
curl -o /tmp/itoc-docker/docker-ce_20.10.11~3-0~ubuntu-focal_amd64.deb \
     https://download.docker.com/linux/ubuntu/dists/focal/pool/stable/amd64/docker-ce_20.10.11~3-0~ubuntu-focal_amd64.deb && \
curl -o /tmp/itoc-docker/docker-ce-cli_20.10.11~3-0~ubuntu-focal_amd64.deb \
     https://download.docker.com/linux/ubuntu/dists/focal/pool/stable/amd64/docker-ce-cli_20.10.11~3-0~ubuntu-focal_amd64.deb && \
curl -o /tmp/itoc-docker/containerd.io_1.4.12-1_amd64.deb \
     https://download.docker.com/linux/ubuntu/dists/focal/pool/stable/amd64/containerd.io_1.4.12-1_amd64.deb
# インストール
dpkg -i /tmp/itoc-docker/docker-ce-cli_20.10.11~3-0~ubuntu-focal_amd64.deb && \
dpkg -i /tmp/itoc-docker/containerd.io_1.4.12-1_amd64.deb && \
dpkg -i /tmp/itoc-docker/docker-ce_20.10.11~3-0~ubuntu-focal_amd64.deb

# 一時フォルダ削除
rm -rf /tmp/itoc-docker

