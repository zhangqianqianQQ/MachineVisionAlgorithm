function codebook = proc_codebook_oneimage_circlebin(pb_edge,pb_theta,obj_mask,sc_mask,para_sc)


codebook    = [];
[imgh,imgw] = size(pb_edge);

mask_center = get_mask_center(obj_mask);
location	= sample_location_in_mask(obj_mask,para_sc.codebook_sample_step);

[fea,fea_sum]   = extract_sc_feature(pb_edge, pb_theta, location, para_sc);



codes_idx	= find(fea_sum > para_sc.sum_total_thresh);
if(length(codes_idx)<size(fea,1))
    fprintf(1,'corta %d codes\n',size(fea,1)-length(codes_idx));
    location= location(codes_idx,:);
    fea     = feature_from_ind(fea,codes_idx);
    fea_sum = feature_from_ind(fea_sum,codes_idx);
end

if(isempty(fea))
    return;
end

fea	= spmtimesd(sparse(fea),1./fea_sum,[]);
fea = full(fea);

codebook.location   = location;
codebook.relpos     = [mask_center(1)-location(:,1),mask_center(2)-location(:,2)];
codebook.codes      = fea;
codebook.sc_sum     = fea_sum;

feature_weight      = extract_weight_from_mask(obj_mask,sc_mask,1);
loc_ind             = sub2ind([imgh,imgw],location(:,2),location(:,1));
s_weight            = feature_from_ind(feature_weight,loc_ind);
codebook.sc_weight  = repmat(s_weight,1, para_sc.nb_ori);

