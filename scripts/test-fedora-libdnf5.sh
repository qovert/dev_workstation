#!/bin/bash
# Test script to verify Fedora libdnf5 fix

set -e

echo "🔧 Testing Fedora libdnf5 fix..."

# Check if we're on Fedora
if ! command -v dnf >/dev/null 2>&1; then
    echo "❌ This test is only for Fedora systems with DNF"
    exit 1
fi

# Test if libdnf5 is importable
echo "Testing Python libdnf5 import..."
python3 -c "import libdnf5; print('✅ libdnf5 imported successfully')" 2>/dev/null || {
    echo "❌ libdnf5 import failed. Running fix..."
    sudo dnf install -y python3-libdnf5 python3-dnf
    python3 -c "import libdnf5; print('✅ libdnf5 imported successfully after fix')"
}

# Test Ansible dnf module
echo "Testing Ansible dnf module..."
ansible localhost -m dnf -a "name=curl state=present" --check || {
    echo "❌ Ansible dnf module test failed"
    exit 1
}

echo "✅ All tests passed! Fedora libdnf5 is working correctly."
