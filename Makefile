.PHONY: help install test test-quick lint syntax molecule fix-fedora clean setup run-playbook run-playbook-no-pass setup-no-pass

# Default target
help:
	@echo "Available targets:"
	@echo "  setup       - Complete workstation setup (install deps + run playbook)"
	@echo "  setup-no-pass - Setup without password prompt (uses sudo without password)"
	@echo "  install     - Install testing dependencies only"
	@echo "  run-playbook- Run the Ansible playbook (requires install first)"
	@echo "  run-playbook-no-pass - Run playbook without password prompt"
	@echo "  test        - Run all tests"
	@echo "  test-quick  - Run quick tests (lint + syntax)"
	@echo "  lint        - Run YAML and Ansible linting"
	@echo "  syntax      - Run syntax check"
	@echo "  molecule    - Run Molecule tests"
	@echo "  fix-fedora  - Fix Fedora 42+ libdnf5 issues (🔧 FEDORA ONLY)"
	@echo "  clean       - Clean up test artifacts"
	@echo ""
	@echo "Quick Start:"
	@echo "  make setup  - One-command workstation setup"
	@echo ""
	@echo "Supported Platforms:"
	@echo "  - macOS (with automatic Homebrew installation)"
	@echo "  - Fedora/RHEL/CentOS (with DNF)"
	@echo "  - Ubuntu/Debian (with APT)"
	@echo ""
	@echo "Troubleshooting:"
	@echo "  - Fedora libdnf5 error: make fix-fedora"
	@echo "  - Docker issues: Start Docker Desktop first"
	@echo "  - Pip missing: make install (auto-installs)"

