#!/bin/bash
# OpenUSD CMake Configuration Script (MinSizeRel - macOS ARM64)
# Build Type: MinSizeRel (optimized for minimal size)
# Custom Namespace: pxr_lte
# Library Prefix: lte
# Monolithic build enabled
# Uses uv venv for Python environment

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set paths
SOURCE_DIR="${SCRIPT_DIR}/openusd"
BUILD_DIR="${SCRIPT_DIR}/build-minsizerel"
INSTALL_DIR="${SCRIPT_DIR}/dist-minsizerel-ms"
TBB_ROOT="${SCRIPT_DIR}/dist/tbb"
VENV_DIR="${SCRIPT_DIR}/.venv"

# Check if source exists
if [ ! -d "${SOURCE_DIR}" ]; then
    echo "========================================"
    echo "ERROR: OpenUSD source not found at ${SOURCE_DIR}"
    echo "========================================"
    echo "Please run ./01-checkout-macos.sh first"
    echo "========================================"
    exit 1
fi

# Check if TBB exists
if [ ! -d "${TBB_ROOT}" ] || [ ! -f "${TBB_ROOT}/include/oneapi/tbb.h" ]; then
    echo "========================================"
    echo "ERROR: TBB not found at ${TBB_ROOT}"
    echo "========================================"
    echo "Please run ./02-download-tbb-macos.sh first"
    echo "========================================"
    exit 1
else
    echo "Using existing TBB at ${TBB_ROOT}"
fi

# Setup Python environment using uv
echo "========================================"
echo "Setting up Python environment with uv"
echo "========================================"

if ! command -v uv >/dev/null 2>&1; then
    echo "ERROR: uv is not installed. Please install uv first:"
    echo "  curl -LsSf https://astral.sh/uv/install.sh | sh"
    exit 1
fi

# Create virtual environment if it doesn't exist
if [ ! -d "${VENV_DIR}" ]; then
    echo "Creating virtual environment at ${VENV_DIR}..."
    uv venv "${VENV_DIR}"
fi

# Get Python paths from venv
PYTHON_EXECUTABLE="${VENV_DIR}/bin/python"
if [ ! -f "${PYTHON_EXECUTABLE}" ]; then
    echo "ERROR: Python executable not found in venv"
    exit 1
fi

PYTHON_VERSION=$("${PYTHON_EXECUTABLE}" -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
echo "Using Python ${PYTHON_VERSION} from ${VENV_DIR}"

# Install required Python packages
echo "Installing required Python packages..."
uv pip install --python "${PYTHON_EXECUTABLE}" PyOpenGL jinja2

# Create build directory if it doesn't exist
mkdir -p "${BUILD_DIR}"

# Set TBB environment variable for FindTBB module
export TBB_INSTALL_DIR="${TBB_ROOT}"

# Change to build directory
cd "${BUILD_DIR}"

echo "========================================"
echo "Configuring OpenUSD - MinSizeRel (macOS ARM64)"
echo "========================================"
echo "Build Type:       MinSizeRel"
echo "Source Dir:       ${SOURCE_DIR}"
echo "Build Dir:        ${BUILD_DIR}"
echo "Install Dir:      ${INSTALL_DIR}"
echo "TBB Dir:          ${TBB_ROOT}"
echo "Python:           ${PYTHON_EXECUTABLE} (${PYTHON_VERSION})"
echo "Namespace:        pxr_lte (external)"
echo "Internal NS:      pxrInternal_v0_25_11"
echo "Library Prefix:   lte"
echo "Monolithic:       ON"
echo "========================================"

# Configure with CMake
cmake \
    -G "Ninja" \
    -DCMAKE_BUILD_TYPE=MinSizeRel \
    -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DCMAKE_PREFIX_PATH="${TBB_ROOT}" \
    -DTBB_INCLUDE_DIR="${TBB_ROOT}/include" \
    -DTBB_LIBRARY="${TBB_ROOT}/lib/libtbb.dylib" \
    -DPXR_SET_EXTERNAL_NAMESPACE=pxr_lte \
    -DPXR_SET_INTERNAL_NAMESPACE=pxrInternal_v0_25_11 \
    -DPXR_LIB_PREFIX=lte \
    -DPXR_BUILD_MONOLITHIC=ON \
    -DPXR_ENABLE_PYTHON_SUPPORT=ON \
    -DPXR_BUILD_IMAGING=OFF \
    -DPXR_BUILD_USD_IMAGING=OFF \
    -DPXR_BUILD_USDVIEW=OFF \
    -DPXR_BUILD_TESTS=OFF \
    -DPXR_BUILD_EXAMPLES=OFF \
    -DPXR_BUILD_TUTORIALS=OFF \
    -DPXR_BUILD_USD_TOOLS=ON \
    -DPXR_ENABLE_HDF5_SUPPORT=OFF \
    -DPXR_ENABLE_MATERIALX_SUPPORT=OFF \
    -DPXR_ENABLE_OPENVDB_SUPPORT=OFF \
    -DPXR_ENABLE_PTEX_SUPPORT=OFF \
    -DPXR_USE_DEBUG_PYTHON=OFF \
    -DPython3_EXECUTABLE="${PYTHON_EXECUTABLE}" \
    -DPython3_INCLUDE_DIR="$("${PYTHON_EXECUTABLE}" -c "from sysconfig import get_path; print(get_path('include'))")" \
    -DPython3_LIBRARY="" \
    "${SOURCE_DIR}"

echo ""
echo "========================================"
echo "Configuration complete!"
echo "========================================"
echo "Next step: Run ./04-build-minsizerel-macos.sh to build and install"
echo "========================================"
