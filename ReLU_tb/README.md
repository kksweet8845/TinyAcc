# How to Use it
1. execute gen_test.sh for generate test_case or generate test_case manual if on windows
```shell
$ python relu.py -o outdir <row> <col>
```
2. The generated file will be located in out directory

3. Use vivado to add source design, such as src/\*.v, tpu.v, and build/matrix_define.v. Don't forget copying build\*.bin as well to working directory.


# Sepcs

