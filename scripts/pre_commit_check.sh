#!/bin/bash

# Pre-commit checks script
# This runs the same checks as the CI pipeline locally before committing

set -e

echo "🔍 Running pre-commit checks..."

# Ensure pre-commit is available
if ! command -v pre-commit &> /dev/null; then
    echo "Installing pre-commit..."
    python3 -m pip install pre-commit
    export PATH="$PATH:$HOME/Library/Python/3.9/bin"
fi

# Install pre-commit hooks if not already installed
if [ ! -f .git/hooks/pre-commit ]; then
    echo "Installing pre-commit hooks..."
    pre-commit install
fi

# Run pre-commit checks
echo "Running all pre-commit checks..."
pre-commit run --all-files

echo "✅ All checks passed! You're ready to commit."
