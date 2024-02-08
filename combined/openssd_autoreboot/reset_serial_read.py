import serial, sys

program_name = "OpenSSD Serial Resetter"

def setup(ser: serial.Serial, remake: bool) -> None:
  if remake:
    ser.write("X".encode())
    print(f"[{program_name}] Remaking bad-block table", file=sys.stderr)
  else:
    ser.write("A".encode())
    print(f"[{program_name}] Skip remaking bad-block table", file=sys.stderr)

if __name__ == "__main__":
  assert len(sys.argv) == 2
  serial_dev = sys.argv[1]

  try:
    try:
      ser = serial.Serial(port=serial_dev, baudrate=115200)
    except serial.serialutil.SerialException as e:
      print(e)
      exit(1)
    print(f"[{program_name}] Listening to serial " + ser.portstr)

    nlines = 0
    while True:
      line = ser.readline().decode()
      if "Press 'X' to re-make the bad block table." in line:
        setup(ser, True)
      elif "Turn on the host PC" in line:
        break
      else:
        nlines += 1
        # print(f"[{program_name}] Ignoring {nlines} lines")
        continue
      print(line, end="")

    ser.close()
    print(f"[{program_name}] Reset done, reboot required")
  except Exception as e:
    print(e)
    ser.close()

