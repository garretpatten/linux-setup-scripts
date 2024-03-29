#!/bin/bash

errorMessage=$1
packageManager=$2
workingDirectory=$3

# Git Config
if [[ ! -f "$HOME/.gitconfig" ]]; then
    git config --global credential.helper store
    git config --global user.email "garret.patten@proton.me"
    git config --global user.name "Garret Patten"
    git config --global pull.rebase false
fi

# Vim Config
cp "$workingDirectory/src/config-files/vim/.vimrc" ~/.vimrc
cp "$workingDirectory/src/config-files/nvim/init.vim" ~/.config/nvim/init.vim

echo "Pre Docker stuff"

# Docker and Docker-Compose
if [[ "$packageManager" = "apt-get" ]]; then
    sudo apt-get update -y
    sudo apt-get install apt-transport-https ca-certificates software-properties-common -y
    sudo apt-get install docker.io -y

    sudo apt-get install docker-compose -y
    docker image pull archlinux
    docker image pull fedora
elif [[ "$packageManager" = "dnf" ]]; then
    sudo dnf -y install dnf-plugins-core
    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    sudo dnf install docker-compose -y
    docker image pull archlinux
    docker image pull ubuntu
elif [[ "$packageManager" = "pacman" ]]; then
    sudo pacman -S --noconfirm gnome-terminal
    sudo pacman -S --noconfirm docker

    sudo pacman -S --noconfirm docker-compose
    docker image pull fedora
    docker image pull ubuntu
else
    echo "Support not yet added for this package manager."
fi

# GitHub CLI
if [[ -f "/usr/local/bin/gh" ]]; then
    echo "gh is already installed."
else
    if [[ "$packageManager" = "pacman" ]]; then
        sudo pacman -S --noconfirm gh
    else
        sudo "$packageManager" install gh -y
    fi
fi

# Node.js
if [[ "$packageManager" = "apt-get" ]]; then
    # nosemgrep: bash.curl.security.curl-pipe-bash.curl-pipe-bash Installation comes from Debian docs
    curl -sL https://deb.nodesource.com/setup_18.x | sudo bash -
    sudo apt-get install nodejs -y
    #  NVM
    # nosemgrep: bash.curl.security.curl-pipe-bash.curl-pipe-bash Installation comes from Debian docs
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
elif [[ "$packageManager" = "dnf" ]]; then
    sudo dnf module install nodejs:18/common -y
elif [[ "$packageManager" = "pacman" ]]; then
    sudo pacman -S --noconfirm nodejs
    sudo pacman -S --noconfirm npm
else
    echo "Node $errorMessage"
fi

# Vue.js
if [[ -f "/usr/local/bin/vue" ]]; then
    echo "Vue is already installed."
else
    sudo npm install -g @vue/cli
fi

# Semgrep
if [[ -f "$HOME/.local/bin/semgrep" ]]; then
    echo "Semgrep is already installed."
else
    if [[ "$packageManager" = "apt-get" ]]; then
        echo "Support not yet added for apt."
    elif [[ "$packageManager" = "dnf" ]]; then
        python3 -m pip install semgrep
    elif [[ "$packageManager" = "pacman" ]]; then
        sudo pacman -S python-semgrep --no-confirm
    else
        echo "Semgrep $errorMessage"
    fi
fi

# Sourcegraph CLI
if [[ -f "/usr/local/bin/src" ]]; then
    echo "Sourcegraph CLI is already installed."
else
    curl -L https://sourcegraph.com/.api/src-cli/src_linux_amd64 -o /usr/local/bin/src
    chmod +x /usr/local/bin/src
fi


# Postman
if [[ "$packageManager" = "dnf" ]]; then
    flatpak install flathub com.getpostman.Postman -y
elif [[ "$packageManager" = "pacman" ]]; then
    yay -S --noconfirm postman-bin
else
    echo "Postman $errorMessage"
fi

# VS Code
if [[ -f "/usr/bin/code" ]]; then
    echo "VS Code is already installed."
else
    isInstalled="true"
    if [[ "$packageManager" = "apt-get" ]]; then
        cd ~/Downloads || return

        wget "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg

        cd "$workingDirectory" || return

        sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
        sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

        sudo apt-get install apt-transport-https -y
        sudo apt-get update -y
        sudo apt-get install code -y
    elif [[ "$packageManager" = "dnf" ]]; then
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
        sudo dnf check-update -y
        sudo dnf install code -y
    elif [[ "$packageManager" = "pacman" ]]; then
        sudo pacman -S --noconfirm code
    else
        isInstalled="false"
        echo "VS Code $errorMessage"
    fi

    if [[ "$isInstalled" = "true" ]]; then
        cp "$workingDirectory/src/config-files/vs-code/settings.json" ~/.config/'Code - OSS'/User/settings.json
    fi
fi

# Fira Code
if [[ -d "/usr/share/fonts/FiraCode/" ]]; then
    echo "Fira Code is already installed."
    if [[ "$packageManager" = "pacman" ]]; then
        cd ~/Downloads || return

        git clone https://aur.archlinux.org/ttf-firacode.git
        cd ttf-firacode || return
        makepkg -sri --noconfirm

        cd "$workingDirectory" || return
    else
        echo "Fira Code $errorMessage"
    fi
fi
