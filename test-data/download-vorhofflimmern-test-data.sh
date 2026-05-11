#!/bin/bash -e

base=https://github.com/medizininformatik-initiative/kerndatensatz-testdaten/raw/refs/heads/master/Test_Data/Vorhofflimmern

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

echo "Download from $base..."
wget -q "$base/VHF-Testdaten_01-VHF00001-VHF01000.ndjson" -O "$tmp_dir/VHF-Testdaten_01-VHF00001-VHF01000.ndjson"
wget -q "$base/VHF-Testdaten_01-VHF01001-VHF02000.ndjson" -O "$tmp_dir/VHF-Testdaten_01-VHF01001-VHF02000.ndjson"
wget -q "$base/VHF-Testdaten_01-VHF02001-VHF03000.ndjson" -O "$tmp_dir/VHF-Testdaten_01-VHF02001-VHF03000.ndjson"
wget -q "$base/VHF-Testdaten_01-VHF03001-VHF04000.ndjson" -O "$tmp_dir/VHF-Testdaten_01-VHF03001-VHF04000.ndjson"
wget -q "$base/VHF-Testdaten_01-VHF04001-VHF05000.ndjson" -O "$tmp_dir/VHF-Testdaten_01-VHF04001-VHF05000.ndjson"
wget -q "$base/VHF-Testdaten_01-VHF05001-VHF06000.ndjson" -O "$tmp_dir/VHF-Testdaten_01-VHF05001-VHF06000.ndjson"
wget -q "$base/VHF-Testdaten_01-VHF06001-VHF07000.ndjson" -O "$tmp_dir/VHF-Testdaten_01-VHF06001-VHF07000.ndjson"
wget -q "$base/VHF-Testdaten_01-VHF07001-VHF08000.ndjson" -O "$tmp_dir/VHF-Testdaten_01-VHF07001-VHF08000.ndjson"
wget -q "$base/VHF-Testdaten_01-VHF08001-VHF09000.ndjson" -O "$tmp_dir/VHF-Testdaten_01-VHF08001-VHF09000.ndjson"
wget -q "$base/VHF-Testdaten_01-VHF09001-VHF10000.ndjson" -O "$tmp_dir/VHF-Testdaten_01-VHF09001-VHF10000.ndjson"

wget -q "$base/VHF-Testdaten_02-andereDiagnose-VHF10001-VHF11000.ndjson" -O "$tmp_dir/VHF-Testdaten_02-andereDiagnose-VHF10001-VHF11000.ndjson"
wget -q "$base/VHF-Testdaten_03-andererLaborwert-VHF11001-VHF12000.ndjson" -O "$tmp_dir/VHF-Testdaten_03-andererLaborwert-VHF11001-VHF12000.ndjson"

blazectl --server "${BLAZE_SERVER:-http://localhost:8080/fhir}" upload "$tmp_dir"
