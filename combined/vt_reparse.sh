#!/bin/bash

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
combind_dir="$script_dir"
analysis_dir="$(dirname -- "$combind_dir")/analysis"
data_dir="$analysis_dir/data"
trace_dir="$analysis_dir/traces"

vt_program="/home/yiruiz2/Downloads/vt-cli/build/vt"
vt_key="816cf78026e3ad8ddaefafe289ce27c68cc80f10a0c5d09449ee29f5a5ec261f"
vt_parser="$script_dir/vt_parser.py"

for folder in "$data_dir"/*; do
  vt_info_file="$folder/run.info.json"
  timing_file="$folder/run.info.timing"
  info_file="$folder/run.info"
  if [ -f "$vt_info_file" ]; then
    python3 "$vt_parser" "$vt_info_file" > "$info_file"
    cat "$timing_file" >> "$info_file"
  fi
done
