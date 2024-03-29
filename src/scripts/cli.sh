#!/bin/bash

errorMessage=$1
packageManager=$2

# Foundational CLI tools
cliTools=("bat" "curl" "exa" "git" "htop" "neofetch" "openvpn" "vim" "wget" "zsh")
for cliTool in "${cliTools[@]}"; do
    if [[ -d "/usr/bin/$cliTool" ]]; then
        echo "$cliTool is already installed."
    elif [[ -f "/usr/sbin/$cliTool" ]]; then
        echo "$cliTool is already installed."
    else
        if [[ "$packageManager" = "apt-get" || "$packageManager" = "dnf" ]]; then
            sudo "$packageManager" install "$cliTool" -y
        elif [[ "$packageManager" = "pacman" ]]; then
            sudo pacman -S --noconfirm "$cliTool"
        else
            echo "$cliTool $errorMessage"
        fi
    fi
done

# Flatpak
if [[ "$packageManager" = "apt-get" || "$packageManager" = "dnf" ]]; then
	if [[ -f "/usr/bin/flatpak" ]]; then
		echo "flatpak is already installed."
	else
		sudo "$packageManager" install flatpak -y
	fi

	# Add remote Flathub repos
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

# Python
if [[ -f "/usr/bin/python" || -f "usr/bin/python3" ]]; then
    echo "python3 is already installed."
else
    if [[ "$packageManager" = "apt-get" ]]; then
        sudo apt-get install python3.6 -y
    elif [[ "$packageManager" = "dnf" ]]; then
        sudo dnf install python3 -y
    elif [[ "$packageManager" = "pacman" ]]; then
        sudo pacman -S --noconfirm python3
    else
        echo "Python $errorMessage"
    fi
fi

# Pip
if [[ -f "/usr/bin/pip" || -f "/usr/bin/python-pip" ]]; then
    echo "python-pip is already installed."
else
    if [[ "$packageManager" = "apt-get" ]]; then
        sudo apt-get install python3-pip -y
    elif [[ "$packageManager" = "dnf" ]]; then
        sudo dnf install python3-pip -y
    elif [[ "$packageManager" = "pacman" ]]; then
        sudo pacman -S --noconfirm python-pip
    else
        echo "PIP $errorMessage"
    fi
fi
