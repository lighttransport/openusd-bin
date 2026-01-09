#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENUSD_SRC_DIR="${SCRIPT_DIR}/openusd"

echo "=== Cloning OpenUSD Repository ==="
echo "Source: https://github.com/lighttransport/openusd.git"
echo "Destination: ${OPENUSD_SRC_DIR}"

if [ -d "${OPENUSD_SRC_DIR}" ]; then
    echo "Directory ${OPENUSD_SRC_DIR} already exists."
    echo "Skipping clone. Remove directory to re-clone."
else
    git clone https://github.com/lighttransport/openusd.git "${OPENUSD_SRC_DIR}"
    echo "Clone complete."
fi

echo ""
echo "=== Repository Information ==="
cd "${OPENUSD_SRC_DIR}"
echo "Current branch: $(git branch --show-current)"
echo "Latest commit: $(git log -1 --oneline)"
echo ""
echo "Checkout complete!"
