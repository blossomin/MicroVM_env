sysctl net.ipv4.ip_forward=1
modprobe -v loop
sysctl net.bridge.bridge-nf-call-iptables=0


export CNI_VERSION=v0.9.1
export ARCH=$([ $(uname -m) = "x86_64" ] && echo amd64 || echo arm64)
sudo mkdir -p /opt/cni/bin
curl -sSL https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-${ARCH}-${CNI_VERSION}.tgz | sudo tar -xz -C /opt/cni/bin

yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo && yum install -y containerd.io docker

yum install -y e2fsprogs openssh-clients git
which containerd || ( yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo && yum install -y containerd.io )
echo "containerd finished.."

release_url="https://github.com/firecracker-microvm/firecracker/releases"
latest=$(basename $(curl -fsSLI -o /dev/null -w  %{url_effective} ${release_url}/latest))
arch=`uname -m`
curl -L ${release_url}/download/${latest}/firecracker-${latest}-${arch}.tgz \
| tar -xz

mv release-${latest}-$(uname -m)/firecracker-${latest}-$(uname -m) firecracker

chmod +x firecracker
sudo mv firecracker /usr/bin
echo "Firecracker finished.."

curl -Lo footloose https://github.com/weaveworks/footloose/releases/download/0.6.3/footloose-0.6.3-linux-x86_64
chmod +x footloose
sudo mv footloose /usr/bin/
echo "footloose finished.."


export VERSION=v0.10.0
export GOARCH=$(go env GOARCH 2>/dev/null || echo "amd64")

for binary in ignite ignited; do
    echo "Installing ${binary}..."
    curl -sfLo ${binary} https://github.com/weaveworks/ignite/releases/download/${VERSION}/${binary}-${GOARCH}
    chmod +x ${binary}
    sudo mv ${binary} /usr/bin
done

systemctl enable containerd
systemctl start containerd
