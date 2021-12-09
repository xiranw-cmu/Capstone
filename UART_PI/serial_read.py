#!/usr/bin/env python3
import time
import serial

ser = serial.Serial(
        port='/dev/ttyUSB0',
        baudrate = 576000,
        parity=serial.PARITY_NONE,
        stopbits=serial.STOPBITS_ONE,
        bytesize=serial.EIGHTBITS,
        timeout=1
)

## ali needs to figure out how many test cases there are
file_name = 'sim_output.txt'
test_cases = sys.argv[2]
prev = ''
with open (file_name, "w") as f:
    t = 0
    temp = 0
    while 1:
        x=ser.read(3)
        line = x.hex() ## hex string formatted like DATA-DATA-REG-0000
        result = f"{line[4]}{line[0:3]}"
        if x != b'' and count == 0:
            t = time.time()
            print(t)
        if x != b'':
            count+=1
            prev = x
            f.write(result + "\n")
            print(x, count, " ")
        if count == test_cases:
            temp = time.time()
            print(temp-t)
            break
        if x == b'' and prev == b'' and count > 0:
            print("OH NO!!")
