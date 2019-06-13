function [fea,fea_sum]  = extract_sc_feature(edge_map,theta_map,testpos,para_sc)
[ey,ex] = find(edge_map>para_sc.edge_thresh);
eind    = sub2ind(size(edge_map), ey, ex);

ori     = theta_map(eind);
mag     = edge_map(eind);

fea     = compute_sc(testpos(:,1),testpos(:,2),...
    ex,ey,ori,mag,...
    para_sc.bin_r,para_sc.nb_bin_theta,para_sc.nb_ori,...
    para_sc.blur_r,para_sc.blur_t,para_sc.blur_o,para_sc.blur_method);

fea_sum = sum(fea,2);
