#!/usr/bin/env bash
# shellcheck disable=SC2155
set -e

# Action inputs
readonly version="$INPUT_VERSION"
readonly sitemaps=("${INPUT_SITEMAPS//'\n'/ }")
readonly urls=("${INPUT_URLS//'\n'/ }")
readonly limit="$INPUT_LIMIT"
readonly progress="$INPUT_PROGRESS"
readonly verbosity="$INPUT_VERBOSITY"
readonly config="$INPUT_CONFIG"

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

function log() {
    local title="$1"
    local message="$2"

    printf "\033[32;1m✓ \033[0m\033[34;1m%s \033[0m\033[90;1m%s\033[0m\n" "${title}" "${message}"
}

# Check requirements
function check_requirements() {
    # Verify local PHP installation
    if ! which php >/dev/null; then
        error "PHP not installed" "Unable to detected local PHP installation."
    fi

    # Verify GPG installation
    if ! which gpg >/dev/null; then
        error "GPG not installed" "Unable to detect local GPG installation."
    fi
}

# Download and verify PHAR file from GitHub release
function download_phar_file() {
    # Download PHAR file
    if ! curl -fsSL "${sourceUrl}" -o "${pharFile}" 2>/dev/null; then
        error "Download failed" "Unable to download PHAR file from \"${sourceUrl}\"."
    fi

    # Make PHAR file executable
    chmod +x "${pharFile}"

    # Download signature file and verify PHAR file
    if curl -fsSL "${signatureUrl}" -o "${signatureFile}" 2>/dev/null; then
        curl -sS https://keys.openpgp.org/vks/v1/by-fingerprint/E73F20790A629A2CEF2E9AE57C1C5363490E851E -o /tmp/key.asc
        gpg --import /tmp/key.asc >/dev/null 2>&1
        rm /tmp/key.asc
        gpg --verify "${signatureFile}" "${pharFile}" 2>/dev/null
    fi

    # Resolve library version from PHAR file
    if [ "${version}" == "latest" ]; then
        pharVersion="$("${pharFile}" --version | awk '{print $2}')"
    else
        pharVersion="${version}"
    fi

    log "PHAR" "Downloaded version ${pharVersion}"
}

# Verify configured config file
function verify_config_file() {
    # Check if config file support is available
    if [ -n "${config}" ] && ! "${pharFile}" --help | grep -q -- '--config'; then
        error "Config file not supported" "Support for config files has been added in v3 of the library."
    fi
}

function run_cache_warmup() {
    local sitemap
    local url
    local args=("--no-interaction" "--ansi")

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

    # Add limit option
    if [ -n "${limit}" ]; then
        args+=(--limit "${limit}")
    fi

    # Add progress option
    if [ -n "${progress}" ]; then
        args+=(--progress)
    fi

    # Add verbosity option
    if [ "${verbosity}" == "v" ] || [ "${verbosity}" == "vv" ] || [ "${verbosity}" == "vvv" ]; then
        args+=(-"${verbosity}")
    fi

    # Add config option
    if [ -n "${config}" ]; then
        args+=(--config "${config}")
    fi

    # Run cache warmup
    printf "\n"
    "${pharFile}" "${args[@]}"
}

# Expose variables as action outputs
function export_output_variables() {
    echo "version=${pharVersion}" >> "${GITHUB_OUTPUT}"
}

check_requirements
download_phar_file
verify_config_file
run_cache_warmup
export_output_variables
