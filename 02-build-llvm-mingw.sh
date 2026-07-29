#!/usr/bin/env bash
# Cross-build OpenUSD v26.05 for Windows x86_64 with LLVM-MinGW.
# This is a minimal shared-monolithic build using the pxr_lte namespace and
# the lte library prefix. Python, imaging, tools, tests, and examples are off.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="${OPENUSD_SOURCE_DIR:-${SCRIPT_DIR}/openusd}"
BUILD_ROOT="${BUILD_ROOT:-${SCRIPT_DIR}/build-llvm-mingw}"
INSTALL_PREFIX="${INSTALL_PREFIX:-${SCRIPT_DIR}/dist-llvm-mingw}"
USD_BUILD_DIR="${USD_BUILD_DIR:-${BUILD_ROOT}/usd-build}"

LLVM_MINGW_VERSION="${LLVM_MINGW_VERSION:-20260616}"
LLVM_MINGW_RELEASE="${LLVM_MINGW_RELEASE:-20260616}"
LLVM_MINGW_ARCHIVE="llvm-mingw-${LLVM_MINGW_VERSION}-ucrt-ubuntu-22.04-x86_64.tar.xz"
LLVM_MINGW_URL="https://github.com/mstorsjo/llvm-mingw/releases/download/${LLVM_MINGW_RELEASE}/${LLVM_MINGW_ARCHIVE}"
LLVM_MINGW_ROOT="${LLVM_MINGW_ROOT:-${BUILD_ROOT}/${LLVM_MINGW_ARCHIVE%.tar.xz}}"

ONETBB_VERSION="${ONETBB_VERSION:-2021.12.0}"
ONETBB_ARCHIVE="oneTBB-${ONETBB_VERSION}.zip"
ONETBB_URL="https://github.com/oneapi-src/oneTBB/archive/refs/tags/v${ONETBB_VERSION}.zip"
TBB_SOURCE_DIR="${BUILD_ROOT}/oneTBB-${ONETBB_VERSION}"
TBB_BUILD_DIR="${BUILD_ROOT}/tbb-build"
JOBS="${JOBS:-$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)}"

