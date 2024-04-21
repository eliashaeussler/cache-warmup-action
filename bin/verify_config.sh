#!/usr/bin/env bash
# shellcheck disable=SC2155
set -e

readonly majorVersion="$(echo "${1}" | xargs | awk -F. '{print $1}')"
readonly config="$2"

# Check if config file support is available
if [ -n "${config}" ] && [ "${majorVersion}" -lt 3 ]; then
    echo '::error title=Config file not supported::Support for config files has been added in v3 of the library.'
    exit 1
fi
