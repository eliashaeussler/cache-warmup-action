#!/usr/bin/env bash
# shellcheck disable=SC2155
set -e

readonly version="$1"
readonly pharFile="./cache-warmup.phar"
readonly signatureFile="./cache-warmup.phar.asc"

# Determine source URLs
if [ "${version}" == "latest" ]; then
    sourceUrl="https://github.com/eliashaeussler/cache-warmup/releases/latest/download/cache-warmup.phar"
    signatureUrl="https://github.com/eliashaeussler/cache-warmup/releases/latest/download/cache-warmup.phar.asc"
else
    sourceUrl="https://github.com/eliashaeussler/cache-warmup/releases/download/${version}/cache-warmup.phar"
    signatureUrl="https://github.com/eliashaeussler/cache-warmup/releases/download/${version}/cache-warmup.phar.asc"
fi

# Download PHAR file
function _download_phar() {
    curl -sSL "${sourceUrl}" -o "${pharFile}"
    chmod +x "${pharFile}"
}

# Verify PHAR file with GPG signature
function _verify_phar() {
    curl -sSL "${signatureUrl}" -o "${signatureFile}"
    gpg --keyserver keys.openpgp.org --recv-keys E73F20790A629A2CEF2E9AE57C1C5363490E851E
    gpg --verify "${signatureFile}" "${pharFile}"
}

# Resolve library version
function _get_phar_version() {
    if [ "${version}" == "latest" ]; then
        pharVersion="$("${pharFile}" --version | awk '{print $2}')"
    else
        pharVersion="${version}"
    fi
}

_download_phar
_verify_phar
_get_phar_version

# Expose variables
echo "pharFile=${pharFile}" >> "${GITHUB_OUTPUT}"
echo "pharVersion=${pharVersion}" >> "${GITHUB_OUTPUT}"
