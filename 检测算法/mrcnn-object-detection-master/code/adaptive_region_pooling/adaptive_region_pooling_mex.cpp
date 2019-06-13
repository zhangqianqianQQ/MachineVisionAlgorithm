//
// This file is part of the code that implements the following ICCV2015 accepted paper:
// title: "Object detection via a multi-region & semantic segmentation-aware CNN model"
// authors: Spyros Gidaris, Nikos Komodakis
// institution: Universite Paris Est, Ecole des Ponts ParisTech
// Technical report: http://arxiv.org/abs/1505.01749
// code: https://github.com/gidariss/mrcnn-object-detection
// 
// It is adapted from the SPP-Net code: 
// https://github.com/ShaoqingRen/SPP_net
// 
// AUTORIGHTS
// --------------------------------------------------------
// Copyright (c) 2015 Spyros Gidaris
// 
// "Object detection via a multi-region & semantic segmentation-aware CNN model"
// Technical report: http://arxiv.org/abs/1505.01749
// Licensed under The MIT License [see LICENSE for details]
// ---------------------------------------------------------
// Copyright (c) 2014, Shaoqing Ren
// 
// This file is part of the SPP code and is available 
// under the terms of the Simplified BSD License provided in 
// LICENSE. Please retain this notice and LICENSE if you use 
// this file (or any portion of it) in your project.
// --------------------------------------------------------- 

#include "mex.h"
#include <malloc.h>
#include <algorithm>
#include <ctime>
#include <vector>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#ifdef WIN32
#else
#include "xmmintrin.h"
#endif

using std::vector;

void inline normalizeBox(int* box_norm, const double* box, const double offset0, 
 const double offset, const double min_times, const int rsp_width, const int rsp_height){
	double x0 = box[0];
	double y0 = box[1];
	double x1 = box[2];
	double y1 = box[3];

	int x0_norm = int(floor((x0 - offset0 + offset) / min_times + 0.5) + 1);
	int y0_norm = int(floor((y0 - offset0 + offset) / min_times + 0.5) + 1);

	int x1_norm = int(ceil((x1 - offset0 - offset) / min_times - 0.5) + 1);
	int y1_norm = int(ceil((y1 - offset0 - offset) / min_times - 0.5) + 1);

	if (x0_norm > x1_norm)
	{
		x0_norm = (x0_norm + x1_norm) / 2;
		x1_norm = x0_norm;
	}

	if (y0_norm > y1_norm)
	{
		y0_norm = (y0_norm + y1_norm) / 2;
		y1_norm = y0_norm;
	}
	
	box_norm[0] = y0_norm;
	box_norm[2] = y1_norm;
	box_norm[1] = x0_norm;
	box_norm[3] = x1_norm;
}

