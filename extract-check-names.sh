#!/bin/bash
set -euo pipefail

# Scans all .yml files under the scripts/ directory for DQA check codes and
# prints a formatted table mapping each file name to its associated check code(s).
# Each "- code:" entry found in a YAML file is extracted, cleaned of quotes,
# and displayed alongside the file it came from.

# Print table header
printf "%-30s | %s\n" "Test" "DQA - Check"
printf "%-30s-|-%s\n" "------------------------------" "-------------------------------------------------------"

# Find all .yml files, search for "- code:" entries, and format the output
find scripts -type f -name "*.yml" -exec grep -H "\- code:" {} + | while IFS=: read -r filepath match; do

    # Extract the file name without the full path (no subprocess)
    filename="${filepath##*/}"

    # Clean up the matched text using bash builtins (no subprocess):
    # 1. Strip everything up to and including '- code: '
    # 2. Remove double and single quotation marks
    code_val="${match#*- code: }"
    code_val="${code_val//\"/}"
    code_val="${code_val//\'/}"

    # Print the row in tabular format
    printf "%-30s | %s\n" "$filename" "$code_val"

done
