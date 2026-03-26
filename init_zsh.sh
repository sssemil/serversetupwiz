#!/bin/bash

set -e
set -x

if ! command -v zsh &> /dev/null; then
    echo "zsh not found, installing..."
    if command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm zsh
    elif command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y zsh
    else
        echo "Unsupported package manager. Install zsh manually."
        exit 1
    fi
fi

if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Setting zsh as default shell..."
    sudo chsh -s "$(which zsh)" "$USER"
fi

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

cat <<EOF > ~/.zshrc
export PATH=\$HOME/bin:/usr/local/bin:\$PATH
export ZSH="\$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)
source \$ZSH/oh-my-zsh.sh
EOF
