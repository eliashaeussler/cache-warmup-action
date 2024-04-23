#!/usr/bin/env bash
# shellcheck disable=SC2155
set -e

readonly dockerImage="$1"
readonly sitemaps=("${2//'\n'/ }")
readonly urls=("${3//'\n'/ }")
readonly limit="$4"
readonly config="$5"

# Command arguments
args=("--no-interaction")

# Parse sitemaps
function _parse_sitemaps() {
    local sitemap
    for sitemap in "${sitemaps[@]}"; do
        if [ -n "${sitemap}" ]; then
            args+=("${sitemap// /}")
        fi
    done
}

# Parse URLs
function _parse_urls() {
    local url
    for url in "${urls[@]}"; do
        if [ -n "${url}" ]; then
            args+=(-u "${url// /}")
        fi
    done
}

# Parse additional config options
function _parse_config_options() {
    if [ -n "${limit}" ]; then
        args+=(--limit "${limit}")
    fi

    if [ -n "${config}" ]; then
        args+=(--config "${config}")
    fi
}

# Run cache warmup
function _run() {
    local workingDirectory="$(pwd -P)"
    docker run --rm -v "${workingDirectory}":"${workingDirectory}" -w "${workingDirectory}" "${dockerImage}" "${args[@]}"
}

_parse_sitemaps
_parse_urls
_parse_config_options
_run
