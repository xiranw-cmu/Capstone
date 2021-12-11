#!/bin/sh

gcc golden_model.c
./a.out $1 &
rm -rf a.out

python serial_read.py $(wc -l < $1) &
sleep 0.1
python serial_write.py $1

