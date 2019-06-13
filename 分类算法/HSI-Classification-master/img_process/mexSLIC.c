//=================================================================================
//  mexSLIC.c
//  Superpixel Segmentation with the SLIC algorithm
//  Author: 2016-10-24, jlfeng

//=================================================================================
/*Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met
 
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * Neither the name of EPFL nor the
 names of its contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND ANY
 EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE REGENTS AND CONTRIBUTORS BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
 #include<mex.h>
#include <stdio.h>
#include <math.h>
#include <float.h>
#include <string.h>  

#define MX_MAX(a,b) ((a) > (b) ? (a) : (b)) 
#define MX_MIN(a,b) ((a) < (b) ? (a) : (b)) 

void GetSeeds(int width, int height, int numSpIn, int *flagSeed,
    int *searchSize, int *numSeeds)
{    
    int step;   
    int numStepX=0, numStepY=0;
    double errX=0, errY=0;
    double stepXRefine, stepYRefine;
    int px,py,seedX,seedY,idxSeed;

    step=(int)(0.5+sqrt(width*height*1.0/numSpIn));
    numStepX=width/step;
    numStepY=height/step;
    errX=width-numStepX*step;
    errY=height-numStepY*step;
    stepXRefine=step+errX*1.0/numStepX;
    stepYRefine=step+errY*1.0/numStepY;

	idxSeed=0;
	for( py = 0; py < numStepY; py++ )
	{		
		for( px = 0; px < numStepX; px++ )
		{
            seedX = (int)(step/2+px*stepXRefine);        
            seedY = (int)(step/2+py*stepYRefine);
			flagSeed[seedY*width+seedX]=1;
			idxSeed++;
		}
	}
    *numSeeds = idxSeed;
    *searchSize=(int)(step*2);
}

void ExecuteSLIC(double *imgData, mwSize *dataDim, double *seeds, int numSeeds, 
    const int searchSize, const double paraCompact, const int iterNum, int *spLabel)
{
    int height=dataDim[0], width=dataDim[1], depth=dataDim[2];
    int imgArea=width*height;
    double distFeature=0, distSpatial=0, distSum=0;
    int tau;
    int px,py,pd, rangeX[2],rangeY[2];
    int idxPixel, idxSp;
    double *ptrSeedData, *ptrImgData;
    int halfSearchSize=searchSize/2;
    double maxDistSpatial=2.0*halfSearchSize*halfSearchSize;
    
    //Memory allocation
    double *minDistRec=mxMalloc(imgArea*sizeof(double));
    double *spSize=mxMalloc(numSeeds*sizeof(double));
    double *spCumData=mxMalloc(numSeeds*(depth+2)*sizeof(double));    
    double *ptrSpCumData;
    
    for (tau=0;tau<iterNum;tau++) //Perform several iterations
    {
        //Initialize the distance record
        for (idxPixel=0;idxPixel<imgArea;idxPixel++)
        {
            minDistRec[idxPixel]=DBL_MAX;
        }
        
        for (idxSp=0;idxSp<numSeeds;idxSp++)
        {
            ptrSeedData=seeds+idxSp*(2+depth);
            rangeX[0]=MX_MAX(ptrSeedData[0]-halfSearchSize,0);
            rangeX[1]=MX_MIN(ptrSeedData[0]+halfSearchSize,width);
            rangeY[0]=MX_MAX(ptrSeedData[1]-halfSearchSize,0);
            rangeY[1]=MX_MIN(ptrSeedData[1]+halfSearchSize,height);
            for (py=rangeY[0];py<rangeY[1];py++)
            {
                ptrImgData=imgData+(py*width+rangeX[0])*depth;
                for (px=rangeX[0];px<rangeX[1];px++)
                {
                    idxPixel=py*width+px;
                    distSpatial=(px-ptrSeedData[0])*(px-ptrSeedData[0])+(py-ptrSeedData[1])*(py-ptrSeedData[1]);
                    distSpatial/=maxDistSpatial;
                    distFeature=0;
                    for (pd=0; pd<depth;pd++)
                    {
                        distFeature+=pow(ptrImgData[pd]-ptrSeedData[pd+2],2);
                    } 
                    distSum=distFeature+paraCompact*distSpatial;
                    if (distSum<minDistRec[idxPixel])
                    {
                        minDistRec[idxPixel]=distSum;
                        spLabel[idxPixel]=idxSp;
                    }
                    ptrImgData+=depth;
                }
            }
        }
        
        memset(spSize,0,numSeeds*sizeof(double));
        memset(spCumData,0,numSeeds*(depth+2)*sizeof(double));
        
        idxPixel=0;
        ptrImgData=imgData;
        for (py=0;py<height;py++)
        {        
            for (px=0;px<width;px++)
            {
                idxSp=spLabel[idxPixel];
                ptrSpCumData=spCumData+idxSp*(2+depth);            
                spSize[idxSp]++;
                ptrSpCumData[0]+=px;
                ptrSpCumData[1]+=py;
                for (pd=0;pd<depth;pd++)
                {
                    ptrSpCumData[pd+2]+=ptrImgData[pd];
                }
                idxPixel++;
                ptrImgData+=depth;
            }
        }
        
        for (idxSp=0;idxSp<numSeeds;idxSp++)
        {
            ptrSeedData=seeds+idxSp*(2+depth);
            ptrSpCumData=spCumData+idxSp*(2+depth);
            spSize[idxSp]=MX_MAX(spSize[idxSp],1);
            for (pd=0;pd<depth+2;pd++)
            {
                ptrSeedData[pd]=ptrSpCumData[pd]/spSize[idxSp];
            } 
        }
    }
    
    mxFree(spSize);
    mxFree(minDistRec);
    mxFree(spCumData);    
}

void SuperpixelRelabeling(int *spLabel, mwSize *dims, int numSpIn, int *spLabelC, int *numSpOut)
{
    int height=dims[0], width=dims[1], imgSize=width*height;
    int thrSpSize=imgSize/(numSpIn*2);
    int idxPixel, idxPixelAnchor;
    int px,py, pxn, pyn, idxn;    
    int dx[4]={-1,0,1,0}; // 4-connection neighborhood
    int dy[4]={0,-1,0,1};
    int numSp=0;
    int adjLabel=0;
    int *vecIdxPixelInSp=mxMalloc(2*imgSize*sizeof(int));
    int numPixelInSp, idxPixelInSp;
    for (idxPixel=0;idxPixel<imgSize;idxPixel++)
    {
        spLabelC[idxPixel]=-1;
    }
    
    idxPixelAnchor=0;
    for (py=0;py<height;py++)
    {
        for (px=0;px<width;px++)
        {
            if (spLabelC[idxPixelAnchor]<0)// find a new superpixel
            {
                spLabelC[idxPixelAnchor]=numSp;
                vecIdxPixelInSp[0]=px;
                vecIdxPixelInSp[1]=py;
                
                for (idxn=0;idxn<4;idxn++)// search the neighboring superpixel
                {
                    pxn=px+dx[idxn];
                    pyn=py+dy[idxn];
                    if ((pxn>-1 && pxn<width) &&(pyn>-1 && pyn<height))
                    {
                        idxPixel=pyn*width+pxn;
                        if (spLabelC[idxPixel]>-1)
                        {
                            adjLabel=spLabelC[idxPixel];
                        }
                    }
                }
                // Search pixels of the same superpixel
                numPixelInSp=1;
                idxPixelInSp=0;
                while (idxPixelInSp<numPixelInSp)
                {
                    for (idxn=0;idxn<4;idxn++)
                    {
                        pxn=vecIdxPixelInSp[idxPixelInSp*2]+dx[idxn];
                        pyn=vecIdxPixelInSp[idxPixelInSp*2+1]+dy[idxn];
                        if ((pxn>-1 && pxn<width) &&(pyn>-1 && pyn<height))
                        {
                            idxPixel=pyn*width+pxn;
                            if (spLabelC[idxPixel]<0 && spLabel[idxPixel]==spLabel[idxPixelAnchor])
                            {
                                vecIdxPixelInSp[numPixelInSp*2]=pxn;
                                vecIdxPixelInSp[numPixelInSp*2+1]=pyn;
                                spLabelC[idxPixel]=numSp;
                                numPixelInSp++;
                            }
                        }
                    }
                    idxPixelInSp++;
                }
                
                if (numPixelInSp<thrSpSize)
                {
                    for (idxPixelInSp=0;idxPixelInSp<numPixelInSp;idxPixelInSp++)
                    {
                        idxPixel=vecIdxPixelInSp[idxPixelInSp*2+1]*width+vecIdxPixelInSp[idxPixelInSp*2];
                        spLabelC[idxPixel]=adjLabel;
                    }
                }
                else
                {
                    numSp++;
                }                
            }
             idxPixelAnchor++;
        }
    }
    
    *numSpOut=numSp;
    mxFree(vecIdxPixelInSp);
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    int imgWidth, imgHeight, imgDepth,imgSize;
    double *ptrInputData, *ptrImgData,*ptrPixelData;
    int *spLabel, *spLabelC;
    double *spSeeds, *ptrSeedData;
    int numSpIn, numSpOut,numSeeds, *flagSeed;
    int searchSize;
    int iterNum;
    double paraCompact;
    int px,py,pd, idxPixel,idxSeed, ii;
    mwSize numdims, *dims;
    int *spLabelOut, *ptrNumSpOut;
    
    //Check input parameter
    if (nrhs<1)
    {
        mexErrMsgTxt("No input img.");
    }
    else if (nrhs>4)
    {
        mexErrMsgTxt("Too many input arguments.");
    }
    
    // Get data from input augments    
    numdims=mxGetNumberOfDimensions(prhs[0]) ;
    dims=mxGetDimensions(prhs[0]);
    ptrInputData=(double *)mxGetData(prhs[0]);
    imgHeight=dims[0];
    imgWidth=dims[1];
    imgDepth=(numdims==2)?1:dims[2];
    imgSize=imgHeight*imgWidth;
    numSpIn=(int)mxGetScalar(prhs[1]);
    paraCompact=mxGetScalar(prhs[2]);
    iterNum=(int)mxGetScalar(prhs[3]);
    
    // Allocate memory for temporary data
    ptrImgData=mxMalloc(sizeof(double)*imgSize*imgDepth);
    spLabel=mxMalloc(sizeof(int)*imgSize);
    spLabelC=mxMalloc(sizeof(int)*imgSize);
    flagSeed=mxMalloc(sizeof(int)*imgSize);
    memset(ptrImgData,0,sizeof(double)*imgSize*imgDepth);
    memset(spLabel,0,sizeof(int)*imgSize);
    memset(spLabelC,0,sizeof(int)*imgSize);
    memset(flagSeed,0,sizeof(int)*imgSize);
    searchSize=0;
    numSeeds=0;
    GetSeeds(imgWidth, imgHeight, numSpIn, flagSeed,&searchSize, &numSeeds);
    if (searchSize<2)
    {
        mexErrMsgTxt("Superpixel size is too small. Considering reduce the desired superpxiel number");
    }
    spSeeds=mxMalloc(sizeof(double)*numSeeds*(imgDepth+2));
    memset(spSeeds,0,sizeof(double)*numSeeds*(imgDepth+2));    
    //img data copy
    ii=0;
    idxSeed=0;
    for (px=0;px<imgWidth;px++)        
     {
         for (py=0;py<imgHeight;py++)    
         {
             idxPixel=py*imgWidth+px;
             ptrPixelData=ptrImgData+idxPixel*imgDepth;
             for (pd=0;pd<imgDepth;pd++)
             {
                 ptrPixelData[pd]=ptrInputData[ii+pd*imgSize];
             }
             if (1==flagSeed[idxPixel])
             {
                 ptrSeedData=spSeeds+idxSeed*(2+imgDepth);
                 ptrSeedData[0]=px;
                 ptrSeedData[1]=py;
                 for (pd=0;pd<imgDepth;pd++)
                 {
                     ptrSeedData[2+pd]=ptrPixelData[pd];
                 }                 
                 idxSeed++;
             }
             ii++;
         }
     }

    //Perform SLIC 
    ExecuteSLIC(ptrImgData, dims, spSeeds, numSeeds, searchSize, 
        paraCompact, iterNum, spLabel);   
         
    //Relabeling to enforce connectivity
    SuperpixelRelabeling(spLabel, dims, numSpIn, spLabelC, &numSpOut);
    
    // Assign output augments
    plhs[0] = mxCreateNumericMatrix(imgHeight,imgWidth,mxINT32_CLASS,mxREAL);
    spLabelOut=(int *)mxGetData(plhs[0]);
    ii=0;
    for (px=0;px<imgWidth;px++)
    {
        for (py=0;py<imgHeight;py++)
        {
             idxPixel=py*imgWidth+px;
             spLabelOut[ii]=spLabelC[idxPixel];
             ii++;
        }
    }
    plhs[1] = mxCreateNumericMatrix(1,1,mxINT32_CLASS,mxREAL);
    ptrNumSpOut = (int*)mxGetData(plhs[1]);
    *ptrNumSpOut=numSpOut;
    
      // Deallocate memory
      mxFree(ptrImgData);
      mxFree(spLabel);
      mxFree(spLabelC);
      mxFree(flagSeed);
      mxFree(spSeeds);
}



