#!/bin/sh




python systolic.py --conv --channel 3 --row 3 --col 3 --ksize 3 --knum 4 -o ./test_case/conv/input1
python systolic.py --conv --channel 3 --row 3 --col 8 --ksize 3 --knum 8 -o ./test_case/conv/input2
python systolic.py --conv --channel 16 --row 3 --col 16 --ksize 3 --knum 16 -o ./test_case/conv/input3

python systolic.py --matmul --channel 3 --row 16 --col 24 --col_2 16 -o ./test_case/matmul/input1







