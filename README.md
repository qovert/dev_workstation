# Dev_Workstation

                                                 
m     m   mm   mmmmm  mm   m mmmmm  mm   m   mmm 
#  #  #   ##   #   "# #"m  #   #    #"m  # m"   "
" #"# #  #  #  #mmmm" # #m #   #    # #m # #   mm
 ## ##"  #mm#  #   "m #  # #   #    #  # # #    #
 #   #  #    # #    " #   ## mm#mm  #   ##  "mmm"

I'm winging it, use anything in here at your own risk! 

This repository contains an Ansible playbook for setting up a development workstation on macOS and Linux.

## Description

The playbook includes tasks for installing and configuring various development tools and utilities.

## Requirements

- Ansible 2.9 or higher
- macOS or Linux operating system
- Up to date [ansible.community.general](https://docs.ansible.com/ansible/latest/collections/community/general/index.html) collection.

Hint on that last one:

```bash
ansible-galaxy collection install community.general --upgrade
```

## Usage

1. Clone this repository to your local machine.
2. Navigate to the repository directory.
3. Run the playbook using the following command:

```bash
ansible-playbook playbook.yml -i inventory/hosts
```

## Configuration

Configuration options are outlined in the [default.config.yml](./default.config.yml). 

### Notable options:

- configure dotfiles: Installs [chezmoi](https://www.chezmoi.io/) and pulls dotfiles from the repo specified in the GITHUB_USERNAME environment variable.
- configure_macos: Runs macOS install tasks.
- configure_linux: Runs Linux (Fedora/PopOS! tested) configuration tasks.
- mac_packages: [Homebrew](https://brew.sh/) formulae.
- mac_cask_packages: [Homebrew](https://brew.sh/) cask packages.
- linux_packages: pretty self explanatory. Currently supports dnf|apt.
- linux_flatpak_packages: Same as above only [Flatpak](https://www.flatpak.org/).

## ToDo

- [ ] Follow my own dang advice and don't pipe scripts to shell over the internet 😧
- [ ] Finish setting up deb stuff.
- [ ] See if we can extend to Windows. Loooks like chocolatey?
- [ ] Add iterm2 and tilix configs to dotfiles
