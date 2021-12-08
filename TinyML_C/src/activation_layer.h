#include <stdlib.h>


typedef struct activation {
    float *input; float *d_input;
    float *output; float *d_output;
    int units;
    short batchsize;

} activation;

void relu_op_forward(activation *relu);
