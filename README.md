# dev_workstation

An Ansible playbook for automated workstation setup.

> Hobby project. Run at your own risk. Fork freely.

[![CI](https://github.com/qovert/dev_workstation/workflows/CI/badge.svg)](https://github.com/qovert/dev_workstation/actions)

## Supported platforms

| Platform | Status |
|---|---|
| Fedora 41+ | Primary |
| macOS (Apple Silicon / Intel) | Secondary |
| Debian / Ubuntu | Untested |

## Quick start

### Fedora

```bash
sudo dnf install ansible
ansible-galaxy collection install -r requirements.yml
ansible-playbook main.yml -i localhost, -c local --ask-become-pass
```

### macOS

```bash
pip3 install ansible
ansible-galaxy collection install -r requirements.yml
ansible-galaxy role install -r requirements.yml
ansible-playbook main.yml -i localhost, -c local --ask-become-pass
```

## Configuration

Personal values go in `config.yml` (git-ignored, not committed):

```bash
cp default.config.yml config.yml
# edit config.yml
```

The minimum required setting:

```yaml
github_username: "your-github-username"
```

Alternatively, export `GITHUB_USERNAME` in your shell and skip `config.yml` entirely.

All other values in `default.config.yml` are reasonable defaults — override only what you need in `config.yml`.

## What it does

### All platforms
- Installs and initialises [chezmoi](https://www.chezmoi.io/) from `github.com/<github_username>/dotfiles`
- Downloads oh-my-posh themes

### Fedora
- Bootstraps DNF Python bindings (`python3-libdnf5`) for Ansible on Fedora 41+
- Adds repositories: Microsoft (PowerShell/dotnet), VS Code, 1Password, RPM Fusion (free + nonfree), Terra
- Upgrades the core group for AppStream metadata
- Installs DNF packages (see `fedora_packages` in `default.config.yml`)
- Adds Flathub (system + user remotes) and installs Flatpak apps per-user

### macOS
- Installs Homebrew, formulae, and casks via [geerlingguy.homebrew](https://github.com/geerlingguy/ansible-role-homebrew)
- Optionally installs App Store apps via [geerlingguy.mas](https://github.com/geerlingguy/ansible-role-mas) (`configure_mas: true`)
- Configures system defaults (Dock auto-hide, icon size, VS Code key repeat)
- Manages Dock items via [geerlingguy.mac.dock](https://github.com/geerlingguy/ansible-collection-mac)

## Feature flags

Set these in `config.yml` to enable/disable sections:

```yaml
configure_dotfiles: true   # chezmoi setup
configure_linux: true      # Fedora/Debian tasks
configure_macos: true      # macOS tasks
configure_mas: false       # App Store (requires prior sign-in)
configure_dock: true       # macOS Dock management
```

## Project structure

```
dev_workstation/
├── roles/
│   ├── packages/          # Repo setup + DNF/APT package installation
│   │   ├── tasks/
│   │   │   ├── main.yml
│   │   │   ├── fedora.yml
│   │   │   └── debian.yml   # untested
│   │   └── defaults/
│   ├── apps/              # Flatpak (Fedora) and cask/MAS (macOS)
│   │   └── tasks/
│   │       ├── main.yml
│   │       └── fedora.yml
│   ├── dotfiles/          # chezmoi install, init, apply
│   │   └── tasks/
│   └── system/            # OS-level config (macOS defaults, Dock)
│       ├── tasks/
│       └── handlers/
├── molecule/              # Integration tests (Fedora container)
├── .github/workflows/     # CI (lint + syntax + molecule)
├── main.yml               # Playbook entry point
├── default.config.yml     # Default configuration (commit this)
├── config.yml             # Personal overrides (git-ignored, create this)
├── requirements.yml       # Ansible collections and macOS roles
└── ansible.cfg
```

## Tags

Run specific roles without executing the full playbook:

```bash
ansible-playbook main.yml -i localhost, -c local --ask-become-pass --tags packages
ansible-playbook main.yml -i localhost, -c local --ask-become-pass --tags apps
ansible-playbook main.yml -i localhost, -c local --ask-become-pass --tags dotfiles
ansible-playbook main.yml -i localhost, -c local --ask-become-pass --tags system
```

## Linting / CI

```bash
yamllint .
ansible-lint
ansible-playbook main.yml --syntax-check
molecule test   # requires Docker
```

## License

MIT
