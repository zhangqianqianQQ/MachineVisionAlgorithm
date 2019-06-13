function [hypo_list,score_list, vote_map, winThreshold] =...
    get_hypo_center(candidate_pos,match_scoreK,imgsz,valid_match_idx,...
    vote_offset,vote_filter)


vote_offset  = round(vote_offset);
sx  = vote_offset;
sy  = vote_offset;

candidate_pos_x = candidate_pos(:,1)+sx;
candidate_pos_y = candidate_pos(:,2)+sy;

nb_scale    = length(vote_filter);

density_map     = zeros(imgsz(1),imgsz(2));
vote_map        = zeros(imgsz(1),imgsz(2));

density_map1  = sparse(candidate_pos_y,candidate_pos_x,...
    match_scoreK(valid_match_idx),...
    imgsz(1)+2*vote_offset,imgsz(2)+2*vote_offset);
VR = full(density_map1);
VR = conv2(VR,vote_filter,'same');
density_map = density_map1(sy+1:sy+imgsz(1),sx+1:sx+imgsz(2));
vote_map	= VR(sy+1:sy+imgsz(1),sx+1:sx+imgsz(2));

[hypo_list, score_list, winThreshold] = get_hypo_from_votemap(vote_map);
