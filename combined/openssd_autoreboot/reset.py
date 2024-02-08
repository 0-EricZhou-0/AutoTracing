from machine import Pin, UART
import time, os

reset_pin = Pin(23, Pin.OUT)
reset_pin.value(0)

reset_pin.value(1)
time.sleep_ms(2000)
reset_pin.value(0)
