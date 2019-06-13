#include <mex.h>
#include <cstdio>
#include <cstdlib>
#include <fstream>

#include "image.h"
#include "misc.h"
#include "pnmfile.h"
#include "segment-image.h"
#include "filter.h"

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, 
				 const mxArray *prhs[] )
{
	float sigma, k;
	int min_size;

	//r = mxGetPr( prhs[0] );
	//g = mxGetPr( prhs[1] );
	//b = mxGetPr( prhs[3] );
	double *image = mxGetPr( prhs[0] );
	const mwSize *dims = mxGetDimensions( prhs[0] );

	sigma = mxGetScalar( prhs[1] );
	k = mxGetScalar( prhs[2] );
	min_size = mxGetScalar( prhs[3] );

	//mexPrintf( "sigma: %.3f, k: %.3f, min_size: %d\n", sigma, k, min_size );
	
	int height = dims[0];
	int width = dims[1];
	int c = dims[2];

	typedef unsigned char uchar;
	imageRGB *input = new imageRGB(width, height);
	for (int y = 0; y < height; y++) 
	{
		for (int x = 0; x < width; x++) 
		{
			int index = height*x + y;
			imRef(input, x, y).r = static_cast<uchar>( image[index] );
			imRef(input, x, y).g = static_cast<uchar>( image[width*height + index] );
			imRef(input, x, y).b = static_cast<uchar>( image[width*height*2 + index] );
		}
	}

	int num_ccs;
	imageRGB *seg = segment_image(input, sigma, k, min_size, &num_ccs);
	mexPrintf( "number of regions: %d\n", num_ccs );

	plhs[0] = mxCreateNumericArray( 3, dims, mxUINT8_CLASS, mxREAL );
	uchar *output = static_cast<uchar*>( mxGetData(plhs[0]) );

	for (int y = 0; y < height; y++) 
	{
		for (int x = 0; x < width; x++) 
		{
			int index = height*x + y;
			output[index] = imRef(seg, x, y).r;
			output[width*height + index] = imRef(seg, x, y).g;
			output[2*width*height + index] = imRef(seg, x, y).b;
		}
	}
    
    delete input;
    delete seg;
}	