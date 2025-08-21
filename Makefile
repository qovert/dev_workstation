.PHONY: help install test test-quick lint syntax molecule fix-fedora clean

# Default target
help:
	@echo "Available targets:"
	@echo "  install     - Install testing dependencies"
	@echo "  test        - Run all tests"
	@echo "  test-quick  - Run quick tests (lint + syntax)"
	@echo "  lint        - Run YAML and Ansible linting"
	@echo "  syntax      - Run syntax check"
	@echo "  molecule    - Run Molecule tests"
	@echo "  fix-fedora  - Fix Fedora 42+ libdnf5 issues (🔧 FEDORA ONLY)"
	@echo "  clean       - Clean up test artifacts"
	@echo ""
	@echo "Troubleshooting:"
	@echo "  - Fedora libdnf5 error: make fix-fedora"
	@echo "  - Docker issues: Start Docker Desktop first"
	@echo "  - Pip missing: make install (auto-installs)"

# Install testing dependencies
install:
	@echo "Installing testing dependencies..."
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
				echo "📦 macOS detected, installing Homebrew first..."; \
				/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
				echo "📦 Adding Homebrew to PATH..."; \
				if [[ -f /opt/homebrew/bin/brew ]]; then \
					eval "$$(/opt/homebrew/bin/brew shellenv)"; \
				elif [[ -f /usr/local/bin/brew ]]; then \
					eval "$$(/usr/local/bin/brew shellenv)"; \
				fi; \
				echo "📦 Installing Python3 via Homebrew..."; \
				brew install python3; \
				echo "📦 Upgrading pip (macOS/Homebrew)..."; \
				python3 -m pip install --upgrade pip; \
				echo "📦 Installing Ansible and dependencies (macOS/Homebrew)..."; \
				python3 -m pip install --upgrade ansible ansible-lint yamllint molecule "molecule-plugins[docker]"; \
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
	@echo "Installing Ansible collections..."
	@echo "Refreshing shell environment..."
	@hash -r 2>/dev/null || true
	@export PATH="$$(python3 -m site --user-base)/bin:$$PATH" 2>/dev/null || export PATH="$$(python -m site --user-base)/bin:$$PATH" 2>/dev/null || true; \
	if command -v ansible-galaxy >/dev/null 2>&1; then \
		echo "✅ Found ansible-galaxy in PATH"; \
		ansible-galaxy collection install -r requirements.yml; \
	elif python3 -c "import ansible" 2>/dev/null; then \
		echo "📦 Using python3 -m ansible.galaxy..."; \
		python3 -m ansible.galaxy collection install -r requirements.yml; \
	elif python -c "import ansible" 2>/dev/null; then \
		echo "📦 Using python -m ansible.galaxy..."; \
		python -m ansible.galaxy collection install -r requirements.yml; \
	else \
		echo "❌ Ansible is not properly installed or not accessible."; \
		echo "Please check that Ansible was installed successfully and try again."; \
		echo "You may need to restart your terminal session or run:"; \
		echo "  export PATH=\"$$(python3 -m site --user-base)/bin:\$$PATH\""; \
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
