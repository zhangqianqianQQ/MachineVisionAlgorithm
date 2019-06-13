function [hypo_list,score_list, idx_list] = cluterHypo( hypo_list, score_list,...
    scale_ratio_list, elps_ab, nb_iter)

idx_list=1:length(score_list);
idx_list=idx_list(:);

if(isempty(scale_ratio_list))
    do_scale    = 0;
else
    do_scale    = 1;
    scale_ratio_list    = 1./(scale_ratio_list.*scale_ratio_list);
end



for iter = 1:nb_iter    
    [score_list, s_id]  = sort(score_list,'descend');
    hypo_list   = hypo_list(s_id,:);
    idx_list    = idx_list(s_id);
    nb_hypo = length(score_list);
    A   = hypo_list(:,1)*ones(1,nb_hypo);
    B   = hypo_list(:,2)*ones(1,nb_hypo);
    hypo_dx = A-A';
    hypo_dy = B-B';
    
    elps_dist= hypo_dx.*hypo_dx/(elps_ab(1)*elps_ab(1))+ hypo_dy.*hypo_dy/(elps_ab(2)*elps_ab(2));
    if(do_scale)
        elps_dist   = spmtimesd(sparse(elps_dist),scale_ratio_list,[]);
        elps_dist   = full(elps_dist);
    end
    hypo_cnt    = 0;
    hypo_nghb   = [];

    cluster_flag    = zeros(1, nb_hypo);
    

    for hypo=1:size(hypo_list,1)
        if(cluster_flag(hypo)==0)
            hypo_cnt    = hypo_cnt+1;
            nghb_idx    = find(elps_dist(hypo,:)<1 & cluster_flag==0 );
            hypo_nghb(hypo_cnt).nghb=nghb_idx;
            cluster_flag(nghb_idx)  = 1;
        end
    end

    max_ids = zeros(hypo_cnt,1);
    for hypo=1:hypo_cnt        
        weighted_score_list     = score_list(hypo_nghb(hypo).nghb);
        [unused,max_score_idx]  = max(weighted_score_list);
        max_ids(hypo)           = hypo_nghb(hypo).nghb(max_score_idx);

    end
    hypo_list   = hypo_list(max_ids,:);
    score_list  = score_list(max_ids);
    idx_list    = idx_list(max_ids);
    if(do_scale)
        scale_ratio_list= scale_ratio_list(max_ids);
    end
end
