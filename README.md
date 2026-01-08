# OpenUSD Build Scripts

[![Build MinSizeRel](https://github.com/YOUR_USERNAME/openusd-bin/actions/workflows/build-minsizerel.yml/badge.svg)](https://github.com/YOUR_USERNAME/openusd-bin/actions/workflows/build-minsizerel.yml)
[![Release](https://github.com/YOUR_USERNAME/openusd-bin/actions/workflows/release.yml/badge.svg)](https://github.com/YOUR_USERNAME/openusd-bin/actions/workflows/release.yml)

Build scripts for OpenUSD with LTE custom namespace and monolithic library configuration.

> **Note:** Replace `YOUR_USERNAME` in the badges above with your GitHub username after pushing to your repository.

## Prerequisites

### Linux
- CMake 3.20+
- C++17 compiler (GCC 9+ or Clang 10+)
- [uv](https://github.com/astral-sh/uv) for Python environment management
- ninja (recommended) or make

Install uv:
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### Windows
- CMake 3.20+
- Visual Studio 2019 or 2022 with C++ build tools
- [uv](https://github.com/astral-sh/uv) for Python environment management
- ninja (optional, recommended)

Install uv:
```powershell
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
```

Install ninja (optional):
```powershell
choco install ninja
```

## Build Configuration

Two build variants are available:

### RelWithDebInfo (Default)
| Option | Value |
|--------|-------|
| Namespace | `pxr_lte` |
| Library Prefix | `lte` |
| Monolithic | `ON` |
| Build Type | RelWithDebInfo |
| Install Dir | `dist/` |
| Library Size | ~878 MB |
| Python Support | ON |
| Imaging | OFF |

### MinSizeRel (Size-Optimized)
| Option | Value |
|--------|-------|
| Namespace | `pxr_lte` |
| Library Prefix | `lte` |
| Monolithic | `ON` |
| Build Type | MinSizeRel |
| Install Dir | `dist-minsizerel-ms/` |
| Library Size | ~45 MB (94.6% smaller) |
| Python Support | ON |
| Imaging | OFF |

## Build Steps

### 1. Clone Repository

**Linux:**
```bash
./01-checkout.sh
```

**Windows:**
```cmd
01-checkout.bat
```

Clones https://github.com/lighttransport/openusd to `./openusd`.

### 2. Build TBB

**Linux:**
```bash
./02-download-tbb.sh
```

**Windows:**
```cmd
02-download-tbb.bat
```

Downloads and builds Intel oneTBB v2021.12.0. Installs to `./dist/tbb`.

### 3. Configure

**Linux:**
```bash
./03-configure.sh
```

**Windows:**
```cmd
03-configure.bat
```

- Creates Python virtual environment at `./.venv` using uv
- Installs required Python packages (PyOpenGL, jinja2)
- Configures CMake with LTE namespace and monolithic build

### 4. Build and Install

**Linux:**
```bash
./04-build.sh
```

**Windows:**
```cmd
04-build.bat
```

Builds OpenUSD and installs to `./dist`.

### 5. Generate Environment Script

**Linux:**
```bash
./05-setup-env.sh
```

**Windows:**
```cmd
05-setup-env.bat
```

Generates `setup-usd-env.sh` (Linux) or `setup-usd-env.bat` (Windows) in `./dist` for setting up the runtime environment.

## Quick Start

### Default Build (RelWithDebInfo)

**Linux:**
```bash
./01-checkout.sh
./02-download-tbb.sh
./03-configure.sh
./04-build.sh
./05-setup-env.sh
```

**Windows:**
```cmd
01-checkout.bat
02-download-tbb.bat
03-configure.bat
04-build.bat
05-setup-env.bat
```

### MinSizeRel Build (Size-Optimized)

For a smaller library size (94.6% reduction):

**Linux:**
```bash
./01-checkout.sh              # Same as default
./02-download-tbb.sh          # Same as default
./03-configure-minsizerel.sh  # Configure for MinSizeRel
./04-build-minsizerel.sh      # Build MinSizeRel variant
./05-setup-env-minsizerel.sh  # Generate env script
```

**Windows:**
```cmd
01-checkout.bat                   REM Same as default
02-download-tbb.bat               REM Same as default
03-configure-minsizerel.bat       REM Configure for MinSizeRel
04-build-minsizerel.bat           REM Build MinSizeRel variant
05-setup-env-minsizerel.bat       REM Generate env script
```

**Note:** The MinSizeRel build produces a dramatically smaller library (45 MB vs 838 MB on Linux - 94.6% reduction) but may have slightly reduced performance compared to RelWithDebInfo.

## Setup

After building, set up the environment:

**Linux - RelWithDebInfo build:**
```bash
source dist/setup-usd-env.sh
```

**Linux - MinSizeRel build:**
```bash
source dist-minsizerel-ms/setup-usd-env.sh
```

**Windows - RelWithDebInfo build:**
```cmd
dist\setup-usd-env.bat
```

**Windows - MinSizeRel build:**
```cmd
dist-minsizerel-ms\setup-usd-env.bat
```

The setup script sets the following environment variables:
- `PATH` - includes `dist/bin` for USD command-line tools
- `LD_LIBRARY_PATH` - includes `dist/lib` and `dist/tbb/lib` for shared libraries
- `PYTHONPATH` - includes `dist/lib/python` for Python modules
- `PXR_PLUGINPATH_NAME` - USD plugin discovery path
- `USD_INSTALL_DIR` - points to the installation directory

To make this permanent, add to your shell profile:
```bash
echo 'source /path/to/openusd-bin/dist/setup-usd-env.sh' >> ~/.bashrc
```

## Verification

### Verify Command-Line Tools

```bash
# Check usdcat
usdcat --help

# Check usdtree
usdtree --help

# List all installed tools
ls dist/bin/
```

Expected tools: `usdcat`, `usdtree`, `usdzip`, `sdfdump`, `sdffilter`, `usdchecker`, `usddiff`, `usdedit`, `usdresolve`, `usdstitch`, `usdstitchclips`, etc.

### Verify Python Bindings

```bash
# Using the venv Python
.venv/bin/python -c "from pxr import Usd; print('USD Version:', Usd.GetVersion())"
```

Expected output:
```
USD Version: (0, 25, 11)
```

### Verify Stage Creation

```bash
.venv/bin/python << 'EOF'
from pxr import Usd, UsdGeom

# Create a new stage
stage = Usd.Stage.CreateNew('test.usda')

# Add a simple sphere
sphere = UsdGeom.Sphere.Define(stage, '/MySphere')
sphere.GetRadiusAttr().Set(2.0)

# Save the stage
stage.Save()
print("Created test.usda successfully")
EOF

# View the created file
usdcat test.usda
```

### Verify Monolithic Library

```bash
# Check monolithic library exists
ls -lh dist/lib/lteusd_ms.so

# Check library dependencies
ldd dist/lib/lteusd_ms.so | head -10
```

## Usage Examples

### Python Usage

```python
from pxr import Usd, UsdGeom, Gf

# Create a new stage
stage = Usd.Stage.CreateNew('example.usda')

# Define a transform
xform = UsdGeom.Xform.Define(stage, '/World')

# Define a mesh under the transform
mesh = UsdGeom.Mesh.Define(stage, '/World/Cube')

# Set mesh vertices (simple cube)
mesh.GetPointsAttr().Set([
    (-1, -1, -1), (1, -1, -1), (1, 1, -1), (-1, 1, -1),
    (-1, -1, 1), (1, -1, 1), (1, 1, 1), (-1, 1, 1)
])

# Save
stage.Save()
```

### Command-Line Usage

```bash
# View USD file structure
usdtree example.usda

# Convert USDA to USDC (binary)
usdcat example.usda -o example.usdc

# Flatten composed layers
usdcat --flatten composed.usda -o flattened.usda

# Create USDZ package
usdzip -r example.usdz example.usda
```

## CI/CD (GitHub Actions)

Automated builds are available via GitHub Actions.

### Available Workflows

1. **Build MinSizeRel (Linux)** - Builds on every push/PR
   - Automatically builds MinSizeRel variant for Linux x86_64
   - Uploads build artifacts (retained 30 days)
   - Run time: ~30-45 minutes

2. **Build MinSizeRel (Windows)** - Builds on every push/PR
   - Automatically builds MinSizeRel variant for Windows x86_64
   - Uploads build artifacts (retained 30 days)
   - Run time: ~35-50 minutes

3. **Build and Release (Linux)** - Creates versioned releases
   - Triggered by GitHub releases or manual dispatch
   - Generates versioned packages for Linux
   - Includes SHA256 checksums
   - Attaches artifacts to releases

4. **Build and Release (Windows)** - Creates versioned releases
   - Triggered by GitHub releases or manual dispatch
   - Generates versioned packages for Windows
   - Includes SHA256 checksums
   - Attaches artifacts to releases

### Using Pre-built Artifacts

Download from GitHub Actions or Releases:

**Linux:**
```bash
# Extract
tar -xzf openusd-*-minsizerel-linux-x86_64.tar.gz

# Setup and use
cd openusd-*-minsizerel-linux-x86_64
source setup-usd-env.sh
usdcat --help
```

**Windows:**
```powershell
# Extract
Expand-Archive openusd-*-minsizerel-windows-x86_64.zip

# Setup and use
cd openusd-*-minsizerel-windows-x86_64
.\setup-usd-env.bat
usdcat --help
```

**Platforms:** Linux x86_64 and Windows x86_64

See [`.github/WORKFLOWS.md`](.github/WORKFLOWS.md) for detailed documentation.

## Directory Structure

```
openusd-bin/
├── .github/
│   ├── workflows/
│   │   ├── build-minsizerel.yml          # CI workflow (Linux)
│   │   ├── build-minsizerel-windows.yml  # CI workflow (Windows)
│   │   ├── release.yml                    # Release workflow (Linux)
│   │   └── release-windows.yml            # Release workflow (Windows)
│   ├── WORKFLOWS.md                       # Workflow documentation
│   └── CONTRIBUTING.md                    # Contribution guide
├── .gitignore
├── 01-checkout.sh / .bat                  # Linux / Windows
├── 02-download-tbb.sh / .bat              # Linux / Windows
├── 03-configure.sh / .bat                 # Linux / Windows
├── 03-configure-minsizerel.sh / .bat      # Linux / Windows
├── 04-build.sh / .bat                     # Linux / Windows
├── 04-build-minsizerel.sh / .bat          # Linux / Windows
├── 05-setup-env.sh / .bat                 # Linux / Windows
├── 05-setup-env-minsizerel.sh / .bat      # Linux / Windows
├── README.md
├── openusd/                # Source (after checkout)
├── tbb-src/                # TBB source (after step 2)
├── tbb-build/              # TBB build (after step 2)
├── .venv/                  # Python venv (after step 3)
├── build/                  # RelWithDebInfo build
├── build-minsizerel/       # MinSizeRel build
├── dist/                   # RelWithDebInfo installation
│   ├── bin/
│   ├── lib/
│   │   └── lteusd_ms.so (~878 MB)
│   ├── include/
│   ├── tbb/
│   └── setup-usd-env.sh
└── dist-minsizerel-ms/     # MinSizeRel installation
    ├── bin/
    ├── lib/
    │   └── lteusd_ms.so (45 MB)
    ├── include/
    └── setup-usd-env.sh
```
