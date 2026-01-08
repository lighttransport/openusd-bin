#!/bin/bash
# OpenUSD Build and Install Script
# Builds the configured OpenUSD project and installs to dist/

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set paths
BUILD_DIR="${SCRIPT_DIR}/build"
INSTALL_DIR="${SCRIPT_DIR}/dist"

# Check if build directory exists
if [ ! -d "${BUILD_DIR}" ]; then
    echo "========================================"
    echo "Build directory does not exist!"
    echo "Please run ./03-configure.sh first"
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
echo "Building OpenUSD"
echo "========================================"
echo "Build directory: ${BUILD_DIR}"
echo "Install directory: ${INSTALL_DIR}"
echo "Build Type: RelWithDebInfo"
echo "Using ${NUM_CORES} parallel jobs"
echo "========================================"

# Build and install
cmake --build . --config RelWithDebInfo --target install -j "${NUM_CORES}"

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================"
    echo "Build and install completed successfully!"
    echo "========================================"
    echo "Install location: ${INSTALL_DIR}"
    echo ""
    echo "Next step: Run ./05-setup-env.sh to generate environment script"
    echo "========================================"
else
    echo "========================================"
    echo "Build failed!"
    echo "========================================"
    exit 1
fi
