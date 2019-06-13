function [voterec,vh_idx] = trace_back_voterec(hypo_list, ...
    candidate_pos, vote_disc_rad, min_vote)

voterec = []; 

hypo_cnt = size(hypo_list,1);

vh  = zeros(hypo_cnt,1);

hyd = 0;

for hypo=1:hypo_cnt
    dist2= sqrt((candidate_pos(:,1)-hypo_list(hypo,1)).^2 + (candidate_pos(:,2)-hypo_list(hypo,2)).^2);
    [hypo_offset,match_id]  = sort(dist2,'ascend');
    voter_id = find(hypo_offset<=vote_disc_rad);
    

    if(length(voter_id)>=min_vote)
        hyd = hyd + 1;
        voterec(hyd).voter_id   = match_id(voter_id);
        vh(hypo)=1;
    end
end

vh_idx  = find(vh);
