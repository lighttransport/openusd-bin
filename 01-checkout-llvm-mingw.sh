#!/usr/bin/env bash
# Checkout the OpenUSD v26.05 branch carrying the LTE namespace and
# LLVM-MinGW portability changes.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENUSD_REPOSITORY="${OPENUSD_REPOSITORY:-https://github.com/lighttransport/openusd.git}"
OPENUSD_REF="${OPENUSD_REF:-v26.05-custom-namespace}"
OPENUSD_SOURCE_DIR="${OPENUSD_SOURCE_DIR:-${SCRIPT_DIR}/openusd}"

if [[ -d "${OPENUSD_SOURCE_DIR}/.git" ]]; then
    git -C "${OPENUSD_SOURCE_DIR}" fetch origin "${OPENUSD_REF}"
    git -C "${OPENUSD_SOURCE_DIR}" checkout --detach FETCH_HEAD
elif [[ -e "${OPENUSD_SOURCE_DIR}" ]]; then
    echo "error: ${OPENUSD_SOURCE_DIR} exists but is not a Git checkout" >&2
    exit 1
else
    git clone --branch "${OPENUSD_REF}" --single-branch \
        "${OPENUSD_REPOSITORY}" "${OPENUSD_SOURCE_DIR}"
fi

echo "OpenUSD source: ${OPENUSD_SOURCE_DIR}"
echo "OpenUSD ref:    $(git -C "${OPENUSD_SOURCE_DIR}" rev-parse HEAD)"
