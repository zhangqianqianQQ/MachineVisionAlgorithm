#include "mex.h"
#include "disjoint-set.h"
#include <cmath>
using std::abs;

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{	
	double *dismat = mxGetPr( prhs[0] );
	double *threshold = mxGetPr( prhs[1] );
	
	mwSize m = mxGetM( prhs[0] );
	mwSize n = mxGetN( prhs[0] );
	if( m != n )
	{
		mexErrMsgTxt( "Error: provided distance matrix must be square.\n" );
	}
	
	int numSuperpixel = m;
	
	mwSize numSegmentation = mxGetM( prhs[1] ) * mxGetN( prhs[1] );
	mexPrintf( "numSegmentation: %d\n", numSegmentation );
	
	plhs[0] = mxCreateDoubleMatrix( numSuperpixel, numSegmentation, mxREAL );
	double *label = mxGetPr( plhs[0] );
	
	int num = 0;
	for( int s = 0; s < numSegmentation; ++s )
	{
		double t = threshold[s];
		universe *u = new universe( numSuperpixel );
		for( int ix = 0; ix < numSuperpixel * numSuperpixel; ++ix )
		{
			int r1 = ix % m;
			int r2 = ix / m;
			
			int a = u->find( r1 );
			int b = u->find( r2 );
			if( dismat[ix] <= t && abs(dismat[ix]) > 1e-5 && a != b )
			{
				u->join(a, b);
			}
		}
		
		mexPrintf( "\tafter merging, there are %d regions.\n", u->num_sets() );
		
		for( int ix = 0; ix < numSuperpixel; ++ix )
		{
			label[num] = u->find( ix );
			++num;
		}
		
		delete u;		
	}
	if( num != numSuperpixel * numSegmentation )
	{
		mexErrMsgTxt( "Error in generating multiple segmentations." );
	}
}