#include "mex.h"
#include "matrix.h"

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    int m = mxGetM( prhs[0] );
    int n = mxGetN( prhs[0] );
    
    plhs[0] = mxCreateDoubleMatrix(m, n, mxREAL);
    
    char *ca = (char*)mxGetData( prhs[0] );
    double *da = (double*)mxGetData( plhs[0] );
    
    for( int ix = 0; ix < m * n; ++ix )
        da[ix] = (double)ca[ix];
}