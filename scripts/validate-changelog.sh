#!/usr/bin/env bash
set -euo pipefail

CHANGELOG="CHANGELOG.md"
VERSION_FILE="VERSION"
ERRORS=0
WARNINGS=0

# --- Helpers ---
fail() {
	echo "ERROR: $1"
	ERRORS=$((ERRORS + 1))
}
warn() {
	echo "WARNING: $1"
	WARNINGS=$((WARNINGS + 1))
}

# --- 1. File existence ---
if [ ! -f "$CHANGELOG" ]; then
	echo "ERROR: $CHANGELOG does not exist."
	exit 1
fi

# --- 2. File ends with newline ---
if [ "$(tail -c 1 "$CHANGELOG" | wc -l)" -eq 0 ]; then
	fail "File does not end with a newline."
fi

# --- 3. Top-level heading ---
if ! grep -q "^# Changelog$" "$CHANGELOG"; then
	fail "Missing '# Changelog' heading (must be exactly '# Changelog' on its own line)."
fi

# --- 4. VERSION file consistency ---
if [ -f "$VERSION_FILE" ]; then
	RAW_VERSION=$(tr -d 'v\n' <"$VERSION_FILE")
	HEADING_VERSION=$(grep -m1 "^## \[" "$CHANGELOG" | awk -F'[][]' '{print $2}' | sed 's/^v//')
	if [ "$RAW_VERSION" != "$HEADING_VERSION" ]; then
		fail "Latest version in CHANGELOG ($HEADING_VERSION) does not match VERSION file ($RAW_VERSION)."
	fi
else
	warn "No VERSION file found; skipping version consistency check."
fi

# --- 5. Parse version sections ---
# Extract all version headings: line number, raw heading, version string, date
declare -a SECTION_LINES=()
declare -a SECTION_VERSIONS=()
declare -a SECTION_DATES=()

while IFS= read -r line; do
	SECTION_LINES+=("$line")
done < <(grep -n "^## \[" "$CHANGELOG" | cut -d: -f1)

for line in "${SECTION_LINES[@]}"; do
	raw=$(sed -n "${line}p" "$CHANGELOG")
	version=$(echo "$raw" | awk -F'[][]' '{print $2}' | sed 's/^v//')
	date=$(echo "$raw" | awk -F'[][]' '{print $3}' | sed 's/^ *- *//')
	SECTION_VERSIONS+=("$version")
	SECTION_DATES+=("$date")
done

# --- 6. At least one version section ---
if [ "${#SECTION_LINES[@]}" -eq 0 ]; then
	fail "No version headings (## [x.y.z]) found."
	exit 1
fi

# --- 7. Validate date format for each section ---
for date in "${SECTION_DATES[@]}"; do
	if ! [[ "$date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
		fail "Invalid date format '$date' in version heading. Expected YYYY-MM-DD."
	fi
done

# --- 8. Check descending order (newest first) ---
is_descending=true
for ((i = 0; i < ${#SECTION_VERSIONS[@]} - 1; i++)); do
	v1="${SECTION_VERSIONS[$i]}"
	v2="${SECTION_VERSIONS[$((i + 1))]}"

	# Compare version components numerically
	read -r maj1 min1 pat1 <<<"$(tr '.' ' ' <<<"$v1")"
	read -r maj2 min2 pat2 <<<"$(tr '.' ' ' <<<"$v2")"

	if [ "$maj1" -lt "$maj2" ] ||
		{ [ "$maj1" -eq "$maj2" ] && [ "$min1" -lt "$min2" ]; } ||
		{ [ "$maj1" -eq "$maj2" ] && [ "$min1" -eq "$min2" ] && [ "$pat1" -lt "$pat2" ]; }; then
		is_descending=false
		break
	fi
done

if [ "$is_descending" = false ]; then
	fail "Version entries are not in descending order (newest first)."
fi

# --- 9. Check for duplicate version numbers ---
declare -A SEEN_VERSIONS
for v in "${SECTION_VERSIONS[@]}"; do
	if [ -n "${SEEN_VERSIONS[$v]:-}" ]; then
		fail "Duplicate version '$v' found."
	fi
	SEEN_VERSIONS[$v]=1
done

# --- 10. Validate the latest entry has all metadata ---
LATEST_LINE="${SECTION_LINES[0]}"
# Find the next version heading (or end of file)
if [ "${#SECTION_LINES[@]}" -gt 1 ]; then
	LATEST_END="${SECTION_LINES[1]}"
else
	LATEST_END=$(wc -l <"$CHANGELOG")
fi

LATEST_BLOCK=$(sed -n "${LATEST_LINE},${LATEST_END}p" "$CHANGELOG")

for field in "why" "model" "tags"; do
	if ! echo "$LATEST_BLOCK" | grep -qF -- "- **${field}:**"; then
		fail "Latest entry (## [${SECTION_VERSIONS[0]}]) is missing '${field}:' metadata."
	fi
done

# --- 11. Validate each version section has at least one category ---
VALID_CATEGORIES="Added|Changed|Fixed|Removed|Security"

for ((i = 0; i < ${#SECTION_LINES[@]}; i++)); do
	v="${SECTION_VERSIONS[$i]}"
	if [ "$i" -lt $((${#SECTION_LINES[@]} - 1)) ]; then
		START="${SECTION_LINES[$i]}"
		END="${SECTION_LINES[$((i + 1))]}"
	else
		START="${SECTION_LINES[$i]}"
		END=$(wc -l <"$CHANGELOG")
	fi

	SECTION_CONTENT=$(sed -n "${START},${END}p" "$CHANGELOG")

	if ! echo "$SECTION_CONTENT" | grep -qE "^### (${VALID_CATEGORIES})$"; then
		fail "Version [${v}] has no valid category section (### Added|Changed|Fixed|Removed|Security)."
	fi
done

# --- 12. Validate category headings are exact matches ---
while IFS= read -r line; do
	heading=$(sed -n "${line}p" "$CHANGELOG")
	if ! echo "$heading" | grep -qE "^### (${VALID_CATEGORIES})$"; then
		fail "Invalid category heading: '$heading'. Must be exactly one of: Added, Changed, Fixed, Removed, Security."
	fi
done < <(grep -n "^### " "$CHANGELOG" | cut -d: -f1)

# --- 13. Validate changelog bullets have content ---
while IFS= read -r line; do
	content=$(sed -n "${line}p" "$CHANGELOG")
	# Strip the leading "- " (or just "-") and check the rest is non-empty/non-whitespace
	text=$(echo "$content" | sed 's/^- *//')
	if [ -z "$(echo "$text" | tr -d '[:space:]')" ]; then
		fail "Empty changelog bullet found at line $line."
	fi
done < <(grep -nE "^- ?" "$CHANGELOG" | cut -d: -f1)

# --- 14. Check blank lines between version sections ---
for ((i = 0; i < ${#SECTION_LINES[@]} - 1; i++)); do
	current="${SECTION_LINES[$i]}"
	next="${SECTION_LINES[$((i + 1))]}"
	next_minus_1=$((next - 1))
	line_before_next=$(sed -n "${next_minus_1}p" "$CHANGELOG")
	if [ -n "$line_before_next" ]; then
		warn "Missing blank line before version heading at line $next."
	fi
done

# --- Summary ---
echo ""
if [ "$ERRORS" -gt 0 ]; then
	echo "FAIL: $ERRORS error(s), $WARNINGS warning(s)."
	exit 1
else
	echo "OK: $CHANGELOG is valid ($WARNINGS warning(s))."
	exit 0
fi
