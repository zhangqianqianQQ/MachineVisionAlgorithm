#include <cmath>
#include <algorithm>
#include "mex.h"

/*
 * [rois, masks] = roiPooling_forward(convIm, oriImSize, boxes, poolSize);
 *
 * ROI pool a convolutional image into spatial bins for each box and channel.
 *
 * Copyright by Jasper Uijlings, 2015
 * Modified by Holger Caesar, 2015
 */

void mexFunction(int nlhs, mxArray *out[], int nrhs, const mxArray *input[])
{
    if (nlhs == 0) {
        return;
    } else if (nlhs >= 3 || nrhs != 4) {
        mexErrMsgTxt("Error. Usage: [rois, masks] = roiPooling_forward(convIm, oriImSize, boxes, poolSize)");
        return;
    }
    
    // Get pointers
    const mxArray* convImMx = input[0];
    const mxArray* oriImSizeMx = input[1];
    const mxArray* boxesMx = input[2];
    const mxArray* poolSizeMx = input[3];
    
    // Check inputs
    if (!mxIsSingle(convImMx) || mxGetNumberOfDimensions(convImMx) != 3) {
        mexErrMsgTxt("Error: convIm must be single with format height x width x channelCount!");
    }
    if (!mxIsDouble(oriImSizeMx) || mxGetNumberOfDimensions(oriImSizeMx) != 2 || mxGetM(oriImSizeMx) != 1 || mxGetN(oriImSizeMx) != 3) {
        mexErrMsgTxt("Error: oriImSize must be double with format 1 x 3!");
    }
    if (!mxIsSingle(boxesMx) || mxGetNumberOfDimensions(boxesMx) != 2 || mxGetM(boxesMx) == 0 || mxGetN(boxesMx) != 4) {
        mexErrMsgTxt("Error: boxes must be single with format boxCount x 4!");
    }
    if (!mxIsDouble(poolSizeMx) || mxGetNumberOfDimensions(poolSizeMx) != 2 || mxGetM(poolSizeMx) != 1 || mxGetN(poolSizeMx) != 2) {
        mexErrMsgTxt("Error: poolSize must be double with format 1 x 2!");
    }
    
    // Get arrays
    float* convIm     = (float*)  mxGetData(convImMx);
    double* oriImSize = (double*) mxGetData(oriImSizeMx);
    float* boxes      = (float*)  mxGetData(boxesMx);
    double* poolSize  = (double*) mxGetData(poolSizeMx);
    
    const int poolSizeY = (const int) poolSize[0];
    const int poolSizeX = (const int) poolSize[1];
    const int poolNumel = poolSizeY * poolSizeX;
    
    // Get information about arrays
    double oriImSizeY = oriImSize[0];
    double oriImSizeX = oriImSize[1];
    const mwSize* convImSize = mxGetDimensions(convImMx);
    const int convImSizeY = (int) convImSize[0];
    const int convImSizeX = (int) convImSize[1];
    const mwSize channelCount = convImSize[2];
    const mwSize* boxSize = mxGetDimensions(boxesMx);
    const mwSize boxCount = boxSize[0];
    
    // Create output ROI array
    mwSize roisSize[4];
    roisSize[0] = poolSizeY;
    roisSize[1] = poolSizeX;
    roisSize[2] = channelCount;
    roisSize[3] = boxCount;
    out[0] = mxCreateNumericArray(4, roisSize, mxSINGLE_CLASS, mxREAL);
    float* rois = (float*) mxGetData(out[0]);
    float* masks;

    if (nlhs >= 2) {
        // masks = nan([poolSize, channelCount, boxCount], 'single');
        mwSize masksSize[5];
        masksSize[0] = poolSizeY;
        masksSize[1] = poolSizeX;
        masksSize[2] = channelCount;
        masksSize[3] = boxCount;
        out[1] = mxCreateNumericArray(4, masksSize, mxSINGLE_CLASS, mxREAL);
        masks = (float*) mxGetData(out[1]);
        
        // Init mask with nans
        double nan = mxGetNaN();
        for (int i = 0; i < poolNumel * channelCount * boxCount; i++) {
            masks[i] = nan;
        }
    }
    
    // Loop over the ROIs
    double boxStartY, boxEndY, boxStartX, boxEndX, diffY, diffX;
    int convImYIdx, convImXIdx, convImXStart, convImXEnd, convImYStart, convImYEnd;
    int maxConvImIndexNoChannel, convImIndexNoChannel, convImIndex, roisIndex, masksIndex;
    double* imIndsY = new double[poolSizeY + 1];
    double* imIndsX = new double[poolSizeX + 1];
    
    for (int boxIdx = 0; boxIdx < boxCount; boxIdx++){
        
        // Get rescaled box coordinates
        boxStartY = (boxes[boxIdx + 1 * boxCount] - 1) * ((double) convImSizeY-1) / ((double) oriImSizeY-1);
        boxStartX = (boxes[boxIdx + 0 * boxCount] - 1) * ((double) convImSizeX-1) / ((double) oriImSizeX-1);
        boxEndY   = (boxes[boxIdx + 3 * boxCount] - 1) * ((double) convImSizeY-1) / ((double) oriImSizeY-1);
        boxEndX   = (boxes[boxIdx + 2 * boxCount] - 1) * ((double) convImSizeX-1) / ((double) oriImSizeX-1);
        
        // Check if boxes are valid
        if (boxStartY < 0 || boxStartX < 0 || boxEndY > convImSizeY-1 || boxEndX > convImSizeX-1) {
            mexErrMsgTxt("Error: Invalid box in ROI pooling forward pass!");
        }
        
        // Update pixel diffs
        diffY = (boxEndY - boxStartY) / poolSizeY;
        diffX = (boxEndX - boxStartX) / poolSizeX;
        
        // Get unrounded coordinates of start and end of pooling regions
        for(int poolIdxY = 0; poolIdxY < poolSizeY+1; poolIdxY++) {
            imIndsY[poolIdxY] = boxStartY + poolIdxY * diffY;
        }
        for(int poolIdxX = 0; poolIdxX < poolSizeX+1; poolIdxX++) {
            imIndsX[poolIdxX] = boxStartX + poolIdxX * diffX;
        }
        
        // Now a for-loop over all pooling regions
        for (int poolIdxY = 0; poolIdxY < poolSizeY; poolIdxY++) {
            // Note: Regions need to be overlapping, to avoid problems when upscaling small boxes.
            convImYStart = floor(imIndsY[poolIdxY  ]); 
            convImYEnd   = std::min((int) ceil(imIndsY[poolIdxY+1]), convImSizeY-1);
            
            for (int poolIdxX = 0; poolIdxX < poolSizeX; poolIdxX++) {
                convImXStart = floor(imIndsX[poolIdxX  ]);
                convImXEnd   = std::min((int) ceil(imIndsX[poolIdxX+1]), convImSizeX-1);
                
                for(int channelIdx = 0; channelIdx < channelCount; channelIdx++) {
                    roisIndex = poolIdxY + poolIdxX * poolSizeY + channelIdx * poolNumel + boxIdx * poolNumel * channelCount;
                    
                    // Init maximum coordinate
                    maxConvImIndexNoChannel = -1;
                    
                    // Find maximum
                    for(convImXIdx = convImXStart; convImXIdx <= convImXEnd; convImXIdx++) {
                        for(convImYIdx = convImYStart; convImYIdx <= convImYEnd; convImYIdx++) {
                            convImIndexNoChannel = convImYIdx + convImXIdx * convImSizeY;
                            convImIndex = convImIndexNoChannel + channelIdx * convImSizeY * convImSizeX;
                            
                            if (convIm[convImIndex] > rois[roisIndex]){
                                rois[roisIndex] = convIm[convImIndex];
                                maxConvImIndexNoChannel = convImIndexNoChannel;
                            }
                        }
                    }
                    
                    // Create the mask for backpropagation that tells us which value in each
                    // pooling region of the conv image was the highest.
                    if (nlhs >= 2 && maxConvImIndexNoChannel != -1) {
                        // masks(regionYIdx, regionXIdx, channelIdx, boxIdx) = maxY;
                        masks[roisIndex] = maxConvImIndexNoChannel; // C indexing (make sure backward knows that!)
                    }
                }
            }
        }
    }

    // Delete created memory
    delete[] imIndsY;
    delete[] imIndsX;
}