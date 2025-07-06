# Dev_Workstation

```shell
██     ██  █████  ██████  ███    ██ ██ ███    ██  ██████  
██     ██ ██   ██ ██   ██ ████   ██ ██ ████   ██ ██       
██  █  ██ ███████ ██████  ██ ██  ██ ██ ██ ██  ██ ██   ███ 
██ ███ ██ ██   ██ ██   ██ ██  ██ ██ ██ ██  ██ ██ ██    ██ 
 ███ ███  ██   ██ ██   ██ ██   ████ ██ ██   ████  ██████  
```

[![CI](https://github.com/your-username/dev_workstation/workflows/CI/badge.svg)](https://github.com/your-username/dev_workstation/actions)
[![Ansible Lint](https://img.shields.io/badge/ansible--lint-production-brightgreen)](https://ansible.readthedocs.io/projects/lint/)
[![YAML Lint](https://img.shields.io/badge/yaml--lint-passing-brightgreen)](https://yamllint.readthedocs.io/)

This is a hobby project that I'm using to make my life easier and do weird things with Ansible. It may or may not be safe to run, and may or may not do bizarre things to your profile. Fork, run, enjoy at your own risk! 

A robust, cross-platform Ansible playbook for automated development workstation setup with comprehensive testing, linting, and CI/CD integration.

## ✨ Features

- **🖥️ Cross-Platform Support**: macOS (Apple Silicon & Intel), Fedora, Debian, Ubuntu
- **🔄 Idempotent Operations**: Safe to run multiple times without side effects
- **⚡ Performance Optimized**: Batch operations, connection caching, retry logic
- **🧪 Comprehensive Testing**: Automated linting, syntax checks, and Molecule testing
- **🔍 Production Quality**: Passes ansible-lint production profile standards
- **🚀 CI/CD Ready**: GitHub Actions workflow for automated testing
- **📦 Modern Package Management**: Homebrew, APT, DNF, Flatpak support
- **🏠 Dotfiles Integration**: Automated chezmoi setup and configuration

## 🚀 Quick Start

### Prerequisites

- **Ansible**: 2.15+ recommended
- **Python**: 3.9+ with pip
- **Git**: For repository management
- **Docker**: For Molecule testing (optional)

### Installation

1. **Clone the repository**:

   ```bash
   git clone https://github.com/your-username/dev_workstation.git
   cd dev_workstation
   ```

2. **Install dependencies**:

   ```bash
   make install
   # OR manually:
   pip install ansible ansible-lint yamllint molecule[docker]
   ansible-galaxy collection install -r requirements.yml
   ```

3. **Configure your setup**:

   ```bash
   cp default.config.yml my-config.yml
   # Edit my-config.yml with your preferences
   ```

4. **Run the playbook**:

   ```bash
   # Local installation
   ansible-playbook main.yml -e @my-config.yml
   
   # With inventory
   ansible-playbook main.yml -i inventory/hosts -e @my-config.yml
   ```

## 🧪 Testing & Quality Assurance

This project includes comprehensive testing infrastructure to ensure reliability and code quality.

### Available Make Targets

```bash
make help           # Show all available targets
make install        # Install testing dependencies
make test           # Run all tests (lint + syntax + molecule)
make test-quick     # Run quick tests (lint + syntax only)
make lint           # Run YAML and Ansible linting
make syntax         # Run syntax check
make molecule       # Run Molecule tests
make clean          # Clean up test artifacts

# Platform-specific testing
make test-ubuntu    # Test with Ubuntu 22.04
make test-fedora    # Test with Fedora 38
```

### Test Script Usage

The `scripts/test.sh` script provides flexible testing options:

```bash
# Run all tests
./scripts/test.sh

# Skip specific test types
./scripts/test.sh --skip-lint
./scripts/test.sh --skip-syntax
./scripts/test.sh --skip-molecule
./scripts/test.sh --skip-idempotence

# Test specific distribution
./scripts/test.sh --distro ubuntu2204
./scripts/test.sh --distro fedora38

# Get help
./scripts/test.sh --help
```

### Quality Standards

- ✅ **YAML Lint**: Enforces consistent YAML formatting
- ✅ **Ansible Lint**: Production profile compliance 
- ✅ **Syntax Check**: Validates Ansible syntax
- ✅ **Idempotence**: Ensures tasks don't change on repeat runs
- ✅ **Molecule Testing**: Container-based integration tests

### CI/CD Pipeline

GitHub Actions workflow (`.github/workflows/ci.yml`) automatically:

- Runs linting and syntax checks
- Performs Molecule tests on multiple distributions
- Validates idempotence
- Scans for security issues
- Reports test results and coverage

## 🔧 Configuration

### Core Settings

Edit `default.config.yml` or create your own configuration file:

```yaml
---
# Main feature flags
configure_dotfiles: true    # Install and configure chezmoi
configure_macos: true       # Run macOS-specific tasks
configure_linux: true      # Run Linux-specific tasks
configure_mas: true         # Install Mac App Store apps
configure_dock: true        # Configure macOS dock

# GitHub username for dotfiles
GITHUB_USERNAME: "your-github-username"

# Performance settings (already optimized)
ansible_python_interpreter: auto_silent
ansible_ssh_pipelining: true
ansible_ssh_control_persist: 300s
```

### Package Configuration

#### macOS Packages (Homebrew)

```yaml
homebrew_installed_packages:
  - gh                      # GitHub CLI
  - oh-my-posh             # Shell prompt
  - ncdu                   # Disk usage analyzer
  - tree                   # Directory tree viewer
  - docker                 # Container platform
  - powershell            # PowerShell Core

homebrew_cask_apps:
  - obsidian              # Note-taking app
  - iterm2                # Terminal emulator
  - visual-studio-code    # Code editor
  - font-fira-code       # Programming font
```

#### Mac App Store Apps

```yaml
mas_installed_apps:
  - {id: 497799835, name: "Xcode"}
  - {id: 1451685025, name: "WireGuard"}
```

#### Linux Packages

```yaml
linux_packages:
  - flatpak               # Universal package system
  - tilix                 # Terminal emulator
  - powershell           # PowerShell Core
  - bpytop              # System monitor
  - 1password           # Password manager
  - code                 # VS Code
  - tree                 # Directory tree
  - zsh                  # Z shell
  - vim                  # Text editor

linux_flatpak_packages:
  - md.obsidian.Obsidian
  - com.discordapp.Discord
```

#### Dock Configuration (macOS)

```yaml
dockitems_remove:
  - Launchpad
  - TV
  - Podcasts
  - 'App Store'

dockitems_persist:
  - name: "Finder"
    path: "/System/Applications/Finder.app/"
    pos: 1
  - name: "iTerm"
    path: "/Applications/iTerm.app/"
    pos: 2
```

## 📁 Project Structure

```shell
dev_workstation/
├── .github/workflows/       # CI/CD workflows
│   └── ci.yml              # Main CI pipeline
├── inventory/              # Ansible inventory files
│   ├── hosts              # Host definitions
│   └── group_vars/        # Group variables
├── molecule/               # Molecule testing
│   └── default/           # Default test scenario
├── roles/                  # Ansible roles
│   ├── common/            # Cross-platform tasks
│   ├── linux/             # Linux-specific tasks
│   └── macos/             # macOS-specific tasks
├── scripts/                # Utility scripts
│   └── test.sh            # Test runner script
├── tasks/                  # Task files
│   ├── deb.wkstn.yml      # Debian/Ubuntu tasks
│   ├── dotfiles.yml       # Dotfiles management
│   ├── fedora.wkstn.yml   # Fedora/RHEL tasks
│   ├── flatpak.yml        # Flatpak package management
│   ├── mac.defaults.yml   # macOS system defaults
│   ├── mac.pkgs.yml       # macOS package installation
│   └── win11.wkstn.yml    # Windows tasks (experimental)
├── .ansible-lint.yml       # Ansible lint configuration
├── .yamllint.yml          # YAML lint configuration
├── ansible.cfg            # Ansible configuration
├── default.config.yml     # Default configuration
├── main.yml               # Main playbook
├── Makefile              # Build automation
└── requirements.yml       # Ansible dependencies
```

## 🎯 What This Playbook Does

### Cross-Platform Features

#### 📋 Dotfiles Management
- **Chezmoi Installation**: Automatically installs chezmoi via appropriate package manager
- **Repository Initialization**: Clones your dotfiles from GitHub
- **Configuration Application**: Applies dotfiles to your system
- **Cross-Platform Support**: Works on macOS (Homebrew) and Linux (script installation)

#### 🔧 Development Tools
- **Common Utilities**: git, zsh, vim, tree, and more
- **Shell Enhancement**: oh-my-posh with custom themes
- **Directory Management**: Creates necessary directories with proper permissions

### macOS-Specific Features

#### 🍺 Homebrew Management
- **Package Installation**: CLI tools and GUI applications
- **Font Management**: Programming fonts like Fira Code
- **Automatic Updates**: Keeps packages current

#### 🏪 Mac App Store Integration
- **App Installation**: Installs apps via MAS
- **License Management**: Respects existing licenses
- **Batch Operations**: Efficient bulk installations

#### 🎛️ System Configuration
- **Dock Management**: Customizes dock items and positions
- **System Defaults**: Optimizes development settings
- **Finder Settings**: Enhances file management

### Linux-Specific Features

#### 📦 Package Management
- **Multi-Distribution**: Supports APT (Debian/Ubuntu) and DNF (Fedora/RHEL)
- **Repository Setup**: Adds Microsoft, VS Code, and 1Password repositories
- **GPG Key Management**: Handles security keys properly

#### 📱 Flatpak Integration
- **Flathub Repository**: Adds Flathub for universal packages
- **Application Installation**: Installs modern Linux applications
- **Sandbox Security**: Benefits from Flatpak's security model

## 🚦 Platform Detection & Execution

The playbook uses robust OS detection with clear execution paths:

```yaml
# Automatic OS detection
is_macos: "{{ ansible_os_family == 'Darwin' }}"
is_fedora: "{{ ansible_distribution in ['Fedora', 'RedHat', 'CentOS'] }}"
is_debian: "{{ ansible_distribution in ['Debian', 'Ubuntu'] }}"
is_linux: "{{ ansible_system == 'Linux' }}"
```

### Execution Flow
1. **Pre-tasks**: OS detection and fact gathering
2. **Role Execution**: Platform-specific roles (macOS only)
3. **Task Execution**: Cross-platform and OS-specific tasks with proper conditionals
4. **Tagging**: Selective execution with `--tags dotfiles,macos,linux`

## 📈 Performance Optimizations

### Connection & Caching
- **SSH Pipelining**: Reduces connection overhead
- **Control Persistence**: Maintains connections for 5 minutes
- **Fact Caching**: Caches gathered facts for 1 hour

### Task Optimization
- **Batch Operations**: Groups package installations
- **Retry Logic**: Automatic retry on network failures
- **Idempotent Design**: Skip unnecessary operations

### Error Handling
- **Graceful Failures**: Continue on non-critical errors
- **Detailed Logging**: Comprehensive error reporting
- **Recovery Mechanisms**: Automatic cleanup on failures

## 🛠️ Development & Contributing

### Running Tests Locally

```bash
# Install development dependencies
make install

# Run quick tests during development
make test-quick

# Run full test suite
make test

# Test specific platforms
make test-ubuntu
make test-fedora
```

### Code Quality

- **Ansible Lint**: Production profile compliance
- **YAML Lint**: Consistent formatting
- **Pre-commit Hooks**: Available for automated checks
- **Documentation**: Comprehensive inline comments

### Adding New Tasks

1. Create task files in the `tasks/` directory
2. Add appropriate conditionals for OS detection
3. Include in `main.yml` with proper tags
4. Add configuration options to `default.config.yml`
5. Update documentation and tests

## 🔒 Security Considerations

### Best Practices
- **FQCN Usage**: Fully Qualified Collection Names for all modules
- **File Permissions**: Explicit permission settings
- **GPG Verification**: Validates package signatures
- **No Elevated Privileges**: Runs as regular user when possible

### Network Security
- **HTTPS Downloads**: All downloads use encrypted connections
- **Repository Verification**: GPG key validation for external repositories
- **Checksums**: Verification where available

## 🐛 Troubleshooting

### Common Issues

#### Collection Installation
```bash
# Force reinstall collections
ansible-galaxy collection install -r requirements.yml --force

# Clear cache
rm -rf ~/.ansible/collections
```

#### Permission Issues
```bash
# Run with privilege escalation
ansible-playbook main.yml --ask-become-pass

# Check file permissions
ls -la ~/.local/bin/chezmoi
```

#### macOS-Specific Issues
```bash
# Sign into Mac App Store first
open "/System/Applications/App Store.app"

# Fix Homebrew PATH
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
```

#### Linux GPG Issues
```bash
# Refresh GPG keys
sudo apt-key del 9C135BD3 && sudo apt-key del 1F3A1A1F
sudo rm /etc/apt/sources.list.d/microsoft*.list
```

### Debug Mode

Enable debug mode for detailed output:
```bash
ansible-playbook main.yml -vvv
```

### Log Files

Check logs in:
- `/tmp/ansible_facts_cache/` - Cached facts
- `~/.ansible/` - Ansible data directory

## 📋 ToDo & Roadmap

### Completed ✅
- [x] Cross-platform OS detection and execution
- [x] Comprehensive testing infrastructure (Molecule, CI/CD)
- [x] Production-grade linting and code quality
- [x] Idempotent dotfiles management with chezmoi
- [x] Performance optimizations and retry logic
- [x] Robust error handling and logging
- [x] macOS management via geerlingguy.mac collection
- [x] Multi-distribution Linux support
- [x] Security best practices implementation

### In Progress 🚧
- [ ] Windows support via Chocolatey and WinGet
- [ ] Enhanced Flatpak application management
- [ ] Role-based task organization
- [ ] Advanced macOS defaults configuration

### Planned 📅
- [ ] Terraform integration for cloud workstations
- [ ] Container-based development environments
- [ ] Advanced shell configuration (zsh/fish)
- [ ] Development environment templates
- [ ] Secrets management integration
- [ ] Remote workstation provisioning

## 📄 License

This project is licensed under the MIT License. See the LICENSE file for details.

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Ensure all tests pass (`make test`)
6. Submit a pull request

### Development Setup

```bash
git clone https://github.com/your-username/dev_workstation.git
cd dev_workstation
make install
make test-quick  # Verify setup
```
