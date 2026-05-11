#!/bin/bash -e

script_dir=$(cd "$(dirname "$0")" && pwd)

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

echo "Generate test data into $tmp_dir..."
python3 "$script_dir/generate-test-data.py" "$tmp_dir"

blazectl --server "${BLAZE_SERVER:-http://localhost:8080/fhir}" upload "$tmp_dir"
