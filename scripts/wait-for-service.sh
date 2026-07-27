#!/usr/bin/env bash
set -euo pipefail

API_URL="${DOCLING_API_URL:-http://127.0.0.1:5001}"
TIMEOUT="${DOCLING_WAIT_TIMEOUT:-300}"
INTERVAL="${DOCLING_WAIT_INTERVAL:-3}"
DEADLINE=$((SECONDS + TIMEOUT))

printf 'Waiting for Docling Serve at %s' "$API_URL"
while (( SECONDS < DEADLINE )); do
  if curl --fail --silent --show-error --max-time 5 "$API_URL/docs" >/dev/null 2>&1; then
    printf '\nDocling Serve is ready.\n'
    exit 0
  fi

  printf '.'
  sleep "$INTERVAL"
done

printf '\nTimed out after %s seconds. Inspect logs with: make logs\n' "$TIMEOUT" >&2
exit 1
