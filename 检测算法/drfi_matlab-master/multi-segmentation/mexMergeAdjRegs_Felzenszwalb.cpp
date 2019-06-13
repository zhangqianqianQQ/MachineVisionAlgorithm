#include "mex.h"
#include "new-segment-graph.h"

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

	double *supSize = mxGetPr( prhs[4] );
	if( numSuperpixel != mxGetM(prhs[4]) )
	{
		mexErrMsgTxt( "Error in merging adjacent regions: invalid input" );
	}

	int *newSupSize = new int[ static_cast<int>(numSuperpixel) ];
	for( int ix = 0; ix < numSuperpixel; ++ix )
		newSupSize[ix] = static_cast<int>( supSize[ix] );

	mexPrintf( "nadj: %d\n", nadj );
	mexPrintf( "m: %d, n: %d\n", m, n );

	mexPrintf( "numSuperpixel: %.1f, numSegmentation: %d\n", numSuperpixel, numSegmentation );

	plhs[0] = mxCreateDoubleMatrix( numSuperpixel, numSegmentation, mxREAL );
	double *label = mxGetPr( plhs[0] );
	
	edge *edges = new edge[nadj];
	for( int e = 0; e < nadj; ++e )
	{
		edges[e].a = adjlist[e] - 1;
		edges[e].b = adjlist[e + nadj] - 1;
		edges[e].w = 1 - pE[e];
	}
	
    static const int min_size = 300;
	int num = 0;
	for( int s = 0; s < numSegmentation; ++s )
	{
		float t = static_cast<float>( threshold[s] );
		// mexPrintf( "\t*** t: %.3f\n", t );

		universe *u = segment_graph( numSuperpixel, nadj, edges, t, newSupSize );
        
        // force minimum size of segmentation
        for( int e = 0; e < nadj; ++e )
        {
            int a = u->find( edges[e].a );
            int b = u->find( edges[e].b );
            if ((a != b) && ((u->size(a) < min_size) || (u->size(b) < min_size)))
                u->join(a, b);
        }


		for( int ix = 0; ix < numSuperpixel; ++ix )
		{
			label[num] = u->find( ix );
			++num;
		}

		delete u;
	}

	delete [] newSupSize;
	delete edges;
}