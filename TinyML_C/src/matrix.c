#include <stdlib.h>
#include <string.h>
#include <immintrin.h>


//
// Not efficient matrix_multiply algorithm
//
void matrix_multiply(const float *a_matrix, const float *b_matrix, float *c_matrix, const int M, const int N, const int K)
{
    /**
      matrix multiply, c = a * b
      Input:
      a    [M,N]
      b    [N,K]
      Output:
      c    [M,K]
    **/
    register int i,j,p;
    register float *a_matrix_ptr = a_matrix;
    for (i = 0; i < M; i++)
    {
        register float *b_matrix_ptr = b_matrix;
        for (j = 0; j < N; j++)
        {
            register float a_value = *(a_matrix_ptr++);
            if (a_value<0.00001 && a_value>(0-0.00001))
                continue;
            register float *c_matrix_ptr = c_matrix + i*K;
            for (p = 0; p < K; p++)
                *(c_matrix_ptr++) += *(b_matrix_ptr++) * a_value;
        }
    }
}

void matrix_transpose(float *x, int M, int N)
{
    /** matrix transpose 
      Input:
           x[M,N]
      Output:
           x[N,M]
    **/
    float *tmp = (float *)malloc(M*N*sizeof(float));
    register int i, j;
    register float *ptr = x;
    for (i = 0; i < M; i++)
    {
        for (j = 0; j < N; j++)
            tmp[j*M+i] = *(ptr++);
    }
    memcpy(x, tmp, M*N*sizeof(float));
    free(tmp);
}

