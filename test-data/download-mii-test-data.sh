#!/bin/bash -e

base=https://raw.githubusercontent.com/medizininformatik-initiative/mii-testdata/refs/heads/main/kds-testdata/fsh-generated/resources

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

echo "Download from $base..."
for i in {1..11}; do
  wget -q "$base/Bundle-mii-exa-test-data-bundle-pat-$i.json" -O "$tmp_dir/Bundle-mii-exa-test-data-bundle-pat-$i.json"
done

blazectl --server "${BLAZE_SERVER:-http://localhost:8080/fhir}" upload "$tmp_dir"
