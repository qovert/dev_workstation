#!/usr/bin/env bash
# bootstrap.sh — install ansible and run the playbook on a fresh machine.
# Supports: macOS, Fedora Workstation, Fedora Silverblue
set -euo pipefail

# ── helpers ────────────────────────────────────────────────────────────────────
need() { command -v "$1" &>/dev/null; }
info() { printf '\033[0;34m==> %s\033[0m\n' "$*"; }
die()  { printf '\033[0;31merror: %s\033[0m\n' "$*" >&2; exit 1; }

# ── platform detection ─────────────────────────────────────────────────────────
if [[ "$(uname)" == "Darwin" ]]; then
  PLATFORM=macos
elif [[ -f /run/ostree-booted ]] && grep -qi fedora /etc/os-release 2>/dev/null; then
  PLATFORM=silverblue
elif grep -qi fedora /etc/os-release 2>/dev/null; then
  PLATFORM=fedora
else
  die "Unsupported platform. Supported: macOS, Fedora Workstation, Fedora Silverblue."
fi

info "Detected platform: $PLATFORM"

# ── install ansible ────────────────────────────────────────────────────────────
case "$PLATFORM" in
  macos)
    if ! need brew; then
      info "Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      # Add Homebrew to PATH for this session (Apple Silicon vs Intel)
      if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      else
        eval "$(/usr/local/bin/brew shellenv)"
      fi
    fi
    if ! need ansible-playbook; then
      info "Installing ansible via Homebrew..."
      brew install ansible
    fi
    ;;

  silverblue)
    export PATH="$HOME/.local/bin:$PATH"
    if ! need ansible-playbook; then
      info "Installing ansible via pipx..."
      if ! need pipx; then
        # Python 3.12+ marks the system environment as externally managed;
        # --break-system-packages is safe here because we're installing to ~/.local
        python3 -m pip install --user pipx 2>/dev/null \
          || python3 -m pip install --user pipx --break-system-packages
      fi
      pipx install ansible
    fi
    ;;

  fedora)
    if ! need ansible-playbook; then
      info "Installing ansible via dnf..."
      sudo dnf install -y ansible
    fi
    ;;
esac

# ── galaxy dependencies ────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

info "Installing Ansible Galaxy collections..."
ansible-galaxy collection install -r requirements.yml

# Roles are macOS-only in this repo (Homebrew, MAS, etc.)
if [[ "$PLATFORM" == "macos" ]]; then
  info "Installing Ansible Galaxy roles..."
  ansible-galaxy role install -r requirements.yml
fi

# ── run playbook ───────────────────────────────────────────────────────────────
info "Running playbook..."
ansible-playbook main.yml -i "localhost," -c local "$@"
