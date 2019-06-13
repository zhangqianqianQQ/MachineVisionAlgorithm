#include <cmath>
#include "mex.h"
#include "matrix.h"
#include "../compatibility/isScalar.h"

/*
 * dzdx = roiPooling_backward(boxCount, convImSize, roiPoolSize, masks, dzdy);
 *
 * Sum the gradients that are backpropagated through the ROI pooling layer.
 *
 * Copyright by Holger Caesar, 2015
 */

void mexFunction(int nlhs, mxArray *out[], int nrhs, const mxArray *input[])
{
    if (nlhs == 0) {
        return;
    } else if (nlhs != 1 || nrhs != 5) {
        mexErrMsgTxt("Error. Usage: dzdx = roiPooling_backward(boxCount, convImSize, roiPoolSize, masks, dzdy)");
        return;
    }
    
    // Get pointers
    const mxArray* boxCountMx = input[0];
    const mxArray* convImSizeMx = input[1];
    const mxArray* roiPoolSizeMx = input[2];
    const mxArray* masksMx = input[3];
    const mxArray* dzdyMx = input[4];
    
    // Check inputs
    if (!mxIsDouble(boxCountMx) || !isScalar(boxCountMx)) {
        mexErrMsgTxt("Error: boxCount must be a scalar double!");
    }
    if (!mxIsDouble(convImSizeMx) || mxGetNumberOfDimensions(convImSizeMx) != 2 || mxGetM(convImSizeMx) != 1 || mxGetN(convImSizeMx) != 3) {
        mexErrMsgTxt("Error: convImSize must be double with format 1 x 3!");
    }
    if (!mxIsDouble(roiPoolSizeMx) || mxGetNumberOfDimensions(roiPoolSizeMx) != 2 || mxGetM(roiPoolSizeMx) != 1 || mxGetN(roiPoolSizeMx) != 2) {
        mexErrMsgTxt("Error: roiPoolSize must be double with format 1 x 2!");
    }
    int boxCount = (int) mxGetScalar(boxCountMx);
    const mwSize* masksDims = mxGetDimensions(masksMx);
    const mwSize* dzdyDims = mxGetDimensions(dzdyMx);
    if (!mxIsSingle(masksMx)){
        mexErrMsgTxt("Error: masks must be single!");
    }
    if (!mxIsSingle(dzdyMx)) {
        mexErrMsgTxt("Error: dzdy must be single!");
    }
    if (    mxGetNumberOfDimensions(masksMx) != mxGetNumberOfDimensions(dzdyMx) ||
            masksDims[0] != dzdyDims[0] ||
            masksDims[1] != dzdyDims[1] ||
            masksDims[2] != dzdyDims[2] ||
            (masksDims[3] != dzdyDims[3] && boxCount > 1)) {
        mexErrMsgTxt("Error: masks must have the same format as dzdy!");
    }
    
    // Get arrays
    double* convImSize = (double*) mxGetData(convImSizeMx);
    double* roiPoolSize = (double*) mxGetData(roiPoolSizeMx);
    float* masks = (float*) mxGetData(masksMx);
    float* dzdy = (float*) mxGetData(dzdyMx);
    
    int roiPoolSizeY = roiPoolSize[0];
    int roiPoolSizeX = roiPoolSize[1];
    int convImSizeY = convImSize[0];
    int convImSizeX = convImSize[1];
    int channelCount = convImSize[2];
    
    // Create output and initialize it to all zeros (in mxCreateNumericArray)
    // dzdx = zeros(convImSize, 'single');
    mwSize dzdxSize[3];
    dzdxSize[0] = convImSizeY;
    dzdxSize[1] = convImSizeX;
    dzdxSize[2] = channelCount;
    out[0] = mxCreateNumericArray(3, dzdxSize, mxSINGLE_CLASS, mxREAL);
    float* dzdx = (float*) mxGetData(out[0]);
    
    for (int boxIdx = 0; boxIdx < boxCount; boxIdx++) {
        for (int regionIdxY = 0; regionIdxY < roiPoolSizeY; regionIdxY++) {
            for (int regionIdxX = 0; regionIdxX < roiPoolSizeX; regionIdxX++) {
                for (int channelIdx = 0; channelIdx < channelCount; channelIdx++) {
                    // convImgIdxNoChannel = masks(regionIdxY, regionIdxX, channelIdx, boxIdx);
                    int masksIdx = regionIdxY + regionIdxX * roiPoolSizeY + channelIdx * roiPoolSizeY * roiPoolSizeX + boxIdx * roiPoolSizeY * roiPoolSizeX * channelCount;
                    bool isnan = mxIsNaN(masks[masksIdx]);
                    int convImgIdxNoChannel = masks[masksIdx]; // C indexing
                    
                    if (!isnan) {
                        // Sum over all RoIs that max-pooled x in the forward pass:
                        // dzdx(convImgY, convImgX, channelIdx) = dzdx(convImgY, convImgX, channelIdx) + dzdy(regionIdxY, regionIdxX, channelIdx, boxIdx);
                        int dzdxIdx = convImgIdxNoChannel + channelIdx * convImSizeY * convImSizeX;
                        dzdx[dzdxIdx] = dzdx[dzdxIdx] + dzdy[masksIdx];
                    }
                }
            }
        }
    }
}