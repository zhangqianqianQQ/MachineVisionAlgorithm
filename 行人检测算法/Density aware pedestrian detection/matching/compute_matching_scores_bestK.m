function [scoresK,scoresK_id] = compute_matching_scores_bestK(fea,codes,...
    codes_weight, K, sc_threshold, mask_fcn)


if(~exist('mask_fcn','var'))
    mask_fcn=1;
end

if(mask_fcn)
    [scoresK,scoresK_id] = mex_compute_mscores_K_chi2(fea,codes,codes_weight,K,sc_threshold);
else
    fea_sum = sum(fea,2);
    fea	= spmtimesd(sparse(fea),1./fea_sum,[]);
    fea = full(fea);
    [scoresK,scoresK_id] = hist_cost_chi2(fea,codes,K);
end

