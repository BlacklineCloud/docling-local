#!/usr/bin/env bash
set -euo pipefail

API_URL="${DOCLING_API_URL:-http://127.0.0.1:5001}"

curl --fail --silent --show-error --max-time 10 "$API_URL/docs" >/dev/null
printf 'OK: Docling Serve is reachable at %s\n' "$API_URL"
printf 'API docs: %s/docs\n' "$API_URL"
printf 'UI:       %s/ui\n' "$API_URL"
