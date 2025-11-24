#!/bin/bash -e

token=kDsa2ifeMFdqK35
filename=synthea-1000.tar

tmp_file=$(mktemp)
wget -q https://speicherwolke.uni-leipzig.de/index.php/s/$token/download/$filename -O "$tmp_file"

tmp_dir=$(mktemp -d)
tar -C "$tmp_dir" -xf "$tmp_file"

echo "Test files are saved under: $tmp_dir"
