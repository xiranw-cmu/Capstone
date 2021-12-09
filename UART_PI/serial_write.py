#!/usr/bin/env python3
import time
import serial

ser = serial.Serial(
        port='/dev/ttyUSB0', #Replace ttyS0 with ttyAM0 for Pi1,Pi2,Pi0
        baudrate = 921600,
        parity=serial.PARITY_NONE,
        stopbits=serial.STOPBITS_ONE,
        bytesize=serial.EIGHTBITS,
        timeout=1
)
counter=0

for i in range(2860):
        ser.write(bytes('Ab Cd Ef Gh Ij Kl MnH', 'ascii'))
        time.sleep(1e-6)
        #counter += 1
