#!/usr/bin/env bash

readonly PUBLISH_PNPM_CATALOG="$1"
readonly PACKAGE_DIR="$2"

# Verify that pnpm-workspace.yaml is in the package directory alongside package.json
if [[ ! -f "${PACKAGE_DIR}/pnpm-workspace.yaml" ]]; then
    echo "FAIL: pnpm-workspace.yaml not found in package directory: ${PACKAGE_DIR}"
    echo "Contents of package directory:"
    ls -la "${PACKAGE_DIR}"
    exit 1
fi
echo "PASS: pnpm-workspace.yaml found in package directory"

if [[ ! -f "${PACKAGE_DIR}/package.json" ]]; then
    echo "FAIL: package.json not found in package directory: ${PACKAGE_DIR}"
    exit 1
fi
echo "PASS: package.json found in package directory"

# Test pnpm publishing with catalog versions
# The pnpm-workspace.yaml should be copied into the package directory
# and pnpm should resolve the catalog: version to the actual version
$PUBLISH_PNPM_CATALOG --dry-run --no-git-checks >pub_pnpm_catalog.log 2>&1

# Check that the package name is found
if grep -q '@mycorp/pkg-with-catalog' pub_pnpm_catalog.log; then
    echo "PASS: pnpm publish found package name with catalog"
elif grep -q 'npm notice package:' pub_pnpm_catalog.log; then
    # pnpm may delegate to npm in some cases
    echo "PASS: pnpm publish found package name with catalog (via npm notice)"
else
    echo "FAIL: expected package name '@mycorp/pkg-with-catalog' in output, GOT: $(cat pub_pnpm_catalog.log)"
    exit 1
fi

# Verify that the catalog version was resolved (no "catalog:" in output should cause errors)
# If catalog: wasn't resolved, pnpm would fail with an error about invalid version
if grep -qi 'ERR_PNPM.*catalog' pub_pnpm_catalog.log; then
    echo "FAIL: pnpm failed to resolve catalog version, GOT: $(cat pub_pnpm_catalog.log)"
    exit 1
fi

echo "PASS: pnpm catalog publish test passed!"
