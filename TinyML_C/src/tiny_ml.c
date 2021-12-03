#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <assert.h>
#include "tiny_ml.h"

static void gauss_initialization(float *weights, int layer_units)
{
    /*
    |  The weights are initialized using a Gaussian distribution (also known as normal distribution)   |
    |  with zero mean and standard deviation that is a function of the filter kernel dimensions.       |
    |  This is done to ensure that the variance of the output of a network layer stays bounded within  |
    |  reasonable limits instead of vanishing or exploding i.e., becoming very large.                  |
    */

    float mean  = 0;
    float stddv = 0.01;

	float V1, V2, S, X;
	static int phase = 0;
    for (int shift = 0; shift < layer_units; shift++)
    {
        if (phase == 0) {
            do {
                float U1 = (float) rand() / RAND_MAX;
                float U2 = (float) rand() / RAND_MAX;

                V1 = 2 * U1 - 1;
                V2 = 2 * U2 - 1;
                S = V1 * V1 + V2 * V2;
            } while (S >= 1 || S == 0);
    
            X = V1 * sqrt(-2 * log(S) / S);
        }else {
            X = V2 * sqrt(-2 * log(S) / S);
        }
        phase = 1 - phase;

        weights[shift] = mean + stddv * X;
    }
}

void init_weight(tiny_ml *net, char *weights_path)
{
    // initialize weights for this network
    // weights for convolutional and fully connected layers in a deep neural network (DNN) are initialized in a specific way.
    gauss_initialization(net->conv1.weights, CONV1_CHANNELS*IN_CHANNELS*CONV1_KERNEL*CONV1_KERNEL);
    gauss_initialization(net->conv2.weights, CONV2_CHANNELS*CONV1_CHANNELS*CONV2_KERNEL*CONV2_KERNEL);
    gauss_initialization(net->fc1.weights, CONV2_CHANNELS*FC_MAP1*FEATURE_MAP2*FEATURE_MAP2);
    gauss_initialization(net->fc2.weights, FC_MAP1*OUT_MAP);

    //init bias
    int i;
    for(i=0; i<CONV1_CHANNELS; i++)
        net->conv1.bias[i] = 1;
    for(i=0; i<CONV2_CHANNELS; i++)
        net->conv2.bias[i] = 1;
    for(i=0; i<FC_MAP1; i++)
        net->fc1.bias[i] = 1;
    for(i=0; i<OUT_MAP; i++)
        net->fc2.bias[i] = 1;
}

void load_weight(tiny_ml *net, char *filename)
{
    
    FILE *fp = fopen(filename, "rb");
    load_conv_weights(&(net->conv1), fp);
    load_conv_weights(&(net->conv2), fp);
    load_fc_weights(&(net->fc1), fp);
    load_fc_weights(&(net->fc2), fp);
    fclose(fp);
    printf("Load TinyML from the path : \"%s\" successfully... \n", filename);
}

void malloc_tinyML(tiny_ml *net)
{
    calloc_conv_weights(&(net->conv1));
    calloc_conv_weights(&(net->conv2));
    calloc_fc_weights(&(net->fc1));
    calloc_fc_weights(&(net->fc2));
}

void free_tinyML(tiny_ml *net)
{
    free_conv_weights(&(net->conv1));
    free_conv_weights(&(net->conv2));
    free_fc_weights(&(net->fc1));
    free_fc_weights(&(net->fc2));
}

void init_tinyML_arch(tiny_ml *net, short batchsize)
{
    //initial Tiny ML structure
    net->batchsize = batchsize;
    net->conv1.batchsize = batchsize;
    net->conv2.batchsize = batchsize;
    net->fc1.batchsize   = batchsize;
    net->fc2.batchsize   = batchsize;
    net->mp1.batchsize   = batchsize;
    net->relu1.batchsize = batchsize;
    net->relu2.batchsize = batchsize;
    net->relu3.batchsize = batchsize;

    //conv1 input & output set up
    net->conv1.in_channels = IN_CHANNELS;
    net->conv1.out_channels = CONV1_CHANNELS;
    net->conv1.in_h = FEATURE_MAP0;
    net->conv1.in_w = FEATURE_MAP0;
    net->conv1.kernel_size = CONV1_KERNEL;
    net->conv1.padding = CONV1_PADDING;
    net->conv1.stride = CONV1_STRIDES;
    net->conv1.out_h = FEATURE_MAP1;
    net->conv1.out_w = FEATURE_MAP1;
    net->conv1.in_units = IN_CHANNELS*FEATURE_MAP0*FEATURE_MAP0;
    net->conv1.out_units = CONV1_CHANNELS*FEATURE_MAP1*FEATURE_MAP1;

    net->relu1.units = net->conv1.out_units;

    //maxpool1 input & output set up
    net->mp1.channels = CONV1_CHANNELS;
    net->mp1.stride = 2;
    net->mp1.kernel_size = 3;
    net->mp1.in_h = FEATURE_MAP1;
    net->mp1.in_w = FEATURE_MAP1;
    net->mp1.out_w = POOLING_MAP1;
    net->mp1.out_h = POOLING_MAP1;
    net->mp1.in_units = net->relu1.units;
    net->mp1.out_units = CONV1_CHANNELS*POOLING_MAP1*POOLING_MAP1;

    //conv2 input & output set up
    net->conv2.in_channels = CONV1_CHANNELS;
    net->conv2.out_channels = CONV2_CHANNELS;
    net->conv2.in_h = POOLING_MAP1;
    net->conv2.in_w = POOLING_MAP1;
    net->conv2.kernel_size = CONV2_KERNEL;
    net->conv2.padding = CONV2_PADDING;
    net->conv2.stride = CONV2_STRIDES;
    net->conv2.out_h = FEATURE_MAP2;
    net->conv2.out_w = FEATURE_MAP2;
    net->conv2.in_units = net->mp1.out_units;
    net->conv2.out_units = CONV2_CHANNELS*FEATURE_MAP2*FEATURE_MAP2;

    net->relu2.units = net->conv2.out_units;

    //fc1 input & output set up
    net->fc1.in_units = net->relu2.units;
    net->fc1.out_units = FC_MAP1;

    net->relu3.units = FC_MAP1; 

    //fc2 & final output
    net->fc2.in_units = FC_MAP1;
    net->fc2.out_units = OUT_MAP;

}

int main(int argc, char* argv[])
{
    static tiny_ml net;
    
    if (0 == strcmp(argv[1], "train"))
    {
        /* start training Tiny ML model */
    }
    else if (0 == strcmp(argv[1], "inference"))
    {
        //
        // $./tiny_ml inference -image ./xxx.jpg -weight ./tiny_ml.weights
        //

        char img_path[256];
        char weights_path[256];
        for (int i = 2; i < argc-1; i++)
        {
            if (0 == strcmp(argv[i], "-image"))
                sprintf(img_path, "%s", argv[i+1]);
            if (0 == strcmp(argv[i], "-weight"))
                sprintf(weights_path, "%s", argv[i+1]);
        }
        
        init_tinyML_arch(&net, 1);
        malloc_tinyML(&net);
        load_weights(&net, weights_path);
        printf("TinyML preprocess setup fininshed. Start inference & Input the image into Systolic Arrary\n");
        inference_model(&net, argv[2]);
        free_tinyML(&net);
        
    }
    else {
        printf("Error argument, please use 'train' or 'inference' \n");
    }
}