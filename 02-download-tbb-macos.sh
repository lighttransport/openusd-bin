#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TBB_SRC_DIR="${SCRIPT_DIR}/tbb-src"
TBB_BUILD_DIR="${SCRIPT_DIR}/tbb-build"
TBB_INSTALL_DIR="${SCRIPT_DIR}/dist/tbb"
TBB_VERSION="v2021.12.0"

echo "=== Building Intel oneTBB ${TBB_VERSION} for macOS ARM64 ==="

# Clone TBB if not exists
if [ ! -d "${TBB_SRC_DIR}" ]; then
    echo "Cloning TBB repository..."
    git clone --branch ${TBB_VERSION} --depth 1 \
        https://github.com/oneapi-src/oneTBB.git "${TBB_SRC_DIR}"
else
    echo "TBB source already exists at ${TBB_SRC_DIR}"
fi

# Create build directory
mkdir -p "${TBB_BUILD_DIR}"
cd "${TBB_BUILD_DIR}"

echo ""
echo "=== Configuring TBB ==="
cmake -G "Ninja" \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_INSTALL_PREFIX="${TBB_INSTALL_DIR}" \
    -DTBB_TEST=OFF \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    "${TBB_SRC_DIR}"

echo ""
echo "=== Building TBB ==="
NUM_CORES=$(sysctl -n hw.ncpu)
echo "Using ${NUM_CORES} cores for build"
cmake --build . --config RelWithDebInfo -j ${NUM_CORES}

echo ""
echo "=== Installing TBB ==="
cmake --install . --config RelWithDebInfo

echo ""
echo "=== TBB Build Summary ==="
echo "Installation directory: ${TBB_INSTALL_DIR}"
echo "Library files:"
ls -lh "${TBB_INSTALL_DIR}/lib"
echo ""
echo "TBB build complete!"
