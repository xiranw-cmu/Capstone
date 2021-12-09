#!/usr/bin/env python3
import time
import serial

ser = serial.Serial(
        port='/dev/ttyUSB0',
        baudrate = 921600,
        parity=serial.PARITY_NONE,
        stopbits=serial.STOPBITS_ONE,
        bytesize=serial.EIGHTBITS,
        timeout=1
)
count = 0
t = 0
temp = 0
while 1:
    x=ser.read(21)
    if x != b'' and count == 0:
        t = time.time()
        print(t)
    if x != b'':
        count+=1
        print(x, count, " ")
    if count == 2859:
        temp = time.time()
        print(temp-t)
        break
