# Ansible playbook to setup my personal laptop

This playbook is idempotent, and should work with PoP!_OS, Fedora 39+, and ideally MacOS. If there's interest, I can add try to support for Windows 10+ as well.

## This playbook will install the following

- **MacOS only**
  - Homebrew
  - Docker / Docker Compose
  - Firefox
  - Ansible
  - Git
  - Zsh
  - Oh My Posh
  - PowerShell 7+
- **Linux only**
  - Distrobox
  - flatpak
  - Visual Studio Code
  - Microsoft Edge
  - Wireguard client
- **Personal devices only**
  - Nextcloud client
  - Utils: nmap, vim, htop, wget, tmux, ncdu, tree

## This playbook will also configure the following

- Zsh as the default shell
- Oh My Posh theme
- dotfiles (chezmoi): .zshrc, .vimrc, .tmux.conf, .gitconfig
