#!/usr/bin/env bash
set -e

# Clean up
rm -rf /var/lib/apt/lists/*

KUBESEAL_VERSION="${KUBESEAL:-"latest"}"

KUBESEAL_SHA256="${KUBESEAL_SHA256:-"automatic"}"


if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Figure out correct version of a three part version number is not passed
find_version_from_git_tags() {
    local variable_name=$1
    local requested_version=${!variable_name}
    if [ "${requested_version}" = "none" ]; then return; fi
    local repository=$2
    local prefix=${3:-"tags/v"}
    local separator=${4:-"."}
    local last_part_optional=${5:-"false"}
    if [ "$(echo "${requested_version}" | grep -o "." | wc -l)" != "2" ]; then
        local escaped_separator=${separator//./\\.}
        local last_part
        if [ "${last_part_optional}" = "true" ]; then
            last_part="(${escaped_separator}[0-9]+)?"
        else
            last_part="${escaped_separator}[0-9]+"
        fi
        local regex="${prefix}\\K[0-9]+${escaped_separator}[0-9]+${last_part}$"
        local version_list="$(git ls-remote --tags ${repository} | grep -oP "${regex}" | tr -d ' ' | tr "${separator}" "." | sort -rV)"
        if [ "${requested_version}" = "latest" ] || [ "${requested_version}" = "current" ] || [ "${requested_version}" = "lts" ]; then
            declare -g ${variable_name}="$(echo "${version_list}" | head -n 1)"
        else
            set +e
            declare -g ${variable_name}="$(echo "${version_list}" | grep -E -m 1 "^${requested_version//./\\.}([\\.\\s]|$)")"
            set -e
        fi
    fi
    if [ -z "${!variable_name}" ] || ! echo "${version_list}" | grep "^${!variable_name//./\\.}$" > /dev/null 2>&1; then
        echo -e "Invalid ${variable_name} value: ${requested_version}\nValid values:\n${version_list}" >&2
        exit 1
    fi
    echo "${variable_name}=${!variable_name}"
}

apt_get_update()
{
    if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update -y
    fi
}

# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        apt_get_update
        apt-get -y install --no-install-recommends "$@"
    fi
}

# Ensure apt is in non-interactive to avoid prompts
export DEBIAN_FRONTEND=noninteractive

# Install dependencies
check_packages curl ca-certificates coreutils
if ! type git > /dev/null 2>&1; then
    check_packages git
fi

architecture="$(uname -m)"
case $architecture in
    x86_64) architecture="amd64";;
    aarch64 | armv8*) architecture="arm64";;
    aarch32 | armv7* | armvhf*) architecture="arm";;
    i?86) architecture="386";;
    *) echo "(!) Architecture $architecture unsupported"; exit 1 ;;
esac

# Install kubeseal, verify checksum
if [ "${KUBESEAL_VERSION}" != "none" ] && ! type kubeseal > /dev/null 2>&1; then

    echo "Downloading kubeseal..."

    find_version_from_git_tags KUBESEAL_VERSION https://github.com/bitnami-labs/sealed-secrets

    KUBESEAL_VERSION="${KUBESEAL_VERSION}"

    curl -sSL -o /tmp/kubeseal-${KUBESEAL_VERSION}-linux-${architecture}.tar.gz "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-${KUBESEAL_VERSION}-linux-${architecture}.tar.gz"

    if [ "$KUBESEAL_SHA256" = "automatic" ]; then
        KUBESEAL_SHA256="$(curl -sSL "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/sealed-secrets_${KUBESEAL_VERSION}_checksums.txt" | grep kubeseal-${KUBESEAL_VERSION}-linux-${architecture}.tar.gz | cut -f1 -d' ')"
        echo $KUBESEAL_SHA256
    fi
    ([ "${KUBESEAL_SHA256}" = "dev-mode" ] || (echo "${KUBESEAL_SHA256} */tmp/kubeseal-${KUBESEAL_VERSION}-linux-${architecture}.tar.gz" | sha256sum -c -))
    tar -xf /tmp/kubeseal-${KUBESEAL_VERSION}-linux-${architecture}.tar.gz --directory /usr/local/bin/
    chmod 0755 /usr/local/bin/kubeseal
    rm /tmp/kubeseal-${KUBESEAL_VERSION}-linux-${architecture}.tar.gz
    if ! type kubeseal > /dev/null 2>&1; then
        echo '(!) kubeseal installation failed!'
        exit 1
    fi
else
    if ! type kubeseal > /dev/null 2>&1; then
        echo "Skipping kubeseal."
    else
        echo "kubeseal already instaled"
    fi
fi

# Clean up
rm -rf /var/lib/apt/lists/*

echo -e "\nDone!"