# Install testing dependencies
install:
	@echo "Installing testing dependencies..."
	@echo "Checking for Homebrew on macOS..."
	@if uname -s | grep -q "Darwin"; then \
		if ! command -v brew >/dev/null 2>&1; then \
			echo "📦 macOS detected, installing Homebrew..."; \
			/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
			echo "📦 Adding Homebrew to PATH..."; \
			if [[ -f /opt/homebrew/bin/brew ]]; then \
				eval "$$(/opt/homebrew/bin/brew shellenv)"; \
			elif [[ -f /usr/local/bin/brew ]]; then \
				eval "$$(/usr/local/bin/brew shellenv)"; \
			fi; \
			echo "📦 Installing Python3 via Homebrew..."; \
			brew install python3; \
		else \
			echo "✅ Homebrew is already installed"; \
		fi; \
	fi
	@echo "Checking for pip availability..."
	@if ! command -v pip >/dev/null 2>&1 && ! command -v pip3 >/dev/null 2>&1; then \
		echo "❌ pip not found. Installing pip..."; \
		if command -v python3 >/dev/null 2>&1; then \
			if command -v brew >/dev/null 2>&1; then \
				echo "📦 Installing pip via Homebrew..."; \
				brew install python3; \
				echo "📦 Upgrading pip (macOS/Homebrew)..."; \
				python3 -m pip install --upgrade pip; \
				echo "📦 Installing Ansible and dependencies (macOS/Homebrew)..."; \
				python3 -m pip install --upgrade ansible ansible-lint yamllint molecule "molecule-plugins[docker]"; \
			elif uname -s | grep -q "Darwin"; then \
				echo "❌ This should not happen - Homebrew should be installed by now"; \
				exit 1; \
			elif command -v apt-get >/dev/null 2>&1; then \
				echo "📦 Installing pip via apt..."; \
				sudo apt-get update && sudo apt-get install -y python3-pip; \
				python3 -m pip install --upgrade pip; \
			elif command -v dnf >/dev/null 2>&1; then \
				echo "📦 Installing pip via dnf..."; \
				sudo dnf install -y python3-pip python3-libdnf5; \
				python3 -m pip install --upgrade pip; \
			elif command -v yum >/dev/null 2>&1; then \
				echo "📦 Installing pip via yum..."; \
				sudo yum install -y python3-pip; \
				python3 -m pip install --upgrade pip; \
			else \
				echo "❌ Could not install pip automatically. Please install pip manually:"; \
				echo "   - macOS: /bin/bash -c \"$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""; \
				echo "   - Ubuntu/Debian: sudo apt-get install python3-pip"; \
				echo "   - Fedora/RHEL: sudo dnf install python3-pip python3-libdnf5"; \
				exit 1; \
			fi; \
		else \
			echo "❌ Python3 not found. Please install Python3 first."; \
			exit 1; \
		fi; \
	else \
		echo "✅ pip is available"; \
		if command -v pip3 >/dev/null 2>&1; then \
			PIP=pip3; \
		else \
			PIP=pip; \
		fi; \
		echo "📦 Upgrading pip..."; \
		$$PIP install --upgrade pip; \
		echo "📦 Installing Ansible and dependencies..."; \
		$$PIP install --upgrade ansible ansible-lint yamllint molecule "molecule-plugins[docker]"; \
		echo "📦 Adding pip user bin to PATH..."; \
		if [[ "$$PIP" == "pip3" ]]; then \
			USER_BIN=$$(python3 -m site --user-base)/bin; \
		else \
			USER_BIN=$$(python -m site --user-base)/bin; \
		fi; \
		export PATH="$$USER_BIN:$$PATH"; \
		echo "Updated PATH to include: $$USER_BIN"; \
	fi
	@echo "Installing Ansible collections and roles..."
	@echo "Refreshing shell environment..."
	@hash -r 2>/dev/null || true
	@export PATH="$$(python3 -m site --user-base)/bin:$$PATH" 2>/dev/null || export PATH="$$(python -m site --user-base)/bin:$$PATH" 2>/dev/null || true; \
	if command -v ansible-galaxy >/dev/null 2>&1; then \
		echo "✅ Found ansible-galaxy in PATH"; \
		echo "📦 Installing Ansible roles..."; \
		ansible-galaxy role install -r requirements.yml; \
		echo "📦 Installing Ansible collections..."; \
		ansible-galaxy collection install -r requirements.yml; \
	elif python3 -c "import ansible" 2>/dev/null; then \
		echo "📦 Using python3 -m ansible.galaxy..."; \
		echo "📦 Installing Ansible roles..."; \
		python3 -m ansible.galaxy role install -r requirements.yml; \
		echo "📦 Installing Ansible collections..."; \
		python3 -m ansible.galaxy collection install -r requirements.yml; \
	elif python -c "import ansible" 2>/dev/null; then \
		echo "📦 Using python -m ansible.galaxy..."; \
		echo "📦 Installing Ansible roles..."; \
		python -m ansible.galaxy role install -r requirements.yml; \
		echo "📦 Installing Ansible collections..."; \
		python -m ansible.galaxy collection install -r requirements.yml; \
	else \
		echo "❌ Ansible is not properly installed or not accessible."; \
		echo "Please check that Ansible was installed successfully and try again."; \
		echo "You may need to restart your terminal session or run:"; \
		echo "  export PATH=\"$$(python3 -m site --user-base)/bin:\$$PATH\""; \
		exit 1; \
	fi

# Complete workstation setup - install dependencies and run playbook
setup: install run-playbook
	@echo "🎉 Workstation setup complete!"

