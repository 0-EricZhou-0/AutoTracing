#!/bin/bash

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
data_dir="$script_dir/data"

nthread=16

mapfile -t samples < <(ls "$data_dir")
for sample in "${samples[@]}"; do
  echo "$sample"
done
