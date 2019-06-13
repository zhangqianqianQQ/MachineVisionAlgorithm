function [recog_result] = sc_vote_1_scale(edge_map,theta_map,codebook,para,verbose)

if(~exist('verbose','var'))
    verbose=0;
end

if(verbose);
    last_time=cputime;
end

para_sc = para{1};
para_fea= para{2};
para_vote=para{3};
voter_filter    = para_vote.voter_filter;

[imgh,imgw]     = size(edge_map);
testpos         = sample_grid_location([imgh,imgw], para_fea.sample_step);

if(para_sc.edge_bivalue)
    edge_map    = double(edge_map>para_sc.edge_thresh);
end

[fea,fea_sum]   = extract_sc_feature(edge_map, theta_map, testpos, para_sc);

fea_idx         = find(fea_sum>para_sc.sum_total_thresh);

if(length(fea_idx)<size(fea,1))
    if(verbose>1)
        disp(sprintf('corta %d cero tf ',size(fea,1)-length(fea_idx)));
    end
    fea     = feature_from_ind(fea,fea_idx);
    testpos = feature_from_ind(testpos,fea_idx);
end

if(verbose>1)
    now_time    = cputime;
    fprintf(1,'Sacando feats: %f\n', now_time-last_time);
    last_time   = now_time;
end

[scoresK, scoresK_id]   = compute_matching_scores_bestK(fea,codebook.codes, codebook.sc_weight,...
    para_fea.K, para_sc.sum_total_thresh, para_fea.mask_fcn);

if(verbose>1)
    now_time    = cputime;
    fprintf(1,'Ando buscando: %f\n', now_time-last_time);
    last_time   = now_time;
end

valid_vote_idx  = find(scoresK>para_vote.vote_thresh);

[candidate_pos] = get_candidate_pos(valid_vote_idx, scoresK_id, codebook.relpos, testpos);

[hypo_list, score_list, vote_map, winThreshold]	= get_hypo_center(candidate_pos, scoresK, ...
    [imgh,imgw], valid_vote_idx, para_vote.vote_offset, voter_filter);

[hypo_list, score_list] = clusterHypo(hypo_list, score_list, [], ...
    para_vote.elps_ab, para_vote.nb_iter);

[voterec,vh_idx] = trace_back_voterec(hypo_list, ...
    candidate_pos, para_vote.vote_disc_rad, para_vote.min_vote);

hypo_list   = hypo_list(vh_idx,:);
score_list  = score_list(vh_idx);

if(verbose>1)
    now_time    = cputime;
    fprintf(1,'Votando: %f\n', now_time-last_time);
    last_time   = now_time;
end

recog_result.edge       = edge_map;
recog_result.theta      = theta_map;
recog_result.imgsz      = [imgh,imgw];
recog_result.testpos    = testpos;
recog_result.features   = fea;
recog_result.scoresK    = scoresK;
recog_result.scoresK_id   = scoresK_id;
recog_result.candidate_pos= candidate_pos;
recog_result.voterec  = voterec;
recog_result.vote_map     = vote_map;
recog_result.hypo_list    = hypo_list;
recog_result.score_list   = score_list;
recog_result.valid_vote_idx = valid_vote_idx;
recog_result.win_thresh = winThreshold;
