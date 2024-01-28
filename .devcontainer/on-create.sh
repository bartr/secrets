#!/bin/bash

echo "on-create start" >> ~/status

# Change shell to zsh for vscode
sudo chsh --shell /bin/zsh vscode

sudo apt-get update

export KIC_BASE=$PWD

{
    echo "export KIC_BASE=$PWD"
} >> "$HOME/.zshrc"

# pull docker base images
docker pull golang:latest

# configure git
git config --global core.whitespace blank-at-eol,blank-at-eof,space-before-tab
git config --global pull.rebase false
git config --global init.defaultbranch main
git config --global fetch.prune true
git config --global core.pager more
git config --global diff.colorMoved zebra
git config --global devcontainers-theme.show-dirty 1
git config --global core.editor "nano -w"

echo "installing kic" >> ~/status
.devcontainer/cli-update.sh

echo "generating completions" >> ~/status
gh completion -s zsh > ~/.oh-my-zsh/completions/_gh
kubectl completion zsh > "$HOME/.oh-my-zsh/completions/_kubectl"
k3d completion zsh > "$HOME/.oh-my-zsh/completions/_k3d"

echo "create local registry" >> ~/status
docker network create k3d
k3d registry create registry.localhost --port 5500
docker network connect k3d k3d-registry.localhost

echo "install latest K3d" >> ~/status
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

echo "kic cluster create" >> ~/status
kic cluster create

# only run apt upgrade on pre-build
if [ "$CODESPACE_NAME" = "null" ]
then
    echo "$(date +'%Y-%m-%d %H:%M:%S')    upgrading" >> "$HOME/status"
    sudo apt-get upgrade -y
fi

echo "on-create complete" >> ~/status
