#!/usr/bin/env bash
set -e

readonly version="${1:-latest}"
readonly image="ghcr.io/eliashaeussler/cache-warmup:${version}"

# Pull Docker image
function _pull_image() {
    docker pull "${image}"
}

# Resolve library version
function _get_image_version() {
    if [ "${version}" == "latest" ]; then
        imageVersion="$(docker run --rm "${image}" --version | awk '{print $2}')"
    else
        imageVersion="${version}"
    fi
}

_pull_image
_get_image_version

# Expose variables
echo "image=${image}" >> "${GITHUB_OUTPUT}"
echo "imageVersion=${imageVersion}" >> "${GITHUB_OUTPUT}"
