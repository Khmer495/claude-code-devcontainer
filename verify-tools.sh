#!/bin/bash
# Script to verify tool installations

set -e

echo "=== DevContainer Tool Verification ==="
echo

# Source asdf
source /home/linuxbrew/.linuxbrew/opt/asdf/libexec/asdf.sh 2>/dev/null || true

# Check Terraform
echo "1. Terraform:"
if command -v terraform &> /dev/null; then
    terraform --version
else
    echo "   ❌ Terraform not found"
fi
echo

# Check Go
echo "2. Go:"
if command -v go &> /dev/null; then
    go version
else
    echo "   ❌ Go not found"
fi
echo

# Check Flutter
echo "3. Flutter:"
if command -v flutter &> /dev/null; then
    flutter --version
else
    echo "   ❌ Flutter not found (run install-flutter.sh to install)"
fi
echo

# Check Node.js (base image)
echo "4. Node.js (base image):"
node --version
echo

# Check npm
echo "5. npm:"
npm --version
echo

# Check Claude CLI
echo "6. Claude CLI:"
if command -v claude &> /dev/null; then
    claude --version || echo "   Claude CLI installed"
else
    echo "   ❌ Claude CLI not found"
fi
echo

# Check asdf
echo "7. asdf version manager:"
asdf --version || echo "   ❌ asdf not found"
echo

echo "=== Verification Complete ==="