# Run the Ansible playbook
run-playbook:
	@echo "🚀 Running Ansible playbook for workstation setup..."
	@export PATH="$$(python3 -m site --user-base)/bin:$$PATH" 2>/dev/null || export PATH="$$(python -m site --user-base)/bin:$$PATH" 2>/dev/null || true; \
	if command -v ansible-playbook >/dev/null 2>&1; then \
		echo "✅ Found ansible-playbook in PATH"; \
		echo "📋 Running playbook on localhost..."; \
		ansible-playbook main.yml -i localhost, --connection=local --ask-become-pass; \
	elif python3 -c "import ansible" 2>/dev/null; then \
		echo "📦 Using python3 -m ansible.playbook..."; \
		python3 -c "from ansible.cli.playbook import PlaybookCLI; import sys; sys.argv = ['ansible-playbook', 'main.yml', '-i', 'localhost,', '--connection=local', '--ask-become-pass']; PlaybookCLI().run()"; \
	elif python -c "import ansible" 2>/dev/null; then \
		echo "📦 Using python -m ansible.playbook..."; \
		python -c "from ansible.cli.playbook import PlaybookCLI; import sys; sys.argv = ['ansible-playbook', 'main.yml', '-i', 'localhost,', '--connection=local', '--ask-become-pass']; PlaybookCLI().run()"; \
	else \
		echo "❌ Ansible playbook is not accessible."; \
		echo "Please ensure Ansible was installed successfully by running 'make install'"; \
		exit 1; \
	fi

# Complete workstation setup without password prompts (for CI/automated environments)
setup-no-pass: install run-playbook-no-pass
	@echo "🎉 Workstation setup complete (no password prompts)!"

# Run the Ansible playbook without password prompts
run-playbook-no-pass:
	@echo "🚀 Running Ansible playbook for workstation setup (no password prompts)..."
	@export PATH="$$(python3 -m site --user-base)/bin:$$PATH" 2>/dev/null || export PATH="$$(python -m site --user-base)/bin:$$PATH" 2>/dev/null || true; \
	if command -v ansible-playbook >/dev/null 2>&1; then \
		echo "✅ Found ansible-playbook in PATH"; \
		echo "📋 Running playbook on localhost (no password prompts)..."; \
		ansible-playbook main.yml -i localhost, --connection=local --become; \
	elif python3 -c "import ansible" 2>/dev/null; then \
		echo "📦 Using python3 -m ansible.playbook..."; \
		python3 -c "from ansible.cli.playbook import PlaybookCLI; import sys; sys.argv = ['ansible-playbook', 'main.yml', '-i', 'localhost,', '--connection=local', '--become']; PlaybookCLI().run()"; \
	elif python -c "import ansible" 2>/dev/null; then \
		echo "📦 Using python -m ansible.playbook..."; \
		python -c "from ansible.cli.playbook import PlaybookCLI; import sys; sys.argv = ['ansible-playbook', 'main.yml', '-i', 'localhost,', '--connection=local', '--become']; PlaybookCLI().run()"; \
	else \
		echo "❌ Ansible playbook is not accessible."; \
		echo "Please ensure Ansible was installed successfully by running 'make install'"; \
		exit 1; \
	fi

# Run all tests
test:
	@echo "Running all tests..."
	./scripts/test.sh

# Quick tests (lint + syntax only)
test-quick:
	@echo "Running quick tests..."
	./scripts/test.sh --skip-molecule --skip-idempotence

# Linting only
lint:
	@echo "Running linting..."
	yamllint .
	ansible-lint

# Syntax check only
syntax:
	@echo "Running syntax check..."
	ansible-playbook main.yml --syntax-check

# Molecule tests only
molecule:
	@echo "Running Molecule tests..."
	molecule test

# Test specific distro
test-ubuntu:
	@echo "Testing Ubuntu..."
	./scripts/test.sh --distro ubuntu2204

test-fedora:
	@echo "Testing Fedora..."
	./scripts/test.sh --distro fedora38

# Fix Fedora libdnf5 issues
fix-fedora:
	@echo "🔧 Fixing Fedora libdnf5 issues..."
	@if command -v dnf >/dev/null 2>&1; then \
		echo "📦 Installing required packages..."; \
		sudo dnf install -y python3-libdnf5 python3-dnf ansible; \
		echo "✅ Fedora packages installed successfully"; \
	else \
		echo "❌ This fix is only for Fedora systems with DNF"; \
		exit 1; \
	fi

# Clean up
clean:
	@echo "Cleaning up test artifacts..."
	molecule destroy || true
	docker system prune -f || true
	rm -rf .ansible
	rm -rf molecule/default/.molecule
