#include <cmath>
#include "mex.h"
#include "../compatibility/isScalar.h"

/*
 * [dzdx] = labelPresence_backward(spCount, labelMap, dzdy)
 *
 * Note that this script works essentially the same as regionToPixel_backward.
 * It maps from one label to many superpixels.
 * This uses the mask saved in the forward pass.
 * 
 * Copyright by Holger Caesar, 2015
 */

void mexFunction(int nlhs, mxArray *out[], int nrhs, const mxArray *input[]) {
    if (nlhs == 0) {
        return;
    } else if (nlhs != 1 || nrhs != 3) {
        mexErrMsgTxt("Error. Usage: [dzdx] = labelPresence_backward(spCount, labelMap, dzdy)");
        return;
    }
    
    // Get pointers
    const mxArray* spCountMx  = input[0];
    const mxArray* labelMapMx = input[1];
    const mxArray* dzdyMx     = input[2];
    
    // Check inputs
    if (!mxIsDouble(spCountMx) || !isScalar(spCountMx)) {
        mexErrMsgTxt("Error: spCount must be a scalar double!");
    }
    if (!mxIsDouble(labelMapMx) || mxGetNumberOfDimensions(labelMapMx) != 2) {
        mexErrMsgTxt("Error: labelMap must be double with format labelCount x labelListCount!");
    }
    int labelCount     = mxGetM(labelMapMx);
    int labelListCount = mxGetN(labelMapMx);
    const mwSize* dzdyDims = mxGetDimensions(dzdyMx);
    if (!mxIsSingle(dzdyMx) || dzdyDims[0] != 1 || dzdyDims[1] != 1 || dzdyDims[2] != labelCount ||
              (!(mxGetNumberOfDimensions(dzdyMx) == 4 && dzdyDims[3] == labelListCount)
            && !(mxGetNumberOfDimensions(dzdyMx) == 3))) {
        mexErrMsgTxt("Error: dzdy must be single with format 1 x 1 x labelCount x labelListCount!");
    }
    
    // Get arrays
    int spCount  = (int) mxGetScalar(spCountMx);
    double* labelMap = (double*) mxGetData(labelMapMx);
    float* dzdy   = (float*) mxGetData(dzdyMx);
    
    // Create output and initialize it to all zeros (in mxCreateNumericArray)
    mwSize dzdxSize[4];
    dzdxSize[0] = 1;
    dzdxSize[1] = 1;
    dzdxSize[2] = labelCount;
    dzdxSize[3] = spCount;
    out[0] = mxCreateNumericArray(4, dzdxSize, mxSINGLE_CLASS, mxREAL);
    float* dzdx = (float*) mxGetData(out[0]);
    
    for (int labelListIdx = 0; labelListIdx < labelListCount; labelListIdx++) {
        for (int labelIdx = 0; labelIdx < labelCount; labelIdx++) {
            // We can safely ignore the first two dimensions of these
            // matrices as they are always 1
            int labelMapIdx = labelIdx + labelListIdx * labelCount;
            double boxIdxD = labelMap[labelMapIdx];
            if (!mxIsNaN(boxIdxD)) {
                int boxIdx = (int) boxIdxD - 1; // Convert from Matlab to C indexing
                int dzdxIdx = labelIdx + boxIdx * labelCount;
                dzdx[dzdxIdx] = dzdx[dzdxIdx] + dzdy[labelMapIdx];
            }
        }
    }
}