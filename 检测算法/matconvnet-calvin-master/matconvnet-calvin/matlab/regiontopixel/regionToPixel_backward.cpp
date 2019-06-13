#include <cmath>
#include "mex.h"
#include "../compatibility/isScalar.h"

/*
 * [dzdx] = regionToPixel_backward(boxCount, spMap, dzdy)
 *
 * Go from a pixel level back to region level.
 * This uses the mask saved in the forward pass.
 * 
 * Copyright by Holger Caesar, 2015
 */

void mexFunction(int nlhs, mxArray *out[], int nrhs, const mxArray *input[])
{
    if (nlhs == 0) {
        return;
    } else if (nlhs != 1 || nrhs != 3) {
        mexErrMsgTxt("Error. Usage: [dzdx] = regionToPixel_backward(boxCount, spMap, dzdy)");
        return;
    }
    
    // Get pointers
    const mxArray* boxCountMx = input[0];
    const mxArray* spMapMx = input[1];
    const mxArray* dzdyMx = input[2];
    
    // Check inputs
    if (!mxIsDouble(boxCountMx) || !isScalar(boxCountMx)) {
        mexErrMsgTxt("Error: boxCount must be a scalar double!");
    }
    if (!mxIsDouble(spMapMx) || mxGetNumberOfDimensions(spMapMx) != 2) {
        mexErrMsgTxt("Error: spMap must be double with format labelCount x spCount!");
    }
    int labelCount = mxGetM(spMapMx);
    int spCount    = mxGetN(spMapMx);
    const mwSize* dzdyDims = mxGetDimensions(dzdyMx);
    if (!mxIsSingle(dzdyMx) || dzdyDims[0] != 1 || dzdyDims[1] != 1 || dzdyDims[2] != labelCount ||
              (!(mxGetNumberOfDimensions(dzdyMx) == 4 && dzdyDims[3] == spCount)
            && !(mxGetNumberOfDimensions(dzdyMx) == 3))) {
        mexErrMsgTxt("Error: dzdy must be single with format 1 x 1 x labelCount x spCount!");
    }
    
    // Get arrays
    int boxCount  = (int) mxGetScalar(boxCountMx);
    double* spMap = (double*) mxGetData(spMapMx);
    float* dzdy   = (float*) mxGetData(dzdyMx);
    
    // Create output and initialize it to all zeros (in mxCreateNumericArray)
    mwSize dzdxSize[4];
    dzdxSize[0] = 1;
    dzdxSize[1] = 1;
    dzdxSize[2] = labelCount;
    dzdxSize[3] = boxCount;
    out[0] = mxCreateNumericArray(4, dzdxSize, mxSINGLE_CLASS, mxREAL);
    float* dzdx = (float*) mxGetData(out[0]);
    
    for (int spIdx = 0; spIdx < spCount; spIdx++) {
        for (int labelIdx = 0; labelIdx < labelCount; labelIdx++) {
            // We can safely ignore the first two dimensions of these
            // matrices as they are always 1
            int spMapIdx = labelIdx + spIdx * labelCount;
            double boxIdxD = spMap[spMapIdx];
            int boxIdx = (int) boxIdxD - 1; // Convert from Matlab to C indexing
            if (!mxIsNaN(boxIdxD)) {
                int dzdxIdx = labelIdx + boxIdx * labelCount;
                dzdx[dzdxIdx] = dzdx[dzdxIdx] + dzdy[spMapIdx];
            }
        }
    }
}