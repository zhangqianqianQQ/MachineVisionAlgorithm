function display_hypo_rect_mask_wrapper(recog_result)


edge_map     = recog_result.edge;
vote_map    = recog_result.vote_map;
hypo_list   = recog_result.hypo_list;
score_list  = recog_result.score_list;
hypo_bbox   = recog_result.hypo_bbox;
voterec = recog_result.voterec;
valid_vote_idx= recog_result.valid_vote_idx;
testpos     = recog_result.testpos;
hypo_mask   = recog_result.hypo_mask;
display_hypo_rect_mask(edge_map, vote_map,...
    hypo_list,score_list,hypo_bbox,...
    voterec, valid_vote_idx, testpos,hypo_mask);
