# SPDX-License-Identifier: MIT
# Copyright (c) 2025 KERNEL.METAL (coccinella-labs)

#!/bin/bash

# Post-setup script: Runs after environment/VM is created and ready
# This script performs any final environment configurations

echo "Post-setup: Environment is ready"
echo "Current directory: $(pwd)"
echo "Swift version: $(swift --version | head -1)"
echo "Metal framework check: $(ls /System/Library/Frameworks/Metal.framework 2>/dev/null && echo 'Available' || echo 'Not available')"

# Add any additional setup commands here
# For example, install additional tools or set environment variables

echo "Post-setup complete"