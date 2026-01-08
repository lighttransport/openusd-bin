# GitHub Actions Workflows

This repository contains automated workflows for building OpenUSD MinSizeRel binaries.

## Workflows

### 1. Build OpenUSD MinSizeRel (`build-minsizerel.yml`)

**Triggers:**
- Push to `main` or `master` branch
- Pull requests to `main` or `master` branch
- Manual dispatch via GitHub UI

**What it does:**
1. Sets up Ubuntu build environment
2. Installs dependencies (cmake, ninja, uv, etc.)
3. Clones OpenUSD repository
4. Builds TBB library
5. Configures and builds OpenUSD in MinSizeRel mode
6. Verifies the build
7. Packages and uploads artifacts

**Artifacts:**
- `openusd-minsizerel-linux-x86_64.tar.gz` - Compressed installation (retained 30 days)
- `openusd-minsizerel-installation` - Uncompressed directory (retained 7 days)

**Usage:**
```bash
# Download artifact from GitHub Actions run
# Extract and use
tar -xzf openusd-minsizerel-linux-x86_64.tar.gz
cd openusd-minsizerel-linux-x86_64
source setup-usd-env.sh
```

### 2. Build and Release (`release.yml`)

**Triggers:**
- GitHub release created
- Manual dispatch with optional release creation

**What it does:**
1. Builds OpenUSD MinSizeRel (same as above)
2. Generates build information file
3. Creates versioned package
4. Calculates SHA256 checksums
5. Attaches artifacts to GitHub release (if triggered by release)

**Release Artifacts:**
- `openusd-X.Y.Z-minsizerel-linux-x86_64.tar.gz` - Versioned build
- `checksums.txt` - SHA256 checksums
- `BUILD_INFO.txt` - Detailed build information (included in tarball)

**Manual Release:**
Go to Actions → Build and Release → Run workflow
- Check "Create a new release"
- Enter release tag (e.g., `v1.0.0`)

## Build Configuration

Both workflows build with:
- **Build Type:** MinSizeRel
- **Namespace:** pxr_lte
- **Library Prefix:** lte
- **Monolithic:** ON
- **Library Size:** ~45 MB
- **Platform:** Ubuntu latest (currently 22.04)

## Environment Requirements

The workflows install:
- build-essential (gcc, g++, make)
- cmake
- ninja-build
- libgl1-mesa-dev, libglu1-mesa-dev
- python3-dev
- uv (Python package manager)

## Build Time

Typical build time: ~30-45 minutes on GitHub Actions runners

## Artifact Usage

After downloading an artifact:

```bash
# Extract
tar -xzf openusd-*-minsizerel-linux-x86_64.tar.gz

# The extracted directory contains:
# - bin/           USD command-line tools
# - lib/           Shared libraries (lteusd_ms.so)
# - include/       Header files
# - lib/python/    Python bindings
# - setup-usd-env.sh

# Setup environment
source setup-usd-env.sh

# Verify
usdcat --help
python -c "from pxr import Usd; print(Usd.GetVersion())"
```

## Notes

- Artifacts are built for **Linux x86_64** only
- TBB library is included in the distribution
- Python version is determined by the GitHub Actions runner (currently Python 3.10+)
- The build excludes imaging, MaterialX, OpenVDB, and other optional features
- `.pyc` files and `__pycache__` directories are excluded from artifacts

## Customization

To modify the build:

1. Edit the workflow YAML file in `.github/workflows/`
2. Modify build scripts (`03-configure-minsizerel.sh`, etc.)
3. Adjust CMake options in the configure script
4. Change artifact retention days in the workflow

## Troubleshooting

**Build fails at TBB step:**
- Check TBB version compatibility in `02-download-tbb.sh`

**Build fails at configure step:**
- Review CMake options in `03-configure-minsizerel.sh`
- Check that all dependencies are installed

**Python import fails:**
- Ensure `setup-usd-env.sh` was sourced
- Check `PYTHONPATH` includes `lib/python`

## Security

- Workflows use pinned action versions (@v4)
- Dependencies are installed via official package managers
- No credentials required for building
- GITHUB_TOKEN is only used for release creation (write:releases permission)
