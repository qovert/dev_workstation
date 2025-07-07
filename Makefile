.PHONY: help install test test-quick lint syntax molecule clean

# Default target
help:
	@echo "Available targets:"
	@echo "  install     - Install testing dependencies"
	@echo "  test        - Run all tests"
	@echo "  test-quick  - Run quick tests (lint + syntax)"
	@echo "  lint        - Run YAML and Ansible linting"
	@echo "  syntax      - Run syntax check"
	@echo "  molecule    - Run Molecule tests"
	@echo "  clean       - Clean up test artifacts"

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
			elif command -v apt-get >/dev/null 2>&1; then \
				echo "📦 Installing pip via apt..."; \
				sudo apt-get update && sudo apt-get install -y python3-pip; \
			elif command -v dnf >/dev/null 2>&1; then \
				echo "📦 Installing pip via dnf..."; \
				sudo dnf install -y python3-pip; \
			elif command -v yum >/dev/null 2>&1; then \
				echo "📦 Installing pip via yum..."; \
				sudo yum install -y python3-pip; \
			else \
				echo "❌ Could not install pip automatically. Please install pip manually:"; \
				echo "   - macOS: brew install python3"; \
				echo "   - Ubuntu/Debian: sudo apt-get install python3-pip"; \
				echo "   - Fedora/RHEL: sudo dnf install python3-pip"; \
				exit 1; \
			fi; \
		else \
			echo "❌ Python3 not found. Please install Python3 first."; \
			exit 1; \
		fi; \
	else \
		echo "✅ pip is available"; \
	fi
	@echo "Installing Python packages..."
	@if command -v pip3 >/dev/null 2>&1; then \
		pip3 install ansible ansible-lint yamllint molecule[docker]; \
	else \
		pip install ansible ansible-lint yamllint molecule[docker]; \
	fi
	@echo "Installing Ansible collections..."
	ansible-galaxy collection install -r requirements.yml

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

# Clean up
clean:
	@echo "Cleaning up test artifacts..."
	molecule destroy || true
	docker system prune -f || true
	rm -rf .ansible
	rm -rf molecule/default/.molecule