usage() {
    echo "Usage: $(basename "$0")"
    echo "Output: ${INSTALL_PREFIX}"
    echo "Override paths and versions with BUILD_ROOT, INSTALL_PREFIX,"
    echo "OPENUSD_SOURCE_DIR, LLVM_MINGW_ROOT, LLVM_MINGW_VERSION,"
    echo "LLVM_MINGW_RELEASE, ONETBB_VERSION, USD_BUILD_DIR, and JOBS."
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi
if [[ -n "${1:-}" ]]; then
    usage >&2
    exit 2
fi

if [[ ! -f "${SOURCE_DIR}/cmake/toolchains/llvm-mingw-x86_64.cmake" ]]; then
    echo "error: LLVM-MinGW-enabled OpenUSD source not found at ${SOURCE_DIR}" >&2
    echo "Run ./01-checkout-llvm-mingw.sh first." >&2
    exit 1
fi
grep -Eq '^set\(PXR_MINOR_VERSION "26"\)$' \
    "${SOURCE_DIR}/cmake/defaults/Version.cmake"
grep -Eq '^set\(PXR_PATCH_VERSION "5"\)' \
    "${SOURCE_DIR}/cmake/defaults/Version.cmake"
for tool in cmake curl git ninja tar unzip; do
    command -v "${tool}" >/dev/null || {
        echo "error: required command not found: ${tool}" >&2
        exit 1
    }
done

mkdir -p "${BUILD_ROOT}" "${INSTALL_PREFIX}"

if [[ ! -x "${LLVM_MINGW_ROOT}/bin/x86_64-w64-mingw32-clang++" ]]; then
    llvm_mingw_archive_path="${BUILD_ROOT}/${LLVM_MINGW_ARCHIVE}"
    if [[ ! -f "${llvm_mingw_archive_path}" ]]; then
        curl -fL --retry 3 -o "${llvm_mingw_archive_path}" "${LLVM_MINGW_URL}"
    fi
    mkdir -p "${LLVM_MINGW_ROOT}"
    tar -xJf "${llvm_mingw_archive_path}" --strip-components=1 \
        -C "${LLVM_MINGW_ROOT}"
fi

export LLVM_MINGW_ROOT
TOOLCHAIN_FILE="${SOURCE_DIR}/cmake/toolchains/llvm-mingw-x86_64.cmake"

if [[ ! -f "${TBB_SOURCE_DIR}/CMakeLists.txt" ]]; then
    onetbb_archive_path="${BUILD_ROOT}/${ONETBB_ARCHIVE}"
    if [[ ! -f "${onetbb_archive_path}" ]]; then
        curl -fL --retry 3 -o "${onetbb_archive_path}" "${ONETBB_URL}"
    fi
    unzip -q "${onetbb_archive_path}" -d "${BUILD_ROOT}"
fi

# oneTBB's Clang settings otherwise add ELF-only -z linker flags for MinGW.
onetbb_clang_cmake="${TBB_SOURCE_DIR}/cmake/compilers/Clang.cmake"
sed -i 's/if (NOT APPLE)$/if (NOT APPLE AND NOT MINGW)/' \
    "${onetbb_clang_cmake}"

cmake -S "${TBB_SOURCE_DIR}" -B "${TBB_BUILD_DIR}" -G Ninja \
    -DCMAKE_TOOLCHAIN_FILE="${TOOLCHAIN_FILE}" \
    -DLLVM_MINGW_ROOT="${LLVM_MINGW_ROOT}" \
    -DMINGW=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
    -DTBB_TEST=OFF \
    -DTBB_STRICT=OFF \
    -DBUILD_SHARED_LIBS=ON
cmake --build "${TBB_BUILD_DIR}" --target install -j "${JOBS}"

cmake -S "${SOURCE_DIR}" -B "${USD_BUILD_DIR}" -G Ninja \
    -DCMAKE_TOOLCHAIN_FILE="${TOOLCHAIN_FILE}" \
    -DLLVM_MINGW_ROOT="${LLVM_MINGW_ROOT}" \
    -DTBB_DIR="${INSTALL_PREFIX}/lib/cmake/TBB" \
    -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DPXR_SET_EXTERNAL_NAMESPACE=pxr_lte \
    -DPXR_LIB_PREFIX=lte \
    -DPXR_BUILD_MONOLITHIC=ON \
    -DPXR_ENABLE_PYTHON_SUPPORT=OFF \
    -DPXR_BUILD_IMAGING=OFF \
    -DPXR_BUILD_USD_IMAGING=OFF \
    -DPXR_BUILD_USDVIEW=OFF \
    -DPXR_BUILD_TESTS=OFF \
    -DPXR_BUILD_EXAMPLES=OFF \
    -DPXR_BUILD_TUTORIALS=OFF \
    -DPXR_BUILD_USD_TOOLS=OFF \
    -DPXR_BUILD_USD_VALIDATION=OFF \
    -DPXR_BUILD_DOCUMENTATION=OFF \
    -DPXR_BUILD_EXEC=OFF \
    -DPXR_FIND_TBB_IN_CONFIG=ON \
    -DPXR_ENABLE_COMPILER_CACHE=OFF
cmake --build "${USD_BUILD_DIR}" --target install -j "${JOBS}"

test -f "${INSTALL_PREFIX}/lib/lteusd_ms.dll"
grep -Eq '^#define PXR_NS pxr_lte$' \
    "${INSTALL_PREFIX}/include/pxr/pxr.h"

{
    echo "OpenUSD 26.05 LLVM-MinGW build"
    echo "Source commit: $(git -C "${SOURCE_DIR}" rev-parse HEAD)"
    echo "Target: Windows x86_64 (UCRT)"
    echo "Toolchain: LLVM-MinGW ${LLVM_MINGW_VERSION}"
    echo "Namespace: pxr_lte"
    echo "Library prefix: lte"
    echo "Build: Release, shared monolithic, no Python or imaging"
    echo "oneTBB: ${ONETBB_VERSION}"
} > "${INSTALL_PREFIX}/BUILD_INFO.txt"

echo "LLVM-MinGW OpenUSD installed in: ${INSTALL_PREFIX}"
