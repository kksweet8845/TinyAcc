import numpy as np
import sys
import argparse
import os


def write_macro(filepath, desc):

    fd = open(filepath, "w")

    for key, val in desc:
        fd.write(f"`define {key} {val}\n")

    fd.close()



def write_txt(filepath, mat):

    fd = open(filepath, "w")
    d1, d2 = mat.shape

    for _d1 in range(d1):
        for _d2 in range(d2):
            value = "%3d" % int(mat[_d1, _d2])
            fd.write(value)
            if _d2+1 != d2:
                fd.write(", ")
        fd.write("\n")

    fd.close()


def write_binary(filepath, mat):

    fd = open(filepath, "w")
    d1, d2 = mat.shape    

    for _d1 in range(d1):
        for _d2 in range(d2):
            byte_value = "%08d" % int(bin(mat[_d1, _d2])[2:])
            fd.write(byte_value)
            if _d2+1 != d2:
                fd.write("_")
        fd.write("\n")

    fd.close()


def relu(mat):

    d1, d2 = mat.shape

    relu_mat = np.copy(mat)

    for _d1 in range(d1):
        for _d2 in range(d2):
            if relu_mat[_d1, _d2] >= 128:
                relu_mat[_d1, _d2] = int(0)

    return relu_mat



def main():

    parser = argparse.ArgumentParser()

    parser.add_argument("-o", "--output",
                        help="The output directory ",
                        required=True,
                        default="output",
                        type=str)


    parser.add_argument("row",
                         help="Matrix row dimension",
                         type=int)
    parser.add_argument("col",
                         help="Matrix col dimension",
                         type=int)


    args = parser.parse_args()

    row = args.row
    col = args.col

    assert col <= 16 , "Column cannot exceed 16"


    input_mat = np.zeros((row, 16)).astype(int)
    golden_mat = np.zeros((row, 16)).astype(int)
    rand_mat = (256 * np.random.rand(row, col)) % 256
    rand_mat = rand_mat.astype(int)

    relu_mat = relu(rand_mat)

    input_mat[0:row, 0:col] = rand_mat
    golden_mat[0:row, 0:col] = relu_mat

    
    if not os.path.exists(args.output):
        os.makedirs(args.output)

    write_txt(os.path.join(args.output, "input.txt"), rand_mat)
    write_txt(os.path.join(args.output, "golden.txt"), relu_mat)

#*##########################################################################
#*############################## Output data ###############################
#*##########################################################################
    
    build_path = os.path.join(args.output, "build")
    if not os.path.exists(build_path):
        os.makedirs(build_path)

    input_filename = "input.bin"
    input_txt      = "input.txt"
    golden_filename = "golden.bin"
    golden_txt      = "golden.txt"
    input_filepath = os.path.join(build_path, input_filename)
    golden_filepath = os.path.join(build_path, golden_filename)


    write_binary(input_filepath, input_mat)
    write_binary(golden_filepath, golden_mat)
    write_txt(os.path.join(build_path, input_txt), input_mat)
    write_txt(os.path.join(build_path, golden_txt), golden_mat)

    
    nset = row
    mdef = "matrix_define.v"

    desc = [
        ("NSET", row)
    ]
    write_macro(os.path.join(build_path, mdef), desc)


if __name__ == "__main__":
    sys.exit(main())







