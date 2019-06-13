#include <cmath>
#include "mex.h"
#include "../compatibility/isScalar.h"

/*
 * [dzdx] = regionToPixelSoft_backward(weightsSP, dzdy)
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
    } else if (nlhs != 1 || nrhs != 2) {
        mexErrMsgTxt("Error. Usage: [dzdx] = regionToPixelSoft_backward(weightsSP, dzdy)");
        return;
    }
    
    // Get pointers
    const mxArray* weightsSPMx = input[0];
    const mxArray* dzdyMx = input[1];
    
    // Check inputs
    if (!mxIsDouble(weightsSPMx) || mxGetNumberOfDimensions(weightsSPMx) != 3) {
        mexErrMsgTxt("Error: weightsSP must be double with format labelCount x spCount x rpCount!");
    }
    const mwSize* dims = mxGetDimensions(weightsSPMx);
    int labelCount = dims[0];
    int spCount    = dims[1];
    int rpCount    = dims[2];
    const mwSize* dzdyDims = mxGetDimensions(dzdyMx);
    if (!mxIsSingle(dzdyMx) || dzdyDims[0] != 1 || dzdyDims[1] != 1 || dzdyDims[2] != labelCount ||
            (!(mxGetNumberOfDimensions(dzdyMx) == 4 && dzdyDims[3] == spCount)
            && !(mxGetNumberOfDimensions(dzdyMx) == 3))) {
        mexErrMsgTxt("Error: dzdy must be single with format 1 x 1 x labelCount x spCount!");
    }
    
    // Get arrays
    double* weightsSP = (double*) mxGetData(weightsSPMx);
    float* dzdy   = (float*) mxGetData(dzdyMx);
    
    // Create output and initialize it to all zeros (in mxCreateNumericArray)
    mwSize dzdxSize[4];
    dzdxSize[0] = 1;
    dzdxSize[1] = 1;
    dzdxSize[2] = labelCount;
    dzdxSize[3] = rpCount;
    out[0] = mxCreateNumericArray(4, dzdxSize, mxSINGLE_CLASS, mxREAL);
    float* dzdx = (float*) mxGetData(out[0]);
    
    for (int spIdx = 0; spIdx < spCount; spIdx++) {
        for (int labelIdx = 0; labelIdx < labelCount; labelIdx++) {
            for (int rpIdx = 0; rpIdx < rpCount; rpIdx++) {
                // 
                
                // We can safely ignore the first two dimensions of these
                // matrices as they are always 1
                int weightsSPIdx = labelIdx + spIdx * labelCount;
                double boxIdxD = weightsSP[weightsSPIdx];
                int boxIdx = (int) boxIdxD - 1; // Convert from Matlab to C indexing
                if (!mxIsNaN(boxIdxD)) {
                    int dzdxIdx = labelIdx + boxIdx * labelCount;
                    dzdx[dzdxIdx] = dzdx[dzdxIdx] + dzdy[weightsSPIdx];
                }
            }
        }
    }
}