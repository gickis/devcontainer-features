#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Definition specific tests
check "kubeseal" kubeseal --version

# Report result
reportResults