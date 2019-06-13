function [hypo_list, score_list, bbox_list, scale_list, mask_heights_list]  = ...
    collect_hypo_across_scale(recog_result, ratio_list)

nb_scale    = length(recog_result);

hypo_list   = [];
score_list  = [];
bbox_list   = [];
scale_list  = [];
mask_heights_list   = [];

for scale_no=1:nb_scale        
    hypo_list1   = recog_result(scale_no).hypo_list;
    score_list1  = recog_result(scale_no).score_list;
    mask_heights1= recog_result(scale_no).mask_heights;
    hypo_bbox1   = recog_result(scale_no).hypo_bbox;
        
    nb_hypo     = length(score_list1);
    
    hypo_list       = [hypo_list;hypo_list1*ratio_list(scale_no)];
    score_list      = [score_list;score_list1];
    bbox_list       = [bbox_list; hypo_bbox1.*ratio_list(scale_no)];
    mask_heights_list= [mask_heights_list;mask_heights1*ratio_list(scale_no)];
    scale_list      = [scale_list;ones(nb_hypo,1)*scale_no];
end
