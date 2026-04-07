#!/bin/bash
set -euo pipefail

SERVER_URL="http://localhost:8080/fhir"
SCRIPT_DIR="scripts"
REPORT_DIR="reports"

# Ensure the reports directory exists
mkdir -p "$REPORT_DIR"

# Loop through all .yml files in the scripts directory
for SCRIPT_FILE in "$SCRIPT_DIR"/*.yml; do

  # Get the base name of the file without the extension
  BASENAME=$(basename "$SCRIPT_FILE" .yml)

  # Construct the output file path for HTML
  JSON_OUTPUT="$REPORT_DIR/${BASENAME}.json"
  HTML_OUTPUT="$REPORT_DIR/${BASENAME}.html"

  echo "Generating report for ${BASENAME}..."

  # Execute the blazectl command for HTML report
  blazectl --server "$SERVER_URL" evaluate-measure "$SCRIPT_FILE" > "$JSON_OUTPUT"
  blazectl render-report < "$JSON_OUTPUT" > "$HTML_OUTPUT"
  echo "Generated: $JSON_OUTPUT and $HTML_OUTPUT"
done

echo "All HTML reports generated."
