function ori_edge = edge_splitting(ori,blur_o,nb_ori)


if(~exist('nb_ori','var'))
    nb_ori = 4;
end
if(~exist('blur_o','var'))
    blur_o = 0.2;
end

nb_ori = 4;

edge_ori = mod(ori,pi);

edge_ori_unit   = pi/nb_ori;

edge_ori_blur_part   = edge_ori_unit*blur_o;

edge_ori_bins=(0:nb_ori)*(edge_ori_unit);

edge_ori_bins   = edge_ori_bins - 0.5*edge_ori_unit;
 
edge_ori_idx    = find(edge_ori<(edge_ori_bins(2)+edge_ori_blur_part)...
    | (edge_ori>edge_ori_bins(end)-edge_ori_blur_part));

ori_id=1;
ori_edge(ori_id).idx = edge_ori_idx;

for ori_id=2:nb_ori    
    edge_ori_idx = find(edge_ori>(edge_ori_bins(ori_id)-edge_ori_blur_part)...
        & edge_ori<(edge_ori_bins(ori_id+1)+edge_ori_blur_part));
    
    ori_edge(ori_id).idx = edge_ori_idx;
end
