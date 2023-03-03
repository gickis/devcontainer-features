#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Definition specific tests
check "kubeconform" kubeconform -v

# Report result
reportResults