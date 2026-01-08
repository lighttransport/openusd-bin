#!/bin/bash
# OpenUSD Checkout Script
# Clones the lighttransport/openusd repository

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set paths
OPENUSD_SRC_DIR="${SCRIPT_DIR}/openusd"

echo "========================================"
echo "Cloning OpenUSD from lighttransport"
echo "========================================"
echo "Repository: https://github.com/lighttransport/openusd"
echo "Target directory: ${OPENUSD_SRC_DIR}"
echo "========================================"

if [ -d "${OPENUSD_SRC_DIR}" ]; then
    echo "Directory ${OPENUSD_SRC_DIR} already exists."
    read -p "Do you want to update it? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Updating existing repository..."
        cd "${OPENUSD_SRC_DIR}"
        git fetch origin
        git pull origin main
    else
        echo "Using existing repository."
    fi
else
    echo "Cloning repository..."
    git clone https://github.com/lighttransport/openusd.git "${OPENUSD_SRC_DIR}"
fi

echo ""
echo "========================================"
echo "Checkout completed successfully!"
echo "========================================"
echo "Source location: ${OPENUSD_SRC_DIR}"
echo ""
echo "Next step: Run ./02-download-tbb.sh"
echo "========================================"
