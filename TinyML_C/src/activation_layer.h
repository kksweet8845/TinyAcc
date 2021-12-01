#include <stdlib.h>


typedef struct activation_lay {
    float *input; float *d_input;
    float *output; float *d_output;
    int units;
    short batchsize;

} activation_lay;

void relu_op_forward(activation_lay *op);
//void relu_op_backward(activation_lay*op);

void sigmoid_op_forward(activation_lay*op);
//void sigmoid_op_backward(activation_lay *op);

void softmax_op_forward(activation_lay *op);
//void softmax_op_backward(activation_lay *op);