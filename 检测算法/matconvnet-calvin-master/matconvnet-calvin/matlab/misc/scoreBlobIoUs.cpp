// [scores] = scoreBlobIoUs(blobsA, blobsB)
//
// Computes the pairwise IoU scores between two sets of blobs.
// Mex-version is about 6 times faster than Matlab implementation (200*200 blob pairs).
//
// Use the following test example to verify that it works correctly:
// blobA.rect = [1, 1, 3, 3];
// blobA.mask = false(3, 3); blobA.mask(1:2, 2) = true;
// blobA.size = sum(blobA.mask(:));
// 
// blobB.rect = [2, 2, 4, 4];
// blobB.mask = false(4, 4); blobB.mask(1:2, 1) = true;
// blobB.size = sum(blobB.mask(:));
// 
// iou = scoreBlobIoUs(blobA, blobB);
// assert(iou == 1/3);
//
// Copyright by Holger Caesar, 2015

#include "mex.h"
#include "matrix.h" // for structs
#include <algorithm> // for max,min
#include <cmath> // for round

// Check whether two rectangles intersect
bool isBoxIntersect(size_t* aRect, size_t* bRect) {
    return (!(aRect[0] > bRect[2] || bRect[0] > aRect[2] ||
            aRect[1] > bRect[3] || bRect[1] > aRect[3]));
}

// Evaluate the intersection over union for two blobs
double scoreBlobIoU(size_t* aRect, bool* aMask, size_t aSize, size_t* bRect, bool* bMask, size_t bSize) {
    if (isBoxIntersect(aRect, bRect)) {
        // intersectionRect = [max(aRect(1:2), bRect(1:2)), min(aRect(3:4), bRect(3:4))];
        size_t intersectionRect[4] = {
            std::max(aRect[0], bRect[0]),
            std::max(aRect[1], bRect[1]),
            std::min(aRect[2], bRect[2]),
            std::min(aRect[3], bRect[3])
        };
        
        // aMaskCutRect = [intersectionRect(1:2) - aRect(1:2) + 1, intersectionRect(3:4) - aRect(1:2) + 1];
        size_t aMaskCutRect[4] = {
            intersectionRect[0] - aRect[0] + 1,
            intersectionRect[1] - aRect[1] + 1,
            intersectionRect[2] - aRect[0] + 1,
            intersectionRect[3] - aRect[1] + 1
        };
        
        // bMaskCutRect = [intersectionRect(1:2) - bRect(1:2) + 1, intersectionRect(3:4) - bRect(1:2) + 1];
        size_t bMaskCutRect[4] = {
            intersectionRect[0] - bRect[0] + 1,
            intersectionRect[1] - bRect[1] + 1,
            intersectionRect[2] - bRect[0] + 1,
            intersectionRect[3] - bRect[1] + 1
        };
        
        // aMaskCut = blobA.mask(aMaskCutRect(1):aMaskCutRect(3), aMaskCutRect(2):aMaskCutRect(4));
        size_t aMaskSizeY = aRect[2] - aRect[0] + 1;
        size_t aMaskSizeX = aRect[3] - aRect[1] + 1;
        size_t aMaskCutSizeY = aMaskCutRect[2] - aMaskCutRect[0] + 1;
        size_t aMaskCutSizeX = aMaskCutRect[3] - aMaskCutRect[1] + 1;
        bool* aMaskCut = (bool*) mxCalloc(aMaskCutSizeX * aMaskCutSizeY, sizeof(bool));
        for (size_t x = 0; x < aMaskCutSizeX; x++) {
            for (size_t y = 0; y < aMaskCutSizeY; y++) {
                aMaskCut[y + x * aMaskCutSizeY] = aMask[(aMaskCutRect[0]-1+y) + (aMaskCutRect[1]-1+x) * aMaskSizeY];
            }
        }
        
        // bMaskCut = blobB.mask(bMaskCutRect(1):bMaskCutRect(3), bMaskCutRect(2):bMaskCutRect(4));
        size_t bMaskSizeY = bRect[2] - bRect[0] + 1;
        size_t bMaskSizeX = bRect[3] - bRect[1] + 1;
        size_t bMaskCutSizeY = bMaskCutRect[2] - bMaskCutRect[0] + 1;
        size_t bMaskCutSizeX = bMaskCutRect[3] - bMaskCutRect[1] + 1;
        bool* bMaskCut = (bool*) mxCalloc(bMaskCutSizeX * bMaskCutSizeY, sizeof(bool));
        for (size_t x = 0; x < bMaskCutSizeX; x++) {
            for (size_t y = 0; y < bMaskCutSizeY; y++) {
                bMaskCut[y + x * bMaskCutSizeY] = bMask[(bMaskCutRect[0]-1+y) + (bMaskCutRect[1]-1+x) * bMaskSizeY];
            }
        }
        
        // free memory
        mxFree((void*) aMaskCut);
        mxFree((void*) bMaskCut);
        
        // intersection = sum(aMaskCut(:) & bMaskCut(:));
        size_t intersection = 0;
        for (size_t i = 0; i < bMaskCutSizeX * bMaskCutSizeY; i++) {
            if (aMaskCut[i] && bMaskCut[i]) {
                intersection++;
            }
        }
        
        // union = blobA.size + blobB.size - intersection;
        size_t unionV = aSize + bSize - intersection;
        
        // iou = intersection / union;
        return (double) intersection / (double) unionV;
    } else {
        return 0.0;
    }
}

