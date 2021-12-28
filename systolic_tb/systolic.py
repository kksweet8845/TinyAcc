import sys
import argparse
import random
import os
import numpy as np

CONFIG_OP = 0x0
CONV_OP = 0x1
MAT_OP  = 0x2




def write_instr(fd, op, A_src_addr, A_channel, A_row, A_col,
                  B_src_addr, B_channel, B_row, B_col, output_dir=""):

    def gen_rs(src, channel, row, col):
        bin_src = "%010d" % int(bin(src)[2:])
        bin_ch  = "%08d" % int(bin(channel)[2:])
        bin_row = "%08d" % int(bin(row)[2:])
        bin_col = "%08d" % int(bin(col)[2:])
        return f"{bin_src}_{bin_ch}_{bin_row}_{bin_col}"

    


    #* write opcode
    bin_val = bin(op)
    bin_val = "%03d" % int(bin_val[2:])
    fd.write(bin_val)
    fd.write("_")
    fd.write(gen_rs(A_src_addr, A_channel, A_row, A_col))
    fd.write("_")
    fd.write(gen_rs(B_src_addr, B_channel, B_row, B_col))
    fd.write("\n")




def write_conv_rotated_data(filepath, mat, ksize):

    fd = open(filepath, "w")
    channel, row, col = mat.shape

    # mask = 0xffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff
    # mask = (mask >> ((16 - col) << 3)) << ((16 - col) << 3)

    padding = (ksize-1) >> 1
    pad_col = 16 + padding*2

    pmat = np.zeros((channel, row, pad_col), dtype=int)
    pmat[:, :, 1:col+1] = mat

    cmat = np.zeros((channel*row*3, 16), dtype=int)

    for ch in range(channel):
        for r in range(row):
            cmat[ch*row*3+r*3, 0:col] = pmat[ch, r, 1:col+1]
            cmat[ch*row*3+r*3+1, 0:col] = pmat[ch, r, 0:col]
            cmat[ch*row*3+r*3+2, 0:col] = pmat[ch, r, 2:col+2]
            for k in [1, 0 ,2]:
                for i in range(16):
                    byte_value = "%08d" % int(bin(pmat[ch, r, k+i])[2:])
                    fd.write(byte_value)
                    if i != 15:
                        fd.write("_")
                fd.write("\n")
    return cmat

def gen_conv_rotated_data(mat, ksize):

    channel, row, col = mat.shape

    # mask = 0xffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff
    # mask = (mask >> ((16 - col) << 3)) << ((16 - col) << 3)

    padding = (ksize-1) >> 1
    pad_col = 16 + padding*2

    pmat = np.zeros((channel, row, pad_col), dtype=int)
    pmat[:, :, 1:col+1] = mat

    cmat = np.zeros((channel*row*3, 16), dtype=int)

    for ch in range(channel):
        for r in range(row):
            cmat[ch*row*3+r*3, 0:col] = pmat[ch, r, 1:col+1]
            cmat[ch*row*3+r*3+1, 0:col] = pmat[ch, r, 0:col]
            cmat[ch*row*3+r*3+2, 0:col] = pmat[ch, r, 2:col+2]

    return cmat   



def write_txt(filepath, mat):

    fd = open(filepath, "w")

    if len(mat.shape) == 3:
        d0, d1, d2 = mat.shape
    else:
        d0 = 1
        d1, d2 = mat.shape

    for _d0 in range(d0):
        fd.write(f"#=========== {_d0} ===========#\n")
        for _d1 in range(d1):
            for _d2 in range(d2):
                if len(mat.shape) == 3:
                    value = "%2d" % int(mat[_d0, _d1, _d2])
                else:
                    value = "%2d" % int(mat[_d1, _d2])
                fd.write(value)
                if _d2+1 != d2:
                    fd.write(", ")
            fd.write("\n")

        fd.write("\n\n")

    fd.close()




def write_binary(filepath, mat):

    fd = open(filepath, "w")
    if len(mat.shape) == 3:
        channel, row, col = mat.shape
    elif len(mat.shape) == 2:
        channel = 1
        row, col = mat.shape
    else:
        print("Don't write one dimension data")
        return

    pmat = np.zeros((channel, row, 16), dtype=int)
    pmat[:channel, :, 0:col] = mat

    for ch in range(channel):
        for r in range(row):
            for c in range(16):
                byte_value = "%08d" % int(bin(pmat[ch][r][c])[2:])
                fd.write(byte_value)
                if c != 15:
                    fd.write("_")
            fd.write("\n")
    fd.close()

