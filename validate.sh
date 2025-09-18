#!/bin/bash
set -euo pipefail

echo "🔍 Validating Ray Coder Module..."

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is required but not installed"
    exit 1
fi

echo "✅ Terraform found: $(terraform version -json | jq -r '.terraform_version')"

# Validate main module
echo "🔧 Validating main module..."
terraform fmt -check=true -diff=true .
terraform init -backend=false
terraform validate

# Validate examples
echo "🔧 Validating examples..."
for example_dir in examples/*/; do
    if [ -d "$example_dir" ]; then
        echo "  Validating $(basename "$example_dir")..."
        cd "$example_dir"
        terraform fmt -check=true -diff=true .
        terraform init -backend=false
        terraform validate
        cd ../..
    fi
done

echo "✅ All validations passed!"
echo ""
echo "📋 Module Summary:"
echo "  - Ray Dashboard integration"
echo "  - Automatic Ray installation with virtual environment"
echo "  - Configurable Ray extras and Python packages"
echo "  - Health checks and auto-startup"
echo ""
echo "🚀 Ready for Coder registry submission!"

