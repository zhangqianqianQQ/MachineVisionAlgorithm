function recog_result=generate_mask_and_bbox_1_scale(recog_result,codebook,...
    para_vote, max_score_thresh)


if(~exist('max_score_thresh', 'var'))
    max_score_thresh    = eps;
end
hypo_list   = recog_result.hypo_list;
score_list  = recog_result.score_list;
voterec = recog_result.voterec;

vh_idx  = find(score_list>max_score_thresh);

hypo_list   = hypo_list(vh_idx,:);
score_list  = score_list(vh_idx);
voterec = voterec(vh_idx);

scoresK     = recog_result.scoresK;
scoresK_id  = recog_result.scoresK_id;
testpos     = recog_result.testpos;
imgsz       = recog_result.imgsz;
valid_vote_idx=recog_result.valid_vote_idx;

[hypo_mask] = generate_voter_mask(voterec,scoresK,scoresK_id,...
    testpos, codebook, valid_vote_idx, imgsz, para_vote.maskRadius);

nb_hypo     = length(score_list);

hypo_bbox   = zeros(nb_hypo,4);
mask_heights= zeros(nb_hypo,1);

for hypo=1:nb_hypo
    tmpMask     = hypo_mask(:,:,hypo);
    oI_Hypo     = tmpMask>1.5*mean(tmpMask(:));
    hypo_mask(:,:,hypo) = tmpMask.*oI_Hypo;
    [ii,jj]     = find(oI_Hypo);
    min_x       = min(jj);    max_x       = max(jj);
    min_y       = min(ii);    max_y       = max(ii);
    mask_heights(hypo)= max_y - min_y;
    mdx         = max(abs(hypo_list(hypo,1)-min_x),abs(max_x-hypo_list(hypo,1)));
    mdy         = max(abs(hypo_list(hypo,2)-min_y),abs(max_y-hypo_list(hypo,2)));
    left_top    = max([hypo_list(hypo,:)-[mdx,mdy];[1,1]]);
    right_bottom= min([hypo_list(hypo,:)+[mdx,mdy];[imgsz(2),imgsz(1)]]);
    hypo_bbox(hypo,:)   = [left_top(1),left_top(2),right_bottom(1),right_bottom(2)];
end

recog_result.hypo_list    = hypo_list;
recog_result.score_list   = score_list;
recog_result.voterec  = voterec;
recog_result.hypo_mask    = hypo_mask;
recog_result.hypo_bbox    = hypo_bbox;
recog_result.mask_heights = mask_heights;

