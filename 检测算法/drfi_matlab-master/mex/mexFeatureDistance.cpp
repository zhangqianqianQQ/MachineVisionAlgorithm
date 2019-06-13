#include "mex.h"

#include <cmath>
#include <cstdlib>
#include <cstring>

// mexFeatureDistance( f1, f2, 'x1' )
// where each column in f1 and f2 is a sample
// i.e., size(f1, 1) == feature_dimension
//       size(f1, 2) == sample_number

double Distance( double *e1, double *e2, int iDim, const char *distType );

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, 
  const mxArray *prhs[] )
{
    if( nrhs != 3 )
    {
        mexPrintf( "usage: %s f1 f2 dist_type\n" );
        return;
    }
    
    bool isSameFeature = mxIsEmpty( prhs[1] );
    
    double *f1 = (double*)mxGetData( prhs[0] );
    int iSample = mxGetN( prhs[0] );
    int iDim = mxGetM( prhs[0] );
    
    double *f2 = f1;
    
    if( !isSameFeature )
    {
        f2 = (double*)mxGetData( prhs[1] );
   
        if( mxGetN(prhs[1]) != iSample || mxGetM(prhs[1]) != iDim )
        {
            mexErrMsgTxt( "The dimension of f1 and f2 are not matched." );
            return;
        }
    }
    
    char distType[10];
    mxGetString( prhs[2], distType, 10 );
    
    // mexPrintf( "Sample: %d, iDim: %d, distType: %s\n", iSample, iDim, distType );
    
    plhs[0] = mxCreateDoubleMatrix( iSample, iSample, mxREAL );
    double *distMat = (double*)mxGetData( plhs[0] );
    
    if( isSameFeature )
    {
        for( int ix = 0; ix < iSample; ++ix )
        {
            for( int jx = 0; jx < iSample; ++jx )
            {
                if( ix == jx )
                    distMat[ix * iSample + jx] = 0.0;
                if( ix < jx )
                    distMat[ix * iSample + jx] = Distance( f1 + ix * iDim, f2 + jx * iDim, iDim, distType );
                else
                    distMat[ix * iSample + jx] = distMat[jx * iSample + ix];
            }
        }
    }
    else
    {
        for( int ix = 0; ix < iSample; ++ix )
        {
            for( int jx = 0; jx < iSample; ++jx )
            {
                distMat[jx * iSample + ix] = Distance( f1 + ix * iDim, f2 + jx * iDim, iDim, distType );
            }
        }
    }
}

double Distance( double *e1, double *e2, int iDim, const char *distType )
{
    using namespace std;
    
    const double eps = mxGetEps();
    
    double dist = 0.0;
    if( strcmp(distType, "L1" ) == 0 )
    {
        for( int dim = 0; dim < iDim; ++dim )
            dist += fabs( e1[dim] - e2[dim] );
    }
    else if( strcmp(distType, "L2" ) == 0 )
    {
        for( int dim = 0; dim < iDim; ++dim )
            dist += ( e1[dim] - e2[dim] ) * ( e1[dim] - e2[dim] );
    }
    else if( strcmp(distType, "x2" ) == 0 )
    {
        for( int dim = 0; dim < iDim; ++dim )
            dist += ( e1[dim] - e2[dim] ) * ( e1[dim] - e2[dim] ) / ( e1[dim] + e2[dim] + eps );
        dist /= 2.0;
    }
    else
    {
        mexErrMsgTxt( "Not supported feature distance type." );
        return -1.0;
    }
    
    return dist;
}