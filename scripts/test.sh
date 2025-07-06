#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Default values
RUN_LINT=true
RUN_SYNTAX=true
RUN_MOLECULE=true
RUN_IDEMPOTENCE=true
DISTRO="ubuntu2204"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --skip-lint)
      RUN_LINT=false
      shift
      ;;
    --skip-syntax)
      RUN_SYNTAX=false
      shift
      ;;
    --skip-molecule)
      RUN_MOLECULE=false
      shift
      ;;
    --skip-idempotence)
      RUN_IDEMPOTENCE=false
      shift
      ;;
    --distro)
      DISTRO="$2"
      shift
      shift
      ;;
    --help)
      echo "Usage: $0 [OPTIONS]"
      echo "Options:"
      echo "  --skip-lint          Skip YAML and Ansible linting"
      echo "  --skip-syntax        Skip syntax checking"
      echo "  --skip-molecule      Skip Molecule testing"
      echo "  --skip-idempotence   Skip idempotence testing"
      echo "  --distro DISTRO      Test with specific distro (default: ubuntu2204)"
      echo "  --help               Show this help message"
      exit 0
      ;;
    *)
      log_error "Unknown option $1"
      exit 1
      ;;
  esac
done

# Check prerequisites
log_info "Checking prerequisites..."
command -v ansible >/dev/null 2>&1 || { log_error "ansible is required but not installed."; exit 1; }
command -v ansible-lint >/dev/null 2>&1 || { log_error "ansible-lint is required but not installed."; exit 1; }
command -v yamllint >/dev/null 2>&1 || { log_error "yamllint is required but not installed."; exit 1; }

if [[ "$RUN_MOLECULE" == true ]]; then
  command -v molecule >/dev/null 2>&1 || { log_error "molecule is required but not installed."; exit 1; }
  command -v docker >/dev/null 2>&1 || { log_error "docker is required for molecule testing."; exit 1; }
fi

# Install Galaxy dependencies
log_info "Installing Galaxy dependencies..."
ansible-galaxy collection install -r requirements.yml --force

# YAML Linting
if [[ "$RUN_LINT" == true ]]; then
  log_info "Running YAML lint..."
  if yamllint .; then
    log_info "✅ YAML lint passed"
  else
    log_error "❌ YAML lint failed"
    exit 1
  fi

  log_info "Running Ansible lint..."
  if ansible-lint; then
    log_info "✅ Ansible lint passed"
  else
    log_error "❌ Ansible lint failed"
    exit 1
  fi
fi

# Syntax checking
if [[ "$RUN_SYNTAX" == true ]]; then
  log_info "Running syntax check..."
  if ansible-playbook main.yml --syntax-check; then
    log_info "✅ Syntax check passed"
  else
    log_error "❌ Syntax check failed"
    exit 1
  fi
fi

# Molecule testing
if [[ "$RUN_MOLECULE" == true ]]; then
  log_info "Running Molecule tests with distro: $DISTRO..."
  export MOLECULE_DISTRO="$DISTRO"
  
  if molecule test; then
    log_info "✅ Molecule tests passed"
  else
    log_error "❌ Molecule tests failed"
    exit 1
  fi
fi

# Idempotence testing (if not using Molecule)
if [[ "$RUN_IDEMPOTENCE" == true && "$RUN_MOLECULE" == false ]]; then
  log_info "Running idempotence test..."
  
  # First run
  log_info "First playbook run..."
  ansible-playbook main.yml -i "localhost," -c local \
    -e "configure_dotfiles=true" \
    -e "GITHUB_USERNAME=test-user" \
    --tags dotfiles
  
  # Second run (should be idempotent)
  log_info "Second playbook run (checking idempotence)..."
  if ansible-playbook main.yml -i "localhost," -c local \
     -e "configure_dotfiles=true" \
     -e "GITHUB_USERNAME=test-user" \
     --tags dotfiles | grep -q "changed=0"; then
    log_info "✅ Idempotence test passed"
  else
    log_error "❌ Idempotence test failed - playbook is not idempotent"
    exit 1
  fi
fi

log_info "🎉 All tests completed successfully!"
