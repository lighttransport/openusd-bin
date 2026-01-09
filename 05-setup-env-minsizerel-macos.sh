#!/bin/bash
# Generate environment setup script for OpenUSD (MinSizeRel - macOS ARM64)
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${SCRIPT_DIR}/dist-minsizerel-ms"
TBB_DIR="${SCRIPT_DIR}/dist/tbb"
VENV_DIR="${SCRIPT_DIR}/.venv"

if [ ! -d "${INSTALL_DIR}" ]; then
    echo "========================================"
    echo "ERROR: Installation directory not found at ${INSTALL_DIR}"
    echo "========================================"
    echo "Please run ./04-build-minsizerel-macos.sh first"
    echo "========================================"
    exit 1
fi

SETUP_SCRIPT="${INSTALL_DIR}/setup-usd-env.sh"

echo "========================================"
echo "Generating environment setup script"
echo "========================================"
echo "Install Dir: ${INSTALL_DIR}"
echo "Setup Script: ${SETUP_SCRIPT}"
echo "========================================"

# Get Python version
PYTHON_EXECUTABLE="${VENV_DIR}/bin/python"
if [ ! -f "${PYTHON_EXECUTABLE}" ]; then
    echo "ERROR: Python executable not found in venv"
    exit 1
fi

PYTHON_VERSION=$("${PYTHON_EXECUTABLE}" -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")

# Generate setup script
cat > "${SETUP_SCRIPT}" << 'EOF'
#!/bin/bash
# OpenUSD Environment Setup (MinSizeRel - macOS ARM64)
# Source this file to set up the OpenUSD environment:
#   source setup-usd-env.sh

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set USD installation directory
export USD_INSTALL_DIR="${SCRIPT_DIR}"

# Set TBB directory (relative to install dir)
export TBB_DIR="${SCRIPT_DIR}/../dist/tbb"

# Add USD binaries to PATH
export PATH="${USD_INSTALL_DIR}/bin:${PATH}"

# Add USD libraries to DYLD_LIBRARY_PATH (macOS)
export DYLD_LIBRARY_PATH="${USD_INSTALL_DIR}/lib:${TBB_DIR}/lib:${DYLD_LIBRARY_PATH}"

# Set Python paths
EOF

# Add Python version-specific path
cat >> "${SETUP_SCRIPT}" << 'EOF'
export PYTHONPATH="${USD_INSTALL_DIR}/lib/python:${PYTHONPATH}"
EOF

# Continue with the rest of the setup script
cat >> "${SETUP_SCRIPT}" << 'EOF'

# Set plugin path
export PXR_PLUGINPATH_NAME="${USD_INSTALL_DIR}/lib/usd:${USD_INSTALL_DIR}/plugin/usd"

# Display setup information
echo "========================================"
echo "OpenUSD Environment Configured (macOS ARM64)"
echo "========================================"
echo "USD Install:    ${USD_INSTALL_DIR}"
echo "TBB Dir:        ${TBB_DIR}"
echo "========================================"
echo "PATH:           ${PATH}"
echo "DYLD_LIBRARY_PATH: ${DYLD_LIBRARY_PATH}"
echo "PYTHONPATH:     ${PYTHONPATH}"
echo "========================================"
echo ""
echo "Available USD tools:"
ls "${USD_INSTALL_DIR}/bin" | grep -E '^usd|^sdf' | head -10
echo "..."
echo ""
echo "Try: usdcat --help"
echo "========================================"
EOF

chmod +x "${SETUP_SCRIPT}"

echo ""
echo "========================================"
echo "Setup script generated successfully!"
echo "========================================"
echo "To use OpenUSD, source the environment setup script:"
echo ""
echo "  source ${SETUP_SCRIPT}"
echo ""
echo "Or add to your shell profile (~/.zshrc or ~/.bash_profile):"
echo ""
echo "  echo 'source ${SETUP_SCRIPT}' >> ~/.zshrc"
echo ""
echo "========================================"
