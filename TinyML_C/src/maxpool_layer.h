#include <stdlib.h>


typedef struct max_pooling {
    float *input;  float *d_input;
    float *output; float *d_output;
    int channels;
    int kernel_size; int stride;
    int in_w, in_h, out_w, out_h;
    int in_units, out_units;

    short batchsize;
} max_pooling;

void max_pool_forward(max_pooling *mx);