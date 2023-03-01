#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Definition specific tests
check "kubeseal" kubeseal

# Report result
reportResults