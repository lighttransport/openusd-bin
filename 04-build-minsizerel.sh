#!/bin/bash
# OpenUSD Build and Install Script (MinSizeRel)
# Builds the configured OpenUSD project and installs to dist-minsizerel-ms/

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set paths
BUILD_DIR="${SCRIPT_DIR}/build-minsizerel"
INSTALL_DIR="${SCRIPT_DIR}/dist-minsizerel-ms"

# Check if build directory exists
if [ ! -d "${BUILD_DIR}" ]; then
    echo "========================================"
    echo "Build directory does not exist!"
    echo "Please run ./03-configure-minsizerel.sh first"
    echo "========================================"
    exit 1
fi

# Change to build directory
cd "${BUILD_DIR}"

# Get number of cores for parallel build
if command -v nproc >/dev/null 2>&1; then
    NUM_CORES=$(nproc)
elif command -v sysctl >/dev/null 2>&1; then
    NUM_CORES=$(sysctl -n hw.ncpu)
else
    NUM_CORES=4
fi

echo "========================================"
echo "Building OpenUSD (MinSizeRel)"
echo "========================================"
echo "Build directory: ${BUILD_DIR}"
echo "Install directory: ${INSTALL_DIR}"
echo "Build Type: MinSizeRel"
echo "Using ${NUM_CORES} parallel jobs"
echo "========================================"

# Build and install
cmake --build . --config MinSizeRel --target install -j "${NUM_CORES}"

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================"
    echo "Build and install completed successfully!"
    echo "========================================"
    echo "Install location: ${INSTALL_DIR}"
    echo ""
    echo "To check library size:"
    echo "  ls -lh ${INSTALL_DIR}/lib/lteusd_ms.so"
    echo ""
    echo "To generate environment script:"
    echo "  ./05-setup-env-minsizerel.sh"
    echo "========================================"
else
    echo "========================================"
    echo "Build failed!"
    echo "========================================"
    exit 1
fi
