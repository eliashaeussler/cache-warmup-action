#!/usr/bin/env bash
# shellcheck disable=SC2155
set -e

# Action inputs
readonly version="$1"
readonly sitemaps=("${2//'\n'/ }")
readonly urls=("${3//'\n'/ }")
readonly limit="$4"
readonly config="$5"

# Downloaded files
readonly pharFile="./cache-warmup.phar"
readonly signatureFile="./cache-warmup.phar.asc"
pharVersion=""

# Determine source URLs for download from GitHub release
if [ "${version}" == "latest" ]; then
    readonly sourceUrl="https://github.com/eliashaeussler/cache-warmup/releases/latest/download/cache-warmup.phar"
    readonly signatureUrl="https://github.com/eliashaeussler/cache-warmup/releases/latest/download/cache-warmup.phar.asc"
else
    readonly sourceUrl="https://github.com/eliashaeussler/cache-warmup/releases/download/${version}/cache-warmup.phar"
    readonly signatureUrl="https://github.com/eliashaeussler/cache-warmup/releases/download/${version}/cache-warmup.phar.asc"
fi

# Pass generic error message to action output and exit
function error() {
    local title="$1"
    local message="$2"

    echo "::error title=${title}::${message}"
    exit 1
}

# Check requirements
function check_requirements() {
    # Verify local PHP installation
    if ! which php >/dev/null; then
        error 'PHP not installed' 'Unable to detected local PHP installation.'
    fi

    # Verify GPG installation
    if ! which gpg >/dev/null; then
        error 'GPG not installed' 'Unable to detect local GPG installation.'
    fi
}

# Download PHAR file from GitHub release
function download_phar_file() {
    curl -sSL "${sourceUrl}" -o "${pharFile}"
    curl -sSL "${signatureUrl}" -o "${signatureFile}"
    chmod +x "${pharFile}"
}

# Verify PHAR file with GPG signature
function verify_phar_file() {
    gpg --keyserver keys.openpgp.org --recv-keys E73F20790A629A2CEF2E9AE57C1C5363490E851E
    gpg --verify "${signatureFile}" "${pharFile}"
}

# Resolve library version from PHAR file
function resolve_phar_version() {
    if [ "${version}" == "latest" ]; then
        pharVersion="$("${pharFile}" --version | awk '{print $2}')"
    else
        pharVersion="${version}"
    fi
}

# Verify configured config file
function verify_config_file() {
    local majorVersion="$(echo "${pharVersion}" | xargs | awk -F. '{print $1}')"

    # Check if config file support is available
    if [ -n "${config}" ] && [ "${majorVersion}" -lt 3 ]; then
        error 'Config file not supported' 'Support for config files has been added in v3 of the library.'
    fi
}

function run_cache_warmup() {
    local sitemap
    local url
    local args=("--no-interaction")

    # Parse configured sitemaps
    for sitemap in "${sitemaps[@]}"; do
        if [ -n "${sitemap}" ]; then
            args+=("${sitemap// /}")
        fi
    done

    # Parse configured URLs
    for url in "${urls[@]}"; do
        if [ -n "${url}" ]; then
            args+=(-u "${url// /}")
        fi
    done

    # Parse additional config options
    if [ -n "${limit}" ]; then
        args+=(--limit "${limit}")
    fi

    # Add config file argument
    if [ -n "${config}" ]; then
        args+=(--config "${config}")
    fi

    # Run cache warmup
    "${pharFile}" "${args[@]}"
}

# Expose variables as action outputs
function export_output_variables() {
    echo "version=${pharVersion}" >> "${GITHUB_OUTPUT}"
}

check_requirements
download_phar_file
verify_phar_file
resolve_phar_version
verify_config_file
run_cache_warmup
export_output_variables
