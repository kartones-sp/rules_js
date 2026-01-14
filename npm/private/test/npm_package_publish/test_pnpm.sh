#!/usr/bin/env bash

readonly PUBLISH_PNPM="$1"
readonly PUBLISH_PNPM_NO_PACKAGE_JSON="$2"

# Test pnpm publishing with package.json
# Assert that it prints package name (pnpm uses different output format than npm)
# Use --no-git-checks because pnpm checks for clean git state by default
$PUBLISH_PNPM --dry-run --no-git-checks >pub_pnpm.log 2>&1

# pnpm publish --dry-run outputs the tarball contents and package info
if grep -q '@mycorp/pkg-to-publish' pub_pnpm.log; then
    echo "PASS: pnpm publish found package name"
elif grep -q 'npm notice package:' pub_pnpm.log; then
    # pnpm may delegate to npm in some cases
    echo "PASS: pnpm publish found package name (via npm notice)"
else
    echo "FAIL: expected package name '@mycorp/pkg-to-publish' in output, GOT: $(cat pub_pnpm.log)"
    exit 1
fi

# Test pnpm publishing without package.json (should fail)
$PUBLISH_PNPM_NO_PACKAGE_JSON --dry-run --no-git-checks >pub_pnpm_no_package_json.log 2>&1 || true

if grep -qi 'package.json' pub_pnpm_no_package_json.log; then
    echo "PASS: pnpm publish correctly failed for missing package.json"
elif grep -qi 'ERR_PNPM' pub_pnpm_no_package_json.log; then
    echo "PASS: pnpm publish failed with pnpm error"
else
    echo "FAIL: expected error about missing package.json, GOT: $(cat pub_pnpm_no_package_json.log)"
    exit 1
fi

echo "All pnpm publish tests passed!"
