#!/bin/bash

tag=$1

echo "installing kic $tag"

mkdir -p "$HOME/bin"

# update CLI
cd "$HOME/bin" || exit

# remove old CLI
rm -rf kic .kic ds .ds

# use latest release
if [ "$tag" = "" ]; then
    tag=$(curl -s https://api.github.com/repos/cse-labs/res-edge-labs/releases/latest | grep tag_name | cut -d '"' -f4)
fi

# install kic
wget -O kic.tar.gz "https://github.com/cse-labs/res-edge-labs/releases/download/$tag/kic-$tag-linux-amd64.tar.gz"
tar -xvzf kic.tar.gz
rm kic.tar.gz

# install ds
wget -O ds.tar.gz "https://github.com/cse-labs/res-edge-labs/releases/download/$tag/ds-$tag-linux-amd64.tar.gz"
tar -xvzf ds.tar.gz
rm ds.tar.gz

# update completions
kic completion zsh > "$HOME/.oh-my-zsh/completions/_kic"
ds completion zsh > "$HOME/.oh-my-zsh/completions/_ds"

cd "$OLDPWD" || exit

echo ""
echo "run compinit to reload CLI completions"
echo ""
