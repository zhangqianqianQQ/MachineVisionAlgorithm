function recog_result   = compute_unique_vote_score(recog_result, para_fea, verbose)

if(~exist('verbose','var'))
    verbose=0;
end
nb_scale    = length(recog_result);

for scale_no=1:nb_scale
    recog_result(scale_no)  = compute_unique_vote_score_1_scale(...
        recog_result(scale_no), para_fea);
    if(verbose>2)
        display_hypo_rect_mask_wrapper( recog_result(scale_no));        
    end
end

