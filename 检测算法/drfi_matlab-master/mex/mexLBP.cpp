#include "mex.h"

typedef unsigned char uchar;

inline int sub2ind( int r, int c, int rows )
{
    return (c * rows + r );
}

// usage: 
// image_lbp = mexLBP( rgb2gray(image) );
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
    if( nrhs != 1 )
    {
        mexPrintf( "usage: mexLBP( rgb2gray(image) )\n" );
        return;
    }
    
    uchar *image = (uchar*)mxGetData( prhs[0] );
    
    int width  = mxGetN( prhs[0] );
    int height = mxGetM( prhs[0] );
    
    const int nb = 8;
//     const int ox[nb] = {1, 0, -1, 0, 1, -1, -1, 1};
//     const int oy[nb] = {0, -1, 0, 1, -1, -1, 1, 1};
    
    const int ox[nb] = {1, 1, 0, -1, -1, -1, 0, 1};
    const int oy[nb] = {0, 1, 1, 1, 0, -1, -1, -1};
    
    plhs[0] = mxCreateNumericMatrix( height, width, mxUINT8_CLASS, mxREAL );
    uchar *lbp = (uchar*)mxGetData( plhs[0] );
    
    for( int y = 0; y < height; ++y )
    {
        for( int x = 0; x < width; ++x )
        {
            int p = 0;
            
            int ind = sub2ind(y, x, height);
            int pc = static_cast<int>( image[ind] );
            
            for( int n = 0; n < nb; ++n )
            {
                int ni = sub2ind(y+oy[n], x+ox[n], height);
                if( ni < 0 || ni >= height * width )
                    continue;
                
                int pn = static_cast<int>( image[ni] );
                
                if( pn >= pc )
                    p += (1 << (n+1));
            }
            
            lbp[ind] = static_cast<uchar>( p );
        }
    }
}
