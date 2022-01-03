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
    d0, d1, d2 = mat.shape

    for _d0 in range(d0):
        fd.write(f"#=========== {_d0} ===========#\n")
        for _d1 in range(d1):
            for _d2 in range(d2):
                value = "%2d" % int(mat[_d0, _d1, _d2])
                fd.write(value)
                if _d2+1 != d2:
                    fd.write(", ")
            fd.write("\n")

        fd.write("\n\n")

    fd.close()


def write_binary(filepath, mat):

    fd = open(filepath, "w")
    d0, d1, d2 = mat.shape    

    for _d0 in range(d0):
        for _d1 in range(d1):
            for _d2 in range(d2):
                byte_value = "%08d" % int(bin(mat[_d0, _d1, _d2])[2:])
                fd.write(byte_value)
                if _d2+1 != d2:
                    fd.write("_")
            fd.write("\n")

    fd.close()




def maxpooling(mat):


    channel, row, col = mat.shape

    max_mat = np.zeros((channel, int(row/2), int(col/2)))

    for ch in range(channel):
        sub_mat = mat[ch]
        for r in range(0, row, 2):
            for c in range(0, col, 2):
                max_val = max(sub_mat[r, c], sub_mat[r, c+1], sub_mat[r+1, c], sub_mat[r+1, c+1])
                nr = int(r/2)
                nc = int(c/2)
                max_mat[ch, nr, nc] = max_val            
    return max_mat






def main():

    parser = argparse.ArgumentParser()

    parser.add_argument("-o", "--output",
                        help="The output directory ",
                        required=True,
                        default="output",
                        type=str)

    parser.add_argument("channel",
                         help="The channel of matrix",
                         type=int)

    parser.add_argument("row",
                         help="Matrix row dimension",
                         type=int)
    parser.add_argument("col",
                         help="Matrix col dimension",
                         type=int)


    args = parser.parse_args()

    row = args.row
    col = args.col
    ch  = args.channel

    assert row <= 16 and row % 2 == 0, "Row cannot exceed 16"
    assert col <= 16 and col % 2 == 0, "Column cannot exceed 16"
    assert ch  <= 16, "Channel cannot exceed 16"


    input_mat = np.zeros((16, row, 16))
    golden_mat = np.zeros((16, int(row/2), 16)).astype(int)
    org_golden_mat = np.zeros((ch, int(row/2), 16)).astype(int)
    rand_mat = (16 * np.random.rand(ch, row, col)) % 16
    rand_mat = rand_mat.astype(int)

    max_mat = maxpooling(rand_mat)

    input_mat[:ch, 0:row, 0:col] = rand_mat
    golden_mat[:ch, 0:int(row/2), 0:int(col/2)] = max_mat
    org_golden_mat[:ch, 0:int(row/2), 0:int(col/2)] = max_mat

    # print(input_mat)
    input_mat = np.transpose(input_mat, (1, 2, 0)).astype(int)
    # print(golden_mat)
    golden_mat = np.transpose(golden_mat, (1 ,2, 0)).astype(int)

    
    if not os.path.exists(args.output):
        os.makedirs(args.output)

    write_txt(os.path.join(args.output, "input.txt"), rand_mat)
    write_txt(os.path.join(args.output, "golden.txt"), max_mat)

#*##########################################################################
#*############################## Output data ###############################
#*##########################################################################

    build_path = os.path.join(args.output, "build")
    if not os.path.exists(build_path):
        os.makedirs(build_path)

    input_filename = "input.bin"
    input_txt      = "input.txt"
    golden_filename = "golden.bin"
    org_golden_filename = "org_golden.bin"
    golden_txt      = "golden.txt"
    org_golden_txt = "org_golden.txt"

    input_filepath = os.path.join(build_path, input_filename)
    golden_filepath = os.path.join(build_path, golden_filename)
    org_golden_filepath = os.path.join(build_path, org_golden_filename)
    


    write_binary(input_filepath, input_mat)
    write_binary(golden_filepath, golden_mat)
    write_binary(org_golden_filepath, org_golden_mat)
    write_txt(os.path.join(build_path, input_txt), input_mat)
    write_txt(os.path.join(build_path, golden_txt), golden_mat)
    write_txt(os.path.join(build_path, org_golden_txt), org_golden_mat)
    
    nset = row
    mdef = "matrix_define.v"

    desc = [
        ("NSET", nset),
        ("OUT_DIM", int(nset/2))
    ]
    write_macro(os.path.join(build_path, mdef), desc)


if __name__ == "__main__":
    sys.exit(main())







