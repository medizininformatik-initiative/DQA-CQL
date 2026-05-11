#!/bin/bash
set -euo pipefail

SERVER_URL="http://localhost:8080/fhir"
SCRIPT_DIR="scripts"
REPORT_DIR="reports"

mkdir -p "$REPORT_DIR"

fail() {
  local stage="$1"
  local script="$2"
  local err_log="$3"
  local out_file="${4:-}"
  echo
  echo "ERROR: $stage failed for ${script}" >&2
  if [[ -s "$err_log" ]]; then
    echo "--- blazectl stderr ---" >&2
    cat "$err_log" >&2
  fi
  if [[ -n "$out_file" && -s "$out_file" ]]; then
    echo "--- blazectl stdout (last 60 lines) ---" >&2
    tail -n 60 "$out_file" >&2
  fi
  echo "-----------------------" >&2
  exit 1
}

for SCRIPT_FILE in "$SCRIPT_DIR"/*.yml; do
  BASENAME=$(basename "$SCRIPT_FILE" .yml)
  JSON_OUTPUT="$REPORT_DIR/${BASENAME}.json"
  HTML_OUTPUT="$REPORT_DIR/${BASENAME}.html"
  ERR_LOG=$(mktemp)
  trap 'rm -f "$ERR_LOG"' EXIT

  echo "Generating report for ${BASENAME}..."

  if ! blazectl --server "$SERVER_URL" evaluate-measure "$SCRIPT_FILE" \
        > "$JSON_OUTPUT" 2> "$ERR_LOG"; then
    fail "evaluate-measure" "$BASENAME" "$ERR_LOG" "$JSON_OUTPUT"
  fi

  if ! blazectl render-report < "$JSON_OUTPUT" > "$HTML_OUTPUT" 2> "$ERR_LOG"; then
    fail "render-report" "$BASENAME" "$ERR_LOG" "$JSON_OUTPUT"
  fi

  rm -f "$ERR_LOG"
  echo "Generated: $JSON_OUTPUT and $HTML_OUTPUT"
done

echo "All HTML reports generated."
