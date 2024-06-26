# Dev_Workstation

```                                                 
m     m   mm   mmmmm  mm   m mmmmm  mm   m   mmm 
#  #  #   ##   #   "# #"m  #   #    #"m  # m"   "
" #"# #  #  #  #mmmm" # #m #   #    # #m # #   mm
 ## ##"  #mm#  #   "m #  # #   #    #  # # #    #
 #   #  #    # #    " #   ## mm#mm  #   ##  "mmm"
 ```

I'm winging it, use anything in here at your own risk! This is a draft and includes some bad practices, like piping remote scripts to bash. It's mostly just for my use and as an excercise of configuring things with Ansible. 

This repository contains an Ansible playbook for setting up a development workstation on macOS and Linux. It's very much a work in progress at the moment, and even when functionally done it's likely to change significantly.

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

Configuration options are outlined in the [default.config.yml](./default.config.yml). Inventory file example: 

```
[local]
localhost   ansible_connection=local

[remotes]
169.254.0.200   ansible_user=bob
cool_dev_vm.contoso.com ansible_user=bob
```

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
- [x] Finish setting up main deb stuff.
- [ ] Add the Flatpak tasks
- [ ] Deal with different package naming between fedora/deb (less of an issue than I thought...)
- [ ] See if we can extend to Windows. Looks like chocolatey?
- [ ] Add iterm2 and tilix configs to dotfiles
- [ ] Oh-my-posh install 
