#include "mex.h"
#include "matrix.h"

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    const mwSize *mw = mxGetDimensions( prhs[0] );
    plhs[0] = mxCreateCharArray(2, mw);
    
    char *ca = (char*)mxGetData( plhs[0] );
    double *da = (double*)mxGetData( prhs[0] );
    
    for( int ix = 0; ix < mw[0]*mw[1]; ++ix )
        ca[ix] = (char)da[ix];
}