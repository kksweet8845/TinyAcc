#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include "convolution_layer.h"
#include "maxpool_layer.h"
#include "activation_layer.h"
#include "fc_layer.h"

//
//  Model parameter of Tiny ML
//
#define IN_CHANNELS 3
/* convolution hyper parameters */
#define CONV1_CHANNELS 16
#define CONV2_CHANNELS 8

#define CONV1_KERNEL 3
#define CONV2_KERNEL 3

#define CONV1_STRIDES 1
#define CONV2_STRIDES 1

#define CONV1_PADDING 2
#define CONV2_PADDING 2
/* convolution hyper parameters */

//#define FEATURE_MAP0 32
#define FEATURE_MAP0 16
#define FEATURE_MAP1 16
#define POOLING_MAP1 8
#define FEATURE_MAP2 8

#define FC_MAP1 256
#define OUT_MAP 8


//Description of Tiny ML data structure 
typedef struct network {

    float *input;
    float *output;
    short batchsize;
    
    conv conv1;
    activation relu1;

    max_pooling mp1;

    conv conv2;
    activation relu2;

    fc fc1;
    activation relu3;

    fc fc2;

} tiny_ml;