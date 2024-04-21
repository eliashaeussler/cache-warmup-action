#!/usr/bin/env bash
set -e

# Verify local PHP installation
if ! which php >/dev/null; then
    echo '::error title=PHP not installed::Unable to detected local PHP installation.'
    exit 1
fi

# Verify GPG installation
if ! which gpg >/dev/null; then
    echo '::error title=GPG not installed::Unable to detect local GPG installation.'
    exit 1
fi
