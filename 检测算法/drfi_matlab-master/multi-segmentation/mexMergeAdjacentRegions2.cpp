#include "mex.h"
#include "disjoint-set.h"
#include <cmath>
using std::abs;

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{	
	double *adjlist = mxGetPr( prhs[0] );
	double *pE = mxGetPr( prhs[1] );
	mwSize nadj = mxGetM( prhs[0] );
	mwSize dummy = mxGetN( prhs[0] );
	if( nadj != mxGetM(prhs[1]) || dummy != 2 )
	{
		mexErrMsgTxt( "Error in merging adjacent regions: invalid input" );
	}

	double numSuperpixel = mxGetScalar( prhs[2] );
	double *threshold = mxGetPr( prhs[3] );
	int m = mxGetM( prhs[3] );
	int n = mxGetN( prhs[3] );
	int numSegmentation = m * n;

	mexPrintf( "nadj: %d\n", nadj );
	mexPrintf( "m: %d, n: %d\n", m, n );

	mexPrintf( "numSuperpixel: %.1f, numSegmentation: %d\n", numSuperpixel, numSegmentation );

	plhs[0] = mxCreateDoubleMatrix( numSuperpixel, numSegmentation, mxREAL );
	double *label = mxGetPr( plhs[0] );

	int num = 0;
	for( int s = 0; s < numSegmentation; ++s )
	{
		double t = threshold[s];
		mexPrintf( "\t*** threshold: %.3f\n", t );
		universe *u = new universe( numSuperpixel );
		for( int ix = 0; ix < nadj; ++ix )
		{
			int s1 = adjlist[ix] - 1;
			int s2 = adjlist[ix + nadj] - 1;

			int a = u->find( s1 );
			int b = u->find( s2 );
			// mexPrintf( "\t\t*** pE: %.3f\n", pE[ix] );
			if( pE[ix] >= t && a != b )
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
