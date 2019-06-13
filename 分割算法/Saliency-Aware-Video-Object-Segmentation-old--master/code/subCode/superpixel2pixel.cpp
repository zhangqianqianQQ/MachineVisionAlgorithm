#include <matrix.h>
#include <mex.h>

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{

	double *label;
    double *regioncolor;
    int M,channel;
	int labelnum,N;
    int i,j;
    label = mxGetPr(prhs[0]);
	regioncolor =  mxGetPr(prhs[1]);

    M = mxGetM(prhs[0]);
    N =mxGetN(prhs[0]);

	labelnum = mxGetM(prhs[1]);
	channel = mxGetN(prhs[1]);

    mxArray *meanColours = mxCreateDoubleMatrix(M*N,channel,mxREAL);
    double *colours = ( double * )mxGetData( meanColours );
    for(i =0; i<M*N; i++)
    {
         for(j =0; j<channel; j++)
         {
             colours[j*M*N+i]=regioncolor[ j*labelnum + int(label[i]-1)];
         }
     }
    plhs[ 0 ] = meanColours;
}

