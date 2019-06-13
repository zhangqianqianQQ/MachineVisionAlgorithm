/** Function to compute mean colour, centre of mass and size of all superpixels
%
%    Copyright (C) 2013  Anestis Papazoglou
%
%    You can redistribute and/or modify this software for non-commercial use
%    under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%    For commercial use, contact the author for licensing options.
%
%    Contact: a.papazoglou@sms.ed.ac.uk */

/** Expected inputs:
			1 - Frames: a cell array of length frames. Each cell i contains a HxWx3
				double matrix containing the color values of frame i.
			2 - Superpixels: a cell array of length frames. Each cell i contains a
				HxW uint32 superpixel label map of frame i.
			3 - Number of superpixels: a double value containing the total number of
				superpixel labels.
		
		Outputs:
			1 - Superpixel mean colour: a single array of length N, where N is the
				number of superpixels in the video sequence, containing the mean colour
				(RGB) value of each superpixel.
			2 - Superpixel centre of mass: a single array of length N, containing
				the centre of mass of each superpixel.
			3 - Superpixel size: a single array of length N, containing the size of
				each superpixel in pixels.
*/

#include <matrix.h>
#include <mex.h>

//#define DEBUG_MODE

#define USAGE_NOTE "getSuperpixelsStats USAGE:\n" \
"\tExpected inputs:\n" \
"\t\t1 - Frames: a cell array of length frames. Each cell i contains a HxWx3 " \
"double matrix containing the color values of frame i.\n" \
"\t\t2 - Superpixels: a cell array of length frames. Each cell i contains a " \
"HxW uint32 superpixel label map of frame i.\n" \
"\t\t3 - Number of superpixels: a double value containing the total number of " \
"superpixel labels.\n" \
"\n" \
"\tOutputs:\n" \
"\t\t1 - Superpixel mean colour: a single array of length N, where N is the " \
"number of superpixels in the video sequence, containing the mean colour " \
"(RGB) value of each superpixel.\n" \
"\t\t2 - Superpixel centre of mass: a single array of length N, containing " \
"the centre of mass of each superpixel.\n" \
"\t\t3 - Superpixel size: a single array of length N, containing the size of " \
"each superpixel in pixels.\n"

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
	unsigned int frames, height, width, elements, elementsX2, point, superpixel, superpixels, superpixelsX2, size;
	double *image;
	unsigned int *superpixelMap, *sizes;
	float *centres, *colours;

	if( nrhs == 3 )
	{
		/** Assert that inputs are cell arrays */
		if( !mxIsCell( prhs[ 0 ] ) || !mxIsCell( prhs[ 1 ] ) )
			mexErrMsgTxt( USAGE_NOTE );
		
		/** Assert that the input cell arrays are of the same length */
		frames = mxGetNumberOfElements( prhs[ 0 ] );
		if( frames != mxGetNumberOfElements( prhs[ 1 ] ) )
			mexErrMsgTxt( USAGE_NOTE );

		/** Assert that input cell arrays are not empty */
		if( frames == 0 )
			mexErrMsgTxt( USAGE_NOTE );
		
		/** Assert that corresponding cell contents have the same number of elements */
		for( int frame = 0; frame < frames; frame++ )
		{
			/** Check that cell is not empty */
			if( mxIsEmpty( mxGetCell( prhs[ 0 ], frame ) ) ||
				mxIsEmpty( mxGetCell( prhs[ 1 ], frame ) ) )
				continue;
		
			height = mxGetM( mxGetCell( prhs[ 0 ], frame ) );
			width = mxGetN( mxGetCell( prhs[ 0 ], frame ) ) / 3;
			elements = height * width;
			if( elements != mxGetNumberOfElements( mxGetCell( prhs[ 1 ], frame ) ) )
				mexErrMsgTxt( USAGE_NOTE );
		}

		/** Assert that cell contents are of correct data type */
		for( int frame = 0; frame < frames; frame++ )
		{
			if( mxGetClassID( mxGetCell( prhs[ 0 ], frame ) ) != mxDOUBLE_CLASS )
				mexErrMsgTxt( USAGE_NOTE );
			if( mxGetClassID( mxGetCell( prhs[ 1 ], frame ) ) != mxUINT32_CLASS )
				mexErrMsgTxt( USAGE_NOTE );
		}
		if( mxGetClassID( prhs[ 2 ] ) != mxDOUBLE_CLASS )
				mexErrMsgTxt( USAGE_NOTE );
	}
	else
	{
			mexErrMsgTxt( USAGE_NOTE );
	}

	switch( nlhs )
	{
		case 0:
			break;
		case 3:
			break;
		default:
			mexErrMsgTxt( USAGE_NOTE );
	}
	
	superpixels = ( unsigned int )( ( double * )mxGetData( prhs[ 2 ] ) )[ 0 ];
	#ifdef DEBUG_MODE
	mexPrintf( "getSuperpixelStats: Number of frames: %i\n", frames );
	mexPrintf( "getSuperpixelStats: Frame size: %ix%i\n", height, width );
	mexPrintf( "getSuperpixelStats: Total number of superpixels: %i\n", superpixels );
	mexEvalString( "pause(0.001)" );
	#endif
	
	#ifdef DEBUG_MODE
	mexPrintf( "getSuperpixelStats: Allocating memory for outputs...\n" );
	mexEvalString( "pause(0.001)" );
	#endif
	mxArray *sizesMxArray = mxCreateNumericMatrix( superpixels, 1, mxUINT32_CLASS, mxREAL );
	mxArray *massCentresMxArray = mxCreateNumericMatrix( superpixels, 2, mxSINGLE_CLASS, mxREAL );
	mxArray *meanColoursMxArray = mxCreateNumericMatrix( superpixels, 3, mxSINGLE_CLASS, mxREAL );
	
	sizes = ( unsigned int * )mxGetData( sizesMxArray );
	centres = ( float * )mxGetData( massCentresMxArray );
	colours = ( float * )mxGetData( meanColoursMxArray );
	
	#ifdef DEBUG_MODE
	mexPrintf( "getSuperpixelStats: Computing superpixel stats...\n" );
	mexEvalString( "pause(0.001)" );
	#endif
	elementsX2 = 2 * elements;
	superpixelsX2 = 2 * superpixels;
	for( unsigned int frame = 0; frame < frames; frame++ )
	{
		image = ( double * )( mxGetData ( mxGetCell( prhs[ 0 ], frame ) ) );
		superpixelMap = ( unsigned int * )( mxGetData( mxGetCell( prhs[ 1 ], frame ) ) );
		
		for( unsigned int i = 0; i < height; i++ )
		{
			for( unsigned int j = 0; j < width; j++ )
			{
				point = j * height + i;
				superpixel = superpixelMap[ point ] - 1;
				
				if( superpixel < 0 && superpixel >= superpixels )
					mexErrMsgTxt( "getSuperpixelStats: Superpixel labels outside given range" );
				
				centres[ superpixel ] += i;
				centres[ superpixel + superpixels ] += j;
				colours[ superpixel ] += image[ point ];
				colours[ superpixel + superpixels ] += image[ point + elements ];
				colours[ superpixel + superpixelsX2 ] += image[ point + elementsX2 ];
				sizes[ superpixel ]++;
			}
		}
	}
	
	for( superpixel = 0; superpixel < superpixels; superpixel++ )
	{
		size = ( float )sizes[ superpixel ];
		if( size > 0 )
		{
			centres[ superpixel ] /= size;
			centres[ superpixel + superpixels ] /= size;
			colours[ superpixel ] /= size;
			colours[ superpixel + superpixels ] /= size;
			colours[ superpixel + superpixelsX2 ] /= size;
		}
	}
	
	plhs[ 0 ] = meanColoursMxArray;
	plhs[ 1 ] = massCentresMxArray;
	plhs[ 2 ] = sizesMxArray;
	
}

