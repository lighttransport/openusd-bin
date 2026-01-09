#!/bin/bash
# OpenUSD Build and Install Script (MinSizeRel - macOS ARM64)
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build-minsizerel"

if [ ! -d "${BUILD_DIR}" ]; then
    echo "========================================"
    echo "ERROR: Build directory not found at ${BUILD_DIR}"
    echo "========================================"
    echo "Please run ./03-configure-minsizerel-macos.sh first"
    echo "========================================"
    exit 1
fi

cd "${BUILD_DIR}"

echo "========================================"
echo "Building OpenUSD - MinSizeRel (macOS ARM64)"
echo "========================================"
echo "Build Dir: ${BUILD_DIR}"
echo "========================================"

# Get number of cores
NUM_CORES=$(sysctl -n hw.ncpu)
echo "Using ${NUM_CORES} cores for build"

# Build and install
echo ""
echo "Building and installing..."
cmake --build . --config MinSizeRel --target install -j "${NUM_CORES}"

echo ""
echo "========================================"
echo "Build and installation complete!"
echo "========================================"
echo "Next step: Run ./05-setup-env-minsizerel-macos.sh to generate environment setup script"
echo "========================================"