def main():
    
    parser = argparse.ArgumentParser()

    group = parser.add_mutually_exclusive_group()
    group.add_argument("--conv", 
                        help="Convulation systolic",
                        action="store_true")

    group.add_argument("--matmul",
                        help="Matrix Mul systolic",
                        action="store_true")

    parser.add_argument("--channel",
                        help="The number of input channel",
                        required=True,
                        type=int)

    parser.add_argument("--row",
                        help="The number of row of each channel",
                        type=int)
    
    parser.add_argument("--col",
                        help="The number of column of each row",
                        required=True,
                        type=int)

    parser.add_argument("--col_2",
                        help="The number of second matrix in mat mode",
                        type=int)
    
    parser.add_argument("--ksize",
                        help="The size of kernel",
                        type=int,
                        default=3)

    parser.add_argument("--knum",
                        help="The number of kernel",
                        type=int)

    parser.add_argument("-o", "--output",
                        help="The output directory ",
                        required=True,
                        default="output",
                        type=str)

    args = parser.parse_args()


    channel = args.channel
    col     = args.col

    ksize = None
    row = None
    knum = None
    col_2 = None


    build_dir = os.path.join(args.output, "build")
    if not os.path.exists(args.output):
        os.makedirs(args.output)
    if not os.path.exists(build_dir):
        os.makedirs(build_dir)

    if args.conv:
        assert args.ksize, "Not specified ksize"
        assert args.knum, "Not specified knum"
        ksize   = args.ksize
        row     = args.ksize
        knum    = args.knum
        #* generate the conv instrtion
        fd = open(os.path.join(build_dir, "instruction.bin"), "w")
        write_instr(fd, CONFIG_OP, 0, channel, ksize, col, 0, 1, ksize**2, knum)
        write_instr(fd, CONV_OP, 0, 0, 0, 0, 0, 0, 0, 0)
        fd.close()
    elif args.matmul:
        assert args.row, "Not specified row of first matrix"
        assert args.col_2, "Not specified second matrix column"
        col_2 = args.col_2
        row   = args.row
        fd = open(os.path.join(build_dir, "instruction.bin"), "w")
        write_instr(fd, CONFIG_OP, 0, channel, col, row, 0, channel, col, col_2)
        write_instr(fd, MAT_OP, 0, 0, 0, 0, 0, 0, 0, 0)
        fd.close()
    else:
        print("Please specify conv or matmul option")
        sys.exit(1)



    A_filename = "A_input.bin"
    B_filename = "B_input.bin"
    A_txt      = "A_input.txt"
    B_txt      = "B_input.txt"
    A_gold_filename = "A_golden.bin"
    B_gold_filename = "B_golden.bin"
    A_gold_txt = "A_golden.txt"
    B_gold_txt = "B_golden.txt"


    A_mat = None
    B_mat = None
    if args.conv:
        A_mat = (16 * np.random.rand(channel, row, col)) % 16
        A_mat = A_mat.astype(int)
        B_mat = (16 * np.random.rand(1, ksize**2, knum)) % 16
        B_mat = B_mat.astype(int)
    elif args.matmul:
        assert row <= 16, "row is not smaller than 16"
        assert col_2 <= 16, "col_2 is not smaller than 16"
        A_mat = (16 * np.random.rand(channel, row, col)) % 16
        A_mat = A_mat.astype(int)
        B_mat = (16 * np.random.rand(channel, col, col_2)) % 16
        B_mat = B_mat.astype(int)


    A_filepath = os.path.join(build_dir, A_filename)
    B_filepath = os.path.join(build_dir, B_filename)
    A_txtpath  = os.path.join(args.output, A_txt)
    B_txtpath  = os.path.join(args.output, B_txt)
    AG_filepath = os.path.join(build_dir, A_gold_filename)
    BG_filepath = os.path.join(build_dir, B_gold_filename)
    AG_txtpath = os.path.join(args.output, A_gold_txt)
    BG_txtpath = os.path.join(args.output, B_gold_txt)
    

    if args.conv:
        #* Ouptut input data
        write_binary(A_filepath, A_mat)
        write_binary(B_filepath, B_mat)
        write_txt(A_txtpath, A_mat)
        write_txt(B_txtpath, B_mat)
        #* Write conv_rotated_data
        # gmat = write_conv_rotated_data(AG_filepath, A_mat, ksize)
        gmat = gen_conv_rotated_data(A_mat, ksize)
        write_binary(AG_filepath, gmat)
        #* Write weighting data
        concat_B = np.concatenate((B_mat,)*channel, axis=0)
        write_binary(BG_filepath, concat_B )
        write_txt(AG_txtpath, gmat)
        write_txt(BG_txtpath, concat_B)
    elif args.matmul:
        t_A_mat = np.transpose(A_mat, axes=[0, 2, 1])
        #* Output input data
        write_binary(A_filepath, t_A_mat)
        write_binary(B_filepath, B_mat)
        write_txt(A_txtpath, t_A_mat)
        write_txt(B_txtpath, B_mat)
        #* Output golden data
        write_binary(AG_filepath, t_A_mat)
        write_binary(BG_filepath, B_mat)
        write_txt(AG_txtpath, t_A_mat)
        write_txt(BG_txtpath, B_mat)

    fd = open(os.path.join(build_dir, "matrix_define.v"), "w")

    if args.conv:
        fd.write("`define O_UNI_MAX %d\n" % (channel * row * 3))
        fd.write("`define O_WEI_MAX %d\n" % (channel * row * 3))
    elif args.matmul:
        fd.write("`define O_UNI_MAX %d\n" % (channel * col))
        fd.write("`define O_WEI_MAX %d\n" % (channel * col))

    fd.close()


if __name__ == "__main__":

    sys.exit(main())

















