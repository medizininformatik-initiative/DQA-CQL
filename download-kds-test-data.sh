#!/bin/bash -e

base=https://raw.githubusercontent.com/medizininformatik-initiative/mii-testdata/refs/heads/main/kds-testdata/fsh-generated/resources

tmp_dir=$(mktemp -d)
for i in {1..11}; do
  wget -q "$base/Bundle-mii-exa-test-data-bundle-pat-$i.json" -O "$tmp_dir/Bundle-mii-exa-test-data-bundle-pat-$i.json"
done

echo "Test files are saved under: $tmp_dir"
