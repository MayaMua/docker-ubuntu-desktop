#!/bin/sh
arch=$(dpkg --print-architecture)
codename=$(lsb_release --short --codename)
# update
apt-get update
# Install remote desktop (nomachine,kasmvnc,novnc)
bash /docker_config/install_nomachine.sh
bash /docker_config/install_kasmvnc.sh
bash /docker_config/install_novnc.sh
# Install code server
CODE_VERSION=4.108.2
if [[ $codename == 'bionic' ]]; then
    CODE_VERSION=4.16.1
fi
curl -fSL "https://github.com/coder/code-server/releases/download/v${CODE_VERSION}/code-server_${CODE_VERSION}_${arch}.deb" -o code-server.deb
dpkg -i ./code-server.deb
rm code-server.deb
# Install firefox
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://packages.mozilla.org/apt/repo-signing-key.gpg -o /etc/apt/keyrings/packages.mozilla.org.asc
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" > /etc/apt/sources.list.d/mozilla.list
printf "Package: firefox*\nPin: origin packages.mozilla.org\nPin-Priority: 1001\n" > /etc/apt/preferences.d/mozilla-firefox
apt-get update
apt-get install -y firefox
update-alternatives --set x-www-browser /usr/bin/firefox
# Add Docker APT repository and Install docker cli
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$arch signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $codename stable" > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y docker-ce-cli docker-compose-plugin
