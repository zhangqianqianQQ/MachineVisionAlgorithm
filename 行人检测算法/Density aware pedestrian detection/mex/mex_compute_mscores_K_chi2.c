/*================================================================
* function [scoresK,scoresK_id] = mex_compute_mscores_K(fea,codebook,codeweight,K,sc_threshold)
 * Input:
 *  fea              = [#nb_feature,#nb_bin],    Shape Context Feature in test image
 *  codebook         = [#nb_code,#nb_bin],       Shape Context Feature in codebook
 *  codeweight       = [#nb_code,#nb_bin],       weight for each codebook entry
 *  K                = [1,1],                    Best K matches
 *  sc_threshold     = [1,1],                	threshold to prune zeros shape context bins
 *
 * Output:
 *  scoresK          = [K,#nb_feature]           Best K matches for test features, need transpose after call
 *  scoresK_id       = [K,#nb_feature]           Indices to codebook for best K matches, need transpose after call
 *
 *
 * Liming Wang, Jan 2008
 *
*=================================================================*/

# include "mex.h"
# include "math.h"

void mexFunction(
				 int nargout,
				 mxArray *out[],
				 int nargin,
				 const mxArray *in[]
				 )
{
    const double eps =mxGetEps();
    const double MAX_DIS= 1.0;
    /* declare variables */    
    int nb_feature,nb_code,nb_bin;
    double *test_feature,*codebook,*codeweight,*pK,*sc_threshold;
    int K;
    double *scoresAll,*weight_feature;
    int *scoresAll_id;
    double *scoresK;
    int *scoresK_id;
    int ff,cc,bb,oo,flt,kk,jj;
    double weight_sum_row,weight_sum,Chi2Dis;
    
    double double_dummy1,double_dummy2,double_dummy3;
    int int_dummy1,int_dummy2;
    
    	
    
    /* check argument */
    if (nargin<5) {
        mexErrMsgTxt("5 input arguments required");
    }
    if (nargout>2) {
        mexErrMsgTxt("2 many output arguments");
    }
    nb_feature  = mxGetM(in[0]);
    nb_code     = mxGetM(in[1]);
    nb_bin      = mxGetN(in[0]);
    
    test_feature= mxGetPr(in[0]);
    codebook    = mxGetPr(in[1]);
    codeweight  = mxGetPr(in[2]);
    pK          = mxGetPr(in[3]);
    sc_threshold= mxGetPr(in[4]);
    
    K           = (int)pK[0];
    
    if ( nb_bin !=mxGetN(in[1]) || nb_code!=mxGetM(in[2]) || nb_bin!= mxGetN(in[2])) {
        mexErrMsgTxt("Dimension mismatch!!");
    }
    
    scoresAll       = (double*)mxCalloc(nb_code,sizeof(double));
    scoresAll_id    = (int*)mxCalloc(nb_code,sizeof(int));
    weight_feature  = (double*)mxCalloc(nb_bin,sizeof(double));
    
    if(scoresAll==NULL||scoresAll_id==NULL||weight_feature==NULL){
        mexErrMsgTxt("Not enough space to compute scores matrix\n");
    }
    if(nb_code<K)
        K=nb_code;
    
    out[0]      = mxCreateDoubleMatrix(nb_feature,K,mxREAL);
    out[1]      = mxCreateNumericMatrix(nb_feature,K,mxINT32_CLASS,mxREAL);
    if (out[0]==NULL || out[1]==NULL) {       
        
        mexErrMsgTxt("Not enough space for the output matrix");
    }
    scoresK     = mxGetPr(out[0]);
    scoresK_id  = (int*)mxGetPr(out[1]);
    
    /* compute score matrix here */
    for(ff=0;ff<nb_feature;ff++){
        for(cc=0;cc<nb_code;cc++){
            Chi2Dis   = 0.0;
            weight_sum_row  = 0;
            for(bb=0;bb<nb_bin;bb++){
                weight_feature[bb] = test_feature[bb*nb_feature+ff]*codeweight[bb*nb_code+cc];
                weight_sum_row  += weight_feature[bb];				
            }
			if(weight_sum_row<sc_threshold[0])
                Chi2Dis=MAX_DIS;
            else{
                for(bb=0;bb<nb_bin;bb++){                                    
                    double_dummy1   = codebook[bb*nb_code+cc];
                    double_dummy2   = weight_feature[bb]/weight_sum_row;
                    double_dummy3=(double_dummy1-double_dummy2);
                    Chi2Dis+=double_dummy3*double_dummy3/(double_dummy1+double_dummy2+eps);                
                }
                Chi2Dis   = 0.5*Chi2Dis;
            }
            scoresAll[cc]=Chi2Dis;
            scoresAll_id[cc]=cc+1;            
        }
        /* sort the score matrix and take the first smallest K column out */
        
        for(kk=0;kk<K;kk++){
            int_dummy1=kk;
            for(jj=kk+1;jj<nb_code;jj++){
                if(scoresAll[jj]<scoresAll[int_dummy1]){
                    int_dummy1=jj;
                }
            }            
            if(int_dummy1!=kk){
                scoresK[kk*nb_feature+ff]      = 1-scoresAll[int_dummy1];
                scoresK_id[kk*nb_feature+ff]   = scoresAll_id[int_dummy1];
                scoresAll[int_dummy1]   = scoresAll[kk];
                scoresAll_id[int_dummy1]= scoresAll_id[kk];
            }else{
                scoresK[kk*nb_feature+ff]      = 1-scoresAll[kk];
                scoresK_id[kk*nb_feature+ff]   = scoresAll_id[kk];
            }
        }
    }
}

