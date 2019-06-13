function [hypo_list, score_list, bbox_list, recog_result] = ...
    sc_detector_on_edge(I_edge,codebook,para,verbose)


para_sc = para{1};
para_fea= para{2};
para_vote=para{3};

voter_filter    = para_vote.voter_filter;

win_thresh  = [];
recog_result= [];

img = I_edge(1).edge;

nb_scale    = length(I_edge);
ratio       = para_fea.ratio;
if(verbose);
    begin_time  = cputime;
    last_time   = begin_time;
end

for scale_no=1:nb_scale
    if(verbose>1)
        fprintf(1,'===========looking for humans at scale %d==========\n',scale_no);
    end
    edge_map     = I_edge(scale_no).edge;
    theta_map    = I_edge(scale_no).theta;
    recog_res	= sc_vote_1_scale(edge_map, theta_map, codebook, para, verbose);
    recog_result= [recog_result,recog_res];
    win_thresh  = [win_thresh; recog_res.win_thresh];
end

if(ratio>1)
    ratio=1/ratio;
end

max_score_thresh  =   max(win_thresh);
ratio_list  = ratio.^(0:nb_scale-1);
ratio_list  = 1./ratio_list;

recog_result    = generate_mask_and_bbox(recog_result, codebook, ...
    max_score_thresh,para_vote, verbose);

[hypo_list, score_list, bbox_list]  = ...
    collect_hypo_across_scale(recog_result, ratio_list);
if(verbose>3)
    [hypo_list, score_list, bbox_list, scale_list, mask_heights_list]  = ...
        collect_hypo_across_scale(recog_result, ratio_list);
    display_hypo_rect(img, [], hypo_list, score_list, bbox_list);
    set(gcf,'name','voting results');
end

if(verbose>1)
    now_time    = cputime;
    fprintf(1,'Votos totales: %f\n', now_time-last_time);
    last_time   = now_time;
end

recog_result    = compute_unique_vote_score(recog_result, para_fea, verbose);

[hypo_list, score_list, bbox_list, scale_list, mask_heights_list]  = ...
    collect_hypo_across_scale(recog_result, ratio_list);

if(verbose>3)
    display_hypo_rect(img, [], hypo_list, score_list, bbox_list);
    set(gcf,'name','hypothesis with score from unique vote');
end

vh_idx  = prune_by_hypo_cluster(hypo_list,score_list, scale_list,...
    ratio_list, para_vote);

hypo_list       = hypo_list(vh_idx,:);
score_list      = score_list(vh_idx);
bbox_list       = bbox_list(vh_idx,:);
mask_heights_list= mask_heights_list(vh_idx,:);
scale_list      = scale_list(vh_idx);

if(verbose>3)
    display_hypo_rect(img, [], hypo_list, score_list, bbox_list);
end

vh_idx  = prune_by_area_overlapping(bbox_list,score_list);
hypo_list       = hypo_list(vh_idx,:);
score_list      = score_list(vh_idx);
bbox_list       = bbox_list(vh_idx,:);
mask_heights_list= mask_heights_list(vh_idx,:);
scale_list      = scale_list(vh_idx);

if(verbose>2)
    display_hypo_rect(img, [], hypo_list, score_list, bbox_list);
end

if(verbose>1)
    now_time    = cputime;
    fprintf(1,'Corto simple: %f\n', now_time-last_time);
    last_time   = now_time;
end


if(verbose)
    end_time    = cputime;
    fprintf(1,'TT: %f\n', end_time - begin_time);
end
