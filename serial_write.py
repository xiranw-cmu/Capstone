#!/usr/bin/env python3
import time
import serial
import sys

ser = serial.Serial(
        port='/dev/ttyUSB0',
        baudrate = 576000,
        parity=serial.PARITY_NONE,
        stopbits=serial.STOPBITS_ONE,
        bytesize=serial.EIGHTBITS,
        timeout=1
)
file_name = ''
if (len(sys.argv) < 2):
        file_name = "test_case.txt"
else:
        file_name = sys.argv[1]
with open(file_name) as test_fd:
        test_cases = test_fd.readlines()
        for i in range(len(test_cases)):
                test = bytes.fromhex(f"{test_cases[i][0:4]}00")
                ser.write(test)
