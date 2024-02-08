#!/bin/bash
# make INT terminate the whole script
trap "echo; exit" INT

# set -x

ESP32_serial=""
OpenSSD_serial=""
if [ $# -eq 1 ]; then
  printf "OpenSSD direct attach mode\n"
  OpenSSD_serial=$1
elif [ $# -eq 2 ]; then
  ESP32_serial=$1
  OpenSSD_serial=$2
  printf "ESP32 relay mode\n"
else
  printf "Usage1: %s %s\n" "$0" "<OpenSSD_serial>" 1>&2
  printf "Usage2: %s %s %s\n" "$0" "<ESP32_serial>" "<OpenSSD_serial>" 1>&2
  exit 1
fi

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ -n "$ESP32_serial" ]; then
  ampy_program="/home/yiruiz2/.local/bin/ampy"

  # power cycle through ESP32
  printf "Attempt to reset\n"
  timeout 5 "$ampy_program" --port "$ESP32_serial" reset --hard
  if [ $? -ne 0 ]; then
    printf "Hard reset failed, flush firmware\n"
    sudo python3 -m esptool --port "$ESP32_serial" --baud 115200 write_flash -z 0x1000 ~/Downloads/esp32-20230426-v1.20.0.bin
  fi
  printf "Performing power cycle\n"

  retval=1
  while true; do
    timeout 30 "$ampy_program" --port "$ESP32_serial" run "$script_dir/reset.py"
    if [ $? -ne 0 ]; then
      printf "Run reset failed, fall back to flushing firmware\n"
      sudo python3 -m esptool --port "$ESP32_serial" --baud 115200 write_flash -z 0x1000 ~/Downloads/esp32-20230426-v1.20.0.bin
    else
      printf "Power cycle done\n"
      break
    fi
  done
fi

# monitor on openSSD serial port
program_board_tcl="$script_dir/program_and_run.tcl"
# program_board_tcl="$script_dir/program_and_run_alternative.tcl"
# gnome-terminal -- bash -c "screen /dev/ttyUSB3 115200; exec bash"
python3 "$script_dir/reset_serial_read.py" "$OpenSSD_serial" &
process_pid=$!

# prepare Xilinx facilities, program FPGA and flush programs into ARM cores
export LC_ALL="C"
export DISPLAY="dummy"
source /opt/Xilinx/SDK/2019.1/settings64.sh
xsct "$program_board_tcl"

# examine if reset is successful
if wait "$process_pid"; then
  printf "Reset success\n"
else
  printf "Reset failed\n"
  exit 1
fi

