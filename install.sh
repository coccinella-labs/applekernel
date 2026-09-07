# SPDX-License-Identifier: MIT
# Copyright (c) 2025 KERNEL.METAL (coccinella-labs)

#!/bin/bash

# Installation script for KERNEL.METAL project dependencies
# This script installs required tools for development and CI testing

echo "Installing actionlint for GitHub Actions linting..."
bash -c "$(curl https://raw.githubusercontent.com/rhysd/actionlint/main/scripts/download-actionlint.bash)"

echo "Installing act for local GitHub Actions testing..."
curl -s https://api.github.com/repos/nektos/act/releases/latest | jq -r '.assets[] | select(.name | contains("Darwin") and contains("arm64")) | .browser_download_url' | xargs curl -L -o act.tar.gz
tar -xzf act.tar.gz
chmod +x act
rm act.tar.gz

echo "Installing gitlab-ci-local for local GitLab CI testing..."
npm install -g gitlab-ci-local

echo "Upgrading CircleCI CLI..."
brew upgrade circleci

echo "Installation complete. Tools: actionlint, act, gitlab-ci-local, circleci"
echo "Note: Ensure Docker Desktop is installed and running for act to work. Node.js is required for gitlab-ci-local."