void poolFeatures(float* pooled, const int* boxes_norm_outer, const int* boxes_norm_inner, 
				  vector<const float *> feats, const int* feat_ids, const int num_boxes, const int dim_pooled, 
				  const int dim,  vector<int> rsp_widths, vector<int> rsp_heights, 
				  vector<int> spm_bin_divs, const int max_level) 
{
	float* pooled_cache = (float*)malloc(dim_pooled * sizeof(float) ); //, 16);
	if (pooled_cache == NULL) 
	{
		mexErrMsgTxt("malloc error.");
	}
	
	const int dim_pack = dim / 4;
	if ( dim % 4 != 0 )
		mexErrMsgTxt("adaptive_region_pooling_mex: only support channel % 4 == 0");
	for (int i = 0; i < num_boxes; i ++)
	{
		const int best_feat    = feat_ids[i] - 1;
		const int feat_width   = rsp_widths[best_feat];
		const int feat_height  = rsp_heights[best_feat];
		const int feats_stride = feat_width * dim;

		memset((void*)pooled_cache, 0, sizeof(float) * dim_pooled);

		const int* box_norm_outer = boxes_norm_outer + i * 4;
		const int* box_norm_inner = boxes_norm_inner + i * 4;
		
		const int y0_inner = box_norm_inner[0] - 1;
		const int x0_inner = box_norm_inner[1] - 1;
		const int y1_inner = box_norm_inner[2] - 1;
		const int x1_inner = box_norm_inner[3] - 1;
		
		const int boxwidth  = box_norm_outer[3] - box_norm_outer[1] + 1;
		const int boxheight = box_norm_outer[2] - box_norm_outer[0] + 1;

		float* pooled_this_div_cache = pooled_cache;
		for (int lv = 0; lv < max_level; lv ++)
		{
			const float bin_divs = (float)spm_bin_divs[lv];
			for (int yy = 0; yy < bin_divs; yy ++)
			{ 
				const int y_start = std::min(feat_height, std::max(0, (int)floor(yy / bin_divs * boxheight)    + box_norm_outer[0] - 1));
				const int y_end   = std::min(feat_height, std::max(0, (int)ceil((yy+1) / bin_divs * boxheight) + box_norm_outer[0] - 1));
				for (int xx = 0; xx < bin_divs; xx ++)
				{
					const int x_start = std::min(feat_width, std::max(0, (int)floor(xx / bin_divs * boxwidth)      + box_norm_outer[1] - 1));
					const int x_end   = std::min(feat_width, std::max(0, (int)ceil((xx + 1) / bin_divs * boxwidth) + box_norm_outer[1] - 1));
					const float* feats_ptr = feats[best_feat] + y_start * feats_stride;
					for (int y = y_start; y < y_end; y ++)
					{
						//const float* feats_this = feats_ptr + x_start * dim;
						const __m128* feats_this_sse = (__m128*)(feats_ptr + x_start * dim);
						__m128* pooled_this_div_sse  = (__m128*)pooled_this_div_cache;

						for (int x = x_start; x < x_end; x ++, feats_this_sse += dim_pack)
						{
							if (!(x > x0_inner && x < x1_inner && y > y0_inner && y < y1_inner))
							{
								for (int d = 0; d < dim_pack; d ++)
								{
									pooled_this_div_sse[d] = _mm_max_ps(pooled_this_div_sse[d], feats_this_sse[d]);
								}
							}
						}
						feats_ptr += feats_stride;
					}//y
					pooled_this_div_cache += dim;
				}//xx
			}//yy
		}//lv

		{
			// trans from ([channel, width, height], num) to ([width, height, channel], num)
			float *pooled_this_box = pooled + i * dim_pooled;
			float *pooled_this_div = pooled_this_box, *pooled_this_div_cache = pooled_cache;
			for (int lv = 0; lv < max_level; lv ++)
			{
				const int bin_divs = spm_bin_divs[lv];
				for (int ii = 0; ii < bin_divs * bin_divs; ii ++)
				{
					for (int d = 0; d < dim; d ++)
					{
						pooled_this_div[(d * bin_divs * bin_divs + ii)] = pooled_this_div_cache[d];
					}
					pooled_this_div_cache += dim;
				}
				pooled_this_div += bin_divs * bin_divs * dim; 
			}//lv
		}
	}//i
	free(pooled_cache);
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	if (nrhs<5) {
	  mexPrintf("adaptive_region_pooling_mex: needs at least 4 input arguments!\n");
	  mexPrintf("adaptive_region_pooling_mex: compile date: %s %s\n", __DATE__ , __TIME__ );
	  return;
	}
	
	///// get input arguments
	if (!mxIsCell(prhs[0]))
		mexErrMsgTxt("feats must be in cell");

	int feats_num = (int)mxGetNumberOfElements(prhs[0]);
	if (feats_num <= 0)
		mexErrMsgTxt("feats num must > 0");

	vector<int> rsp_dims(feats_num);
	vector<int> rsp_widths(feats_num), rsp_heights(feats_num);
	vector<const float *> feats(feats_num);

	for (int i = 0; i < feats_num; ++i)
	{
		mxArray * mxFeats = mxGetCell(prhs[0], i);
		if (mxGetClassID(mxFeats) != mxSINGLE_CLASS)
			mexErrMsgTxt("feats must be single");
		feats[i] = ((const float*)mxGetData(mxFeats));

		const mwSize *feats_dim = mxGetDimensions(mxFeats);
		rsp_dims[i] = feats_dim[0];
		rsp_widths[i] = feats_dim[1];
		rsp_heights[i] = feats_dim[2];
	}

	int dim = rsp_dims[0];
	for (int i = 1; i < feats_num; ++i)
		if (rsp_dims[i] != dim)
			mexErrMsgTxt("currently only support feats with the same dim.\n");

    /// parse spm_divs
    const mxArray * mxDivs = prhs[1];
    int nDivM = (int)mxGetM(mxDivs);
    int nDivN = (int)mxGetN(mxDivs);
    if (std::min(nDivM, nDivN) != 1)
        mexErrMsgTxt("spm_divs must be a vetctor.\n");
    
    vector<int> spm_bin_divs(nDivM * nDivN);
    const double * pDivs = (const double*)mxGetPr(mxDivs);
    int max_level = nDivM * nDivN;
    int spm_divs = 0;
    for (int i = 0; i < nDivM * nDivN; i++)
    {
        spm_bin_divs[i] = (int)pDivs[i];
        spm_divs += (int)pDivs[i] * (int)pDivs[i];
    }

    /// parse outer boxes_in_cnn_input_images
	if (mxGetClassID(prhs[2]) != mxDOUBLE_CLASS)
		mexErrMsgTxt("boxes must be double");
	double* boxes_outer = mxGetPr(prhs[2]);
	int num_boxes = (int)mxGetN(prhs[2]);
	if (mxGetM(prhs[2]) != 4)
	{
		mexPrintf("outer boxes error.");
		return;
	}

    /// parse inner boxes_in_cnn_input_images 
	if (mxGetClassID(prhs[3]) != mxDOUBLE_CLASS)
		mexErrMsgTxt("boxes must be double");
	double* boxes_inner = mxGetPr(prhs[3]);
	int num_boxes_inner = (int)mxGetN(prhs[3]);
	if (mxGetM(prhs[3]) != 4)
	{
		mexPrintf("inner boxes error.");
		return;
	}
	if (num_boxes_inner!= num_boxes)
	{
		mexPrintf("Number of inner and outer boxes must agree");
		return;
	}
	
	if (mxGetClassID(prhs[4]) != mxINT32_CLASS)
		mexErrMsgTxt("feats_idxs must be int32");
	if (num_boxes != mxGetNumberOfElements(prhs[4]))
		mexErrMsgTxt("feats_idxs num must be the same boxes num.\n");
	const int *feat_ids = (const int*)mxGetPr(prhs[4]);
	
	if (mxGetClassID(prhs[5]) != mxDOUBLE_CLASS)
		mexErrMsgTxt("[offset0 offset min_times]  must be double");
	double offset0   = ((double *)mxGetData(prhs[5]))[0];
	double offset    = ((double *)mxGetData(prhs[5]))[1];
	double min_times = ((double *)mxGetData(prhs[5]))[2];

	///// normalize box
	int* boxes_norm_outer = new int[num_boxes * 4];
	int* boxes_norm_inner = new int[num_boxes * 4];
	for (int i = 0; i < num_boxes; i ++)
	{
		int best_feat = feat_ids[i] - 1;
		
		if(best_feat>=rsp_heights.size() ) {
		  mexPrintf("adaptive_region_pooling_mex: error: box %d: best_feat %d rsp_heights.size() %d\n", i, best_feat, rsp_heights.size() );
		  return;
		}
		
		double* box_outer   = boxes_outer      + i * 4;
		double* box_inner   = boxes_inner      + i * 4;
		int* box_norm_outer = boxes_norm_outer + i * 4;
		int* box_norm_inner = boxes_norm_inner + i * 4;
		
		normalizeBox(box_norm_outer, box_outer, offset0, offset, min_times, rsp_widths[best_feat], rsp_heights[best_feat]);
		normalizeBox(box_norm_inner, box_inner, offset0, offset, min_times, rsp_widths[best_feat], rsp_heights[best_feat]);
	}

	//////////////////////////////////////////////////////////////////////////

	///// normalize box
	const int dim_pooled = std::abs(spm_divs) * dim;
	plhs[0] = mxCreateNumericMatrix(dim_pooled, num_boxes, mxSINGLE_CLASS, mxREAL);
	float* pooled = (float*)mxGetData(plhs[0]);
	memset((void*)pooled, 0, sizeof(float) * num_boxes * dim_pooled);

	poolFeatures(pooled, boxes_norm_outer, boxes_norm_inner, feats, 
			feat_ids, num_boxes, dim_pooled, dim, rsp_widths, 
			rsp_heights, spm_bin_divs, max_level);

	delete[] boxes_norm_outer;
	delete[] boxes_norm_inner;
}

#ifdef MAINMEX
#include "mexstandalone.h"
#endif


