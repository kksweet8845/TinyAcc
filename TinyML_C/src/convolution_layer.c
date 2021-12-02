#include <stdlib.h>
#include <math.h>
#include <pthread.h>
#include <string.h>
#include <time.h>
#include <stdio.h>
#include "convolution_layer.h"
#include "matrix.h"
#define MIN(a,b) (((a) < (b)) ? (a) : (b))


typedef struct conv_args{
    conv *conv;
    short batch_id;
    short start_tunits;
    short end_tunits;
} conv_args;

static void img2col(const float *img, float *col, const conv *conv)
{
    /**
     Output
        col[ikk][owoh]
    **/

    register int input_offset;
    register int iwih = conv->in_w*conv->in_h;
    register int kk   = conv->kernel_size* conv->kernel_size;
    register int ikk  = conv->in_channels * kk;
    register float *input = img;
    register float *x_col = col;
    for (register unsigned short in_c = 0; in_c < conv->in_channels; in_c++)
    {
        register int x_col_offset = in_c * kk;
        for (register int st_x = 0; st_x < conv->out_w * conv->stride; st_x += conv->stride)
        {
            for (register int st_y = 0; st_y < conv->out_h * conv->stride; st_y += conv->stride, x_col_offset += ikk)
            {
                for (register unsigned short j = 0; j < conv->kernel_size; j++)
                {
                    for (register unsigned short i = 0; i < conv->kernel_size; i++, x_col_offset++)
                    {
                        if (!(st_x+i <conv->in_w) | !(st_y+j <conv->in_h))
                        {
                            x_col[x_col_offset] = 0;
                            continue;
                        }

                        input_offset = (st_x+i) + (st_y+j) * conv->in_w + in_c * iwih;
                        x_col[x_col_offset] = input[input_offset];
                    }
                }
            }
        }
        ikk += kk;
    }
}

static void col2img(const float *col, float *img, const conv *conv)
{
    /*
    Backward to do
    */
}

static void* conv_do_forward(void *argv)
{

    conv_args cp;
    memcpy(&cp, (conv_args *)argv, sizeof(conv_args));

    float *x_col    = cp.conv->input_col + cp.batch_id * cp.conv->in_units;
    float *t_input  = cp.conv->input + cp.batch_id * cp.conv->in_units;
    float *t_output = cp.conv->output + cp.batch_id * cp.conv->out_units;
    int ikk  = cp.conv->in_channels * cp.conv->kernel_size * cp.conv->kernel_size;
    int owoh = cp.conv->out_w * cp.conv->out_h;
    
    // ********shape********
    //  
    // t_input    [ic,ih,iw]
    // x_col      [owoh,ikk]
    // weights    [ikk,oc]
    // t_output   [oc,oh,ow]
    //
    // *********************
    
    img2col(t_input, x_col, cp.conv);
    matrix_multiply(x_col, cp.conv->weights, t_output, owoh, ikk, cp.conv->out_channels); //output[owoh,oc]
    matrix_transpose(t_output, owoh, cp.conv->out_channels); //output[oc,owoh]

    register int o_offset=0;
    for (int i = 0; i < cp.conv->out_channels; i++)
    {
        register float tmp = cp.conv->bias[i];
        while (o_offset < (i+1)*owoh)
        {
            t_output[o_offset++] += tmp;
        }
    }

}

void conv_forward(conv *conv)
{
    /**
     * conv2d forward *
      Input:
           conv->input
           conv->weights
           conv->bias
      Output:
           conv->output
    **/
    conv->input_col = (float *)calloc((conv->batchsize)*(conv->in_channels * conv->kernel_size* conv->kernel_size)*(conv->out_w * conv->out_h), sizeof(float));
    conv_args args[conv->batchsize+1];

    for (int p = 0; p < conv->batchsize; p++)
    {
        args[p].conv = conv;
        args[p].batch_id = p;
        conv_do_forward((void *)(&args[p]));
    }
    

}

