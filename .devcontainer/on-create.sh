#!/bin/bash

# this runs as part of pre-build

echo "on-create start"
echo "$(date +'%Y-%m-%d %H:%M:%S')    on-create start" >> "$HOME/status"

# Change shell to zsh for vscode
sudo chsh --shell /bin/zsh vscode

{
    echo ""
    echo "source \$HOME/kic.env"
    echo ""
    echo "compinit"
} >> "$HOME/.zshrc"

{
    echo ""

    #shellcheck disable=2016,2028
    echo 'hsort() { read -r; printf "%s\\n" "$REPLY"; sort }'
    echo "alias kuse='kubectl config use-context'"
    echo ""

    # add cli to path
    echo "export KIC_BASE=$PWD"
    echo "export KIC_REPO_FULL=\$(git remote get-url --push origin)"
    echo "export KIC_BRANCH=\$(git branch --show-current)"
    echo ""

    echo "if [ \"\$KIC_PAT\" != \"\" ]; then"
    echo "    export GITHUB_TOKEN=\$KIC_PAT"
    echo "fi"
    echo ""

    echo "if [ \"\$PAT\" != \"\" ]; then"
    echo "    export GITHUB_TOKEN=\$PAT"
    echo "fi"
    echo ""

    echo "export KIC_PAT=\$GITHUB_TOKEN"
    echo "export PAT=\$GITHUB_TOKEN"
    echo ""

    echo "export MY_BRANCH=\$(echo \$GITHUB_USER | tr '[:upper:]' '[:lower:]')"
} > "$HOME/kic.env"

# configure git
git config --global core.whitespace blank-at-eol,blank-at-eof,space-before-tab
git config --global pull.rebase false
git config --global init.defaultbranch main
git config --global fetch.prune true
git config --global core.pager more
git config --global diff.colorMoved zebra
git config --global devcontainers-theme.show-dirty 1
git config --global core.editor "nano -w"

echo "dowloading kic and ds CLIs"
.devcontainer/cli-update.sh

echo "installing dotnet coverage tool"
dotnet tool install --global dotnet-reportgenerator-globaltool --version 5.1.22

echo "generating completions"
gh completion -s zsh > ~/.oh-my-zsh/completions/_gh
kubectl completion zsh > "$HOME/.oh-my-zsh/completions/_kubectl"
k3d completion zsh > "$HOME/.oh-my-zsh/completions/_k3d"

echo "create local registry"
docker network create k3d
k3d registry create registry.localhost --port 5500
docker network connect k3d k3d-registry.localhost

echo "kic cluster create"
kic cluster create

echo "Pulling docker images"
docker pull golang:latest

sudo apt-get update

# only run apt upgrade on pre-build
if [ "$CODESPACE_NAME" = "null" ]
then
    echo "$(date +'%Y-%m-%d %H:%M:%S')    upgrading" >> "$HOME/status"
    sudo apt-get upgrade -y
fi

echo "on-create complete"
echo "$(date +'%Y-%m-%d %H:%M:%S')    on-create complete" >> "$HOME/status"
