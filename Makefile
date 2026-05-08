.PHONY: help setup install run-playbook lint syntax molecule clean

help:
	@echo "Targets:"
	@echo "  setup       - Install deps and run playbook (primary entry point)"
	@echo "  install     - Install Ansible and Galaxy dependencies only"
	@echo "  run-playbook- Run the playbook (requires install first)"
	@echo "  lint        - YAML and Ansible lint"
	@echo "  syntax      - Syntax check only"
	@echo "  molecule    - Run Molecule tests"
	@echo "  clean       - Remove test artifacts"
	@echo ""
	@echo "Supported platforms: Fedora (primary), macOS (secondary)"
	@echo ""
	@echo "Before running: set github_username in default.config.yml"

install:
	@echo "Installing dependencies..."
	@if uname -s | grep -q Darwin; then \
		if ! command -v brew >/dev/null 2>&1; then \
			/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
		fi; \
		if [[ -f /opt/homebrew/bin/brew ]]; then eval "$$(/opt/homebrew/bin/brew shellenv)"; \
		elif [[ -f /usr/local/bin/brew ]]; then eval "$$(/usr/local/bin/brew shellenv)"; fi; \
	fi
	@if command -v pip3 >/dev/null 2>&1; then PIP=pip3; else PIP=pip; fi; \
	$$PIP install --upgrade ansible ansible-lint yamllint molecule "molecule-plugins[docker]" \
		--break-system-packages 2>/dev/null || \
	$$PIP install --upgrade ansible ansible-lint yamllint molecule "molecule-plugins[docker]" --user
	@USER_BASE=$$(python3 -c "import site; print(site.USER_BASE)" 2>/dev/null) || true; \
	export PATH="$$USER_BASE/bin:$$PATH"; \
	ansible-galaxy role install -r requirements.yml; \
	ansible-galaxy collection install -r requirements.yml

setup: install run-playbook

run-playbook:
	@echo "Running playbook..."
	@USER_BASE=$$(python3 -c "import site; print(site.USER_BASE)" 2>/dev/null) || true; \
	export PATH="$$USER_BASE/bin:$$PATH"; \
	ansible-playbook main.yml -i localhost, --connection=local --ask-become-pass

lint:
	yamllint .
	ansible-lint

syntax:
	ansible-playbook main.yml --syntax-check

molecule:
	molecule test

clean:
	molecule destroy || true
	rm -rf .ansible
	rm -rf molecule/default/.molecule
