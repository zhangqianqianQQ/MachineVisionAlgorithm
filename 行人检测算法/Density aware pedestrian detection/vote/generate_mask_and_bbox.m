function [recog_result_new] =generate_mask_and_bbox(recog_result, codebook,...
    max_score_thresh,para_vote, verbose)

if(~exist('verbose','var') || isempty(verbose))
    verbose = 0;
end 
nb_scale    = length(recog_result);
recog_result_new    = [];
for scale_no=1:nb_scale
    recog_res   = generate_mask_and_bbox_1_scale(recog_result(scale_no), codebook, para_vote, max_score_thresh);
    mask_heights    = recog_res.mask_heights;
    vh_idx  = find(mask_heights>para_vote.min_height & mask_heights<para_vote.max_height);
    recog_res.hypo_list = recog_res.hypo_list(vh_idx,:);
    recog_res.score_list= recog_res.score_list(vh_idx);
    recog_res.voterec= recog_res.voterec(vh_idx);
    recog_res.hypo_mask = recog_res.hypo_mask(:,:,vh_idx);
    recog_res.mask_heights= recog_res.mask_heights(vh_idx);
    recog_res.hypo_bbox = recog_res.hypo_bbox(vh_idx,:);
    recog_result_new= [recog_result_new,recog_res];
    if(verbose>3)
        display_hypo_rect_mask_wrapper( recog_res );
    end    
end
