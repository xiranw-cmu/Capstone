#!/usr/bin/env python3
import time
import serial
import sys
import os

ser = serial.Serial(
        port='/dev/ttyUSB0',
        baudrate = 576000,
        parity=serial.PARITY_NONE,
        stopbits=serial.STOPBITS_ONE,
        bytesize=serial.EIGHTBITS,
        timeout=1
)
path = 'outputs/'
if not os.path.exists(path):
    os.makedirs(path)

file_name = 'sim_output.txt'
test_cases = int(sys.argv[1])
with open (os.path.join(path, file_name), "w") as f:
    t = 0
    temp = 0
    count = 0
    while 1:
        x=ser.read(3)
        line = x.hex() ## hex string formatted like DATA-DATA-DATA-DATA-REG-0000
        result = line         
        if x != b'' and count == 0:
            t = time.time()
        if x != b'':
            count+=1
            result = f"{line[4]}{line[0:4]}"
            f.write(result + "\n")
        if count == test_cases:
            temp = time.time()
            print(temp-t)
            break
