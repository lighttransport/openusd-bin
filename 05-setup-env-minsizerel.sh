#!/bin/bash
# OpenUSD Environment Setup Script Generator (MinSizeRel)
# Creates and installs setup-usd-env.sh to dist-minsizerel-ms/

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set paths
INSTALL_DIR="${SCRIPT_DIR}/dist-minsizerel-ms"
TBB_DIR="${SCRIPT_DIR}/dist/tbb"
VENV_DIR="${SCRIPT_DIR}/.venv"
ENV_SCRIPT="${INSTALL_DIR}/setup-usd-env.sh"

# Check if install directory exists
if [ ! -d "${INSTALL_DIR}" ]; then
    echo "========================================"
    echo "Install directory does not exist!"
    echo "Please run ./04-build-minsizerel.sh first"
    echo "========================================"
    exit 1
fi

echo "========================================"
echo "Generating environment setup script"
echo "========================================"
echo "Install directory: ${INSTALL_DIR}"
echo "Output script: ${ENV_SCRIPT}"
echo "========================================"

# Get Python version from venv
PYTHON_VERSION=""
if [ -f "${VENV_DIR}/bin/python" ]; then
    PYTHON_VERSION=$("${VENV_DIR}/bin/python" -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
fi

# Create the environment setup script
cat > "${ENV_SCRIPT}" << 'SCRIPT_HEADER'
#!/bin/bash
# OpenUSD Environment Setup Script (MinSizeRel)
# Source this file to set up the environment for using OpenUSD
#
# Usage:
#   source setup-usd-env.sh
#
# This script sets:
#   - PATH: to include USD binaries
#   - LD_LIBRARY_PATH: to include USD and TBB libraries
#   - PYTHONPATH: to include USD Python modules
#   - PXR_PLUGINPATH_NAME: for USD plugin discovery

# Get the directory where this script is located
USD_INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_HEADER

# Find TBB directory relative to install dir
cat >> "${ENV_SCRIPT}" << 'SCRIPT_TBB'
# Try to find TBB directory
if [ -d "${USD_INSTALL_DIR}/../dist/tbb" ]; then
    TBB_DIR="${USD_INSTALL_DIR}/../dist/tbb"
elif [ -d "${USD_INSTALL_DIR}/tbb" ]; then
    TBB_DIR="${USD_INSTALL_DIR}/tbb"
else
    TBB_DIR=""
fi
SCRIPT_TBB

# Add Python version specific path
if [ -n "${PYTHON_VERSION}" ]; then
    cat >> "${ENV_SCRIPT}" << SCRIPT_PYTHON
PYTHON_VERSION="${PYTHON_VERSION}"
SCRIPT_PYTHON
else
    cat >> "${ENV_SCRIPT}" << 'SCRIPT_PYTHON_DETECT'
# Auto-detect Python version
PYTHON_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>/dev/null || echo "3.10")
SCRIPT_PYTHON_DETECT
fi

cat >> "${ENV_SCRIPT}" << 'SCRIPT_BODY'

# Set PATH
if [[ ":${PATH}:" != *":${USD_INSTALL_DIR}/bin:"* ]]; then
    export PATH="${USD_INSTALL_DIR}/bin:${PATH}"
fi

# Set LD_LIBRARY_PATH (Linux) / DYLD_LIBRARY_PATH (macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    if [[ ":${DYLD_LIBRARY_PATH}:" != *":${USD_INSTALL_DIR}/lib:"* ]]; then
        if [ -n "${TBB_DIR}" ]; then
            export DYLD_LIBRARY_PATH="${USD_INSTALL_DIR}/lib:${TBB_DIR}/lib:${DYLD_LIBRARY_PATH}"
        else
            export DYLD_LIBRARY_PATH="${USD_INSTALL_DIR}/lib:${DYLD_LIBRARY_PATH}"
        fi
    fi
else
    if [[ ":${LD_LIBRARY_PATH}:" != *":${USD_INSTALL_DIR}/lib:"* ]]; then
        if [ -n "${TBB_DIR}" ]; then
            export LD_LIBRARY_PATH="${USD_INSTALL_DIR}/lib:${TBB_DIR}/lib:${LD_LIBRARY_PATH}"
        else
            export LD_LIBRARY_PATH="${USD_INSTALL_DIR}/lib:${LD_LIBRARY_PATH}"
        fi
    fi
fi

# Set PYTHONPATH
USD_PYTHON_PATH="${USD_INSTALL_DIR}/lib/python"
if [[ ":${PYTHONPATH}:" != *":${USD_PYTHON_PATH}:"* ]]; then
    export PYTHONPATH="${USD_PYTHON_PATH}:${PYTHONPATH}"
fi

# Set PXR_PLUGINPATH_NAME for plugin discovery
export PXR_PLUGINPATH_NAME="${USD_INSTALL_DIR}/lib/usd"

# Export USD_INSTALL_DIR for reference
export USD_INSTALL_DIR

echo "========================================"
echo "OpenUSD Environment Configured (MinSizeRel)"
echo "========================================"
echo "USD_INSTALL_DIR: ${USD_INSTALL_DIR}"
echo "PATH includes: ${USD_INSTALL_DIR}/bin"
echo "Library path includes: ${USD_INSTALL_DIR}/lib"
if [ -n "${TBB_DIR}" ]; then
    echo "TBB library path: ${TBB_DIR}/lib"
fi
echo "PYTHONPATH includes: ${USD_PYTHON_PATH}"
echo "========================================"
echo ""
echo "Try running: usdcat --help"
echo "Or in Python: from pxr import Usd"
echo "========================================"
SCRIPT_BODY

chmod +x "${ENV_SCRIPT}"

echo ""
echo "========================================"
echo "Environment setup script created!"
echo "========================================"
echo "Script location: ${ENV_SCRIPT}"
echo ""
echo "To use OpenUSD, run:"
echo "  source ${ENV_SCRIPT}"
echo ""
echo "Or add to your shell profile:"
echo "  echo 'source ${ENV_SCRIPT}' >> ~/.bashrc"
echo "========================================"
