#include <stdlib.h>

typedef struct fc {
    float *input;   float *d_input;
    float *output;  float *d_output;
    float *weights; float *d_weights;
    float *bias;    float *d_bias;
    int in_units, out_units;

    short batchsize;
} fc;


void fc_forward(fc *fc);