// Entry point
void mexFunction(int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[]) {
    // Check the number of inputs
    if(nrhs!=2) {
        mexErrMsgIdAndTxt("MyToolbox:arrayProduct:nrhs",
                "Two inputs required.");
    }
    
    // Check the number of outputs
    if(nlhs!=1) {
        mexErrMsgIdAndTxt("MyToolbox:arrayProduct:nlhs",
                "One output required.");
    }
    
    // Check that both inputs are struct arrays
    if( !mxIsStruct(prhs[0])) {
        mexErrMsgIdAndTxt("MyToolbox:arrayProduct:notStruct",
                "Input 1 must be type struct.");
    }
    if( !mxIsStruct(prhs[1])) {
        mexErrMsgIdAndTxt("MyToolbox:arrayProduct:notStruct",
                "Input 2 must be type struct.");
    }
    
    // Get inputs
    const mxArray* blobsA = prhs[0];
    const mxArray* blobsB = prhs[1];
    
    // Create outputs
    size_t nY = mxGetM(prhs[0]);
    size_t nX = mxGetM(prhs[1]);
    plhs[0] = mxCreateDoubleMatrix(nY, nX, mxREAL);
    double* scores = mxGetPr(plhs[0]);
    
    // Call function for each pair
    for (size_t x = 0; x < nX; x++) {
        for (size_t y = 0; y < nY; y++) {
            mxArray* aRectPtr = mxGetFieldByNumber(blobsA, y, 0);
            mxArray* bRectPtr = mxGetFieldByNumber(blobsB, x, 0);
            
            mxArray* aMaskPtr = mxGetFieldByNumber(blobsA, y, 1);
            mxArray* bMaskPtr = mxGetFieldByNumber(blobsB, x, 1);
            
            mxArray* aSizePtr = mxGetFieldByNumber(blobsA, y, 2);
            mxArray* bSizePtr = mxGetFieldByNumber(blobsB, x, 2);
            
            double* aRectData = (double*) mxGetData(aRectPtr);
            double* bRectData = (double*) mxGetData(bRectPtr);
            
            size_t aRect[4] = {
                (size_t) std::round(aRectData[0]),
                (size_t) std::round(aRectData[1]),
                (size_t) std::round(aRectData[2]),
                (size_t) std::round(aRectData[3])
            };
            size_t bRect[4] = {
                (size_t) std::round(bRectData[0]),
                (size_t) std::round(bRectData[1]),
                (size_t) std::round(bRectData[2]),
                (size_t) std::round(bRectData[3])
            };
            
            bool* aMask = (bool*) mxGetData(aMaskPtr);
            bool* bMask = (bool*) mxGetData(bMaskPtr);
            
            double* aSizeD = (double*) mxGetData(aSizePtr);
            double* bSizeD = (double*) mxGetData(bSizePtr);
            
            size_t aSize = (size_t) std::round(*aSizeD);
            size_t bSize = (size_t) std::round(*bSizeD);
            
            scores[y + x*nY] = scoreBlobIoU(aRect, aMask, aSize, bRect, bMask, bSize);
        }
    }
}
