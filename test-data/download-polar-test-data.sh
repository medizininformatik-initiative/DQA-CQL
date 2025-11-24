#!/bin/bash -e

base=https://github.com/medizininformatik-initiative/kerndatensatz-testdaten/raw/refs/heads/master/Test_Data/Polar

tmp_dir=$(mktemp -d)
#wget -q "$base/POLAR_Testdaten_Original_UKB-UKB-0001-UKB-0015.ndjson" -O "$tmp_dir/POLAR_Testdaten_Original_UKB-UKB-0001-UKB-0015.ndjson"
wget -q "$base/POLAR_Testdaten_Original_UKE-UKE-0001-UKE-0020.ndjson" -O "$tmp_dir/POLAR_Testdaten_Original_UKE-UKE-0001-UKE-0020.ndjson"
wget -q "$base/POLAR_Testdaten_Original_UKFAU-UKFAU-0001-UKFAU-0011.ndjson" -O "$tmp_dir/POLAR_Testdaten_Original_UKFAU-UKFAU-0001-UKFAU-0011.ndjson"
wget -q "$base/POLAR_Testdaten_Original_UKSH-UKSH-0001-UKSH-0005.ndjson" -O "$tmp_dir/POLAR_Testdaten_Original_UKSH-UKSH-0001-UKSH-0005.ndjson"

echo "Test files are saved under: $tmp_dir"
