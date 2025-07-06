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
	pip install ansible ansible-lint yamllint molecule[docker]
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
