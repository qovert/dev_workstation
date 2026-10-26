# dev_workstation

An Ansible playbook for automated workstation setup.

> Hobby project. Run at your own risk. Fork freely.

[![CI](https://github.com/qovert/dev_workstation/workflows/CI/badge.svg)](https://github.com/qovert/dev_workstation/actions)

## Supported platforms

| Platform | Status |
|---|---|
| Fedora 41+ | Primary |
| Fedora Silverblue 41+ | Primary |
| macOS (Apple Silicon / Intel) | Secondary |
| Debian / Ubuntu | Untested |

## Quick start

### Fedora

```bash
sudo dnf install ansible
ansible-galaxy collection install -r requirements.yml
ansible-playbook main.yml -i localhost, -c local --ask-become-pass
```

### Fedora Silverblue

`pip` and `pipx` are not included in the base Silverblue image. Layer `pipx` onto the host first, then reboot:

```bash
sudo rpm-ostree install pipx
systemctl reboot
```

After rebooting, run the bootstrap script **from the host** (not from inside a toolbox):

```bash
bash bootstrap.sh
```

The script installs Ansible via `pipx`, installs Galaxy dependencies, and runs the playbook. It will prompt for your sudo password to handle `rpm-ostree` layering and Flatpak setup.

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
- Installs oh-my-posh (Linux: release binary to `~/.local/bin`) and downloads its themes

### Fedora
- Bootstraps DNF Python bindings (`python3-libdnf5`) for Ansible on Fedora 41+
- Adds repositories: Microsoft (PowerShell/dotnet), VS Code, 1Password, RPM Fusion (free + nonfree)
- Upgrades the core group for AppStream metadata
- Installs DNF packages (see `fedora_packages` in `default.config.yml`)
- Adds Flathub (system + user remotes) and installs Flatpak apps per-user

### Fedora sway session (`configure_sway: true`)
- Installs sway, waybar, fuzzel, swaylock/swayidle, mako, cliphist and portals as an extra GDM session; GNOME stays as it is
- Adds the lizardbyte COPR and installs [Sunshine](https://github.com/LizardByte/Sunshine) for Moonlight streaming, with uinput access for remote input
- Optional (`sway_enable_wayvnc: true`): sets up [wayvnc](https://github.com/any1/wayvnc) password (PAM) auth and
  generates its RSA key, as a VNC fallback with clipboard sync. Off by default; its `exec` in the sway config is
  commented out
- The sway, waybar and Sunshine configs, the `remote-on`/`remote-off` scripts, and the systemd user units live in the
  chezmoi dotfiles. They run `~/.config/autostart` under sway, start toolbox containers at login (Ptyxis can't open a
  tab in a stopped container), and run Sunshine's packaged unit in the sway session only, restarting it if it dies

After the first run: log into the "Sway" session, open `https://localhost:47990` to create the Sunshine login, and
pair Moonlight from the client. Set Moonlight's resolution to Native and enable "Capture system keyboard shortcuts" so
Super combos reach sway. When a client connects, `remote-on` moves the session to a virtual output sized for it and
turns the local monitors off; a sway reload during the session keeps that layout. `remote-off` (or Super+Ctrl+Shift+R)
restores the monitors.

### Fedora Silverblue
- Layers a minimal set of host packages via `rpm-ostree` (see `silverblue_host_packages` in `default.config.yml`)
- Creates a default Fedora toolbox and installs CLI dev tools inside it (see `silverblue_toolbox_packages`)
- Adds Flathub and installs Flatpak apps per-user, including Silverblue-specific extras (VS Code, 1Password)

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
configure_sway: false      # sway session + Sunshine (Fedora)
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
│   ├── sway/              # sway session, Sunshine, optional wayvnc (Fedora)
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
ansible-playbook main.yml -i localhost, -c local --ask-become-pass --tags sway
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
