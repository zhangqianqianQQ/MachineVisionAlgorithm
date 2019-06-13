function reg_values = encode_bbox_targets_to_reg_vals(bbox_src, bbox_dst_all)
%
% The code in this file comes from the RCNN code: 
% https://github.com/rbgirshick/rcnn
%
% AUTORIGHTS
% ---------------------------------------------------------
% Copyright (c) 2014, Ross Girshick
% 
% This file is part of the R-CNN code and is available 
% under the terms of the Simplified BSD License provided in 
% LICENSE. Please retain this notice and LICENSE if you use 
% this file (or any portion of it) in your project.
% ---------------------------------------------------------

num_bbox    = size(bbox_src,1);
num_targets = size(bbox_dst_all,2);
reg_values  = zeros(num_bbox, num_targets, 'single');
num_classes = num_targets / 4;

src_w       = bbox_src(:,3) - bbox_src(:,1) + eps;
src_h       = bbox_src(:,4) - bbox_src(:,2) + eps;
src_ctr_x   = bbox_src(:,1) + 0.5*src_w;
src_ctr_y   = bbox_src(:,2) + 0.5*src_h;

for c = 1:num_classes
    
    bbox_dst    = bbox_dst_all(:, (c-1)*4 + (1:4));
    gt_w        = bbox_dst(:,3) - bbox_dst(:,1) + eps;
    gt_h        = bbox_dst(:,4) - bbox_dst(:,2) + eps;
    gt_ctr_x    = bbox_dst(:,1) + 0.5*gt_w;
    gt_ctr_y    = bbox_dst(:,2) + 0.5*gt_h;

    dst_ctr_x   = (gt_ctr_x - src_ctr_x) ./ src_w;
    dst_ctr_y   = (gt_ctr_y - src_ctr_y) ./ src_h;
    dst_scl_w   = log(gt_w ./ src_w);
    dst_scl_h   = log(gt_h ./ src_h);
    
    reg_values(:,(c-1)*4 + (1:4)) = [dst_ctr_x, dst_ctr_y, dst_scl_w, dst_scl_h];
end

end
