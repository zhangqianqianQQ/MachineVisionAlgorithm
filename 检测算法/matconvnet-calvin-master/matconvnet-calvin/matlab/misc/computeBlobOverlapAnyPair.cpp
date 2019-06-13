/*
 * [...] = computeBlobOverlapAnyPair(...)
 * Used in computeBlobOverlapAny().
 *
 * Computes whether any two blobs overlap at all.
 *
 * Copyright by Holger Caesar, 2015
 *
 */
#include "mex.h"
#include "matrix.h"

void mexFunction(
        int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[] ) {
    
    // Get inputs
    const mxArray* blobsIndsA = prhs[0];
    const mxArray* blobsIndsB = prhs[1];
    int propCountA = mxGetM(blobsIndsA);
    int propCountB = mxGetM(blobsIndsB);
    
    // Create outputs
    plhs[0] = mxCreateNumericMatrix(propCountA, propCountB, mxDOUBLE_CLASS, mxREAL);
    double* overlaps = (double*) mxGetData(plhs[0]);
    
    for (int i = 0; i <= propCountA-1; i++) {
        mxArray* indsAMx = mxGetCell(blobsIndsA, i);
        int* indsA = (int*) mxGetData(indsAMx);
        int mA = mxGetM(indsAMx);
        
        for (int j = 0; j <= propCountB-1; j++) {
            mxArray* indsBMx = mxGetCell(blobsIndsB, j);
            int* indsB = (int*) mxGetData(indsBMx);
            int mB = mxGetM(indsBMx);
            
            
            // Early abort if the ranges are completely disjoint
            if (indsB[mB-1] < indsA[0] || indsA[mA-1] < indsB[0]) {
                //continue; % Uncomment this and test
            } else {
                int posA = 0;
                int posB = 0;
                
                for ( ; posB < mB && posA < mA; ) {
                    if (indsA[posA] == indsB[posB]) {
                        overlaps[i + propCountA * j] = 1;
                        break;
                    } else if (indsA[posA] < indsB[posB]) {
                        posA++;
                    } else {
                        posB++;
                    }
                }
            }
        }
    }
}