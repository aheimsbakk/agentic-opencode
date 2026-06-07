#!/usr/bin/env bash
set -euo pipefail

CHANGELOG="CHANGELOG.md"
ERRORS=0

if [ ! -f "$CHANGELOG" ]; then
	echo "ERROR: $CHANGELOG does not exist."
	exit 1
fi

# Check for # Changelog heading
if ! grep -q "^# Changelog" "$CHANGELOG"; then
	echo "ERROR: Missing '# Changelog' heading."
	ERRORS=$((ERRORS + 1))
fi

# Check for at least one version heading
if ! grep -q "^## \\[" "$CHANGELOG"; then
	echo "ERROR: No version heading (## [x.y.z]) found."
	ERRORS=$((ERRORS + 1))
fi

# Check changelog metadata (why, model, tags)
if ! grep -q "^\\- \\*\\*why\\*\\*:" "$CHANGELOG"; then
	echo "WARNING: Missing 'why' metadata in latest entry."
fi

if ! grep -q "^\\- \\*\\*model\\*\\*:" "$CHANGELOG"; then
	echo "WARNING: Missing 'model' metadata in latest entry."
fi

if ! grep -q "^\\- \\*\\*tags\\*\\*:" "$CHANGELOG"; then
	echo "WARNING: Missing 'tags' metadata in latest entry."
fi

if [ "$ERRORS" -gt 0 ]; then
	exit 1
fi

echo "OK: $CHANGELOG looks valid."
