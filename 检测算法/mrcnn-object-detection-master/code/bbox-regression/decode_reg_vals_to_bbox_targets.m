function bbox_pred = decode_reg_vals_to_bbox_targets(bbox_init, reg_values)
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

bbox_pred   = zeros(size(reg_values), 'like', reg_values);
num_classes = size(bbox_pred,2) / 4;
for c = 1:num_classes
    reg_values_this              = reg_values(:,(c-1)*4 + (1:4));
    bbox_pred(:,(c-1)*4 + (1:4)) = decode_reg_values(bbox_init, reg_values_this);
end
end

function bbox_pred = decode_reg_values(bbox_init, reg_values)


dst_ctr_x = reg_values(:,1);
dst_ctr_y = reg_values(:,2);
dst_scl_x = reg_values(:,3);
dst_scl_y = reg_values(:,4);

src_w     = bbox_init(:,3) - bbox_init(:,1) + eps;
src_h     = bbox_init(:,4) - bbox_init(:,2) + eps;
src_ctr_x = bbox_init(:,1) + 0.5*src_w;
src_ctr_y = bbox_init(:,2) + 0.5*src_h;

pred_ctr_x = (dst_ctr_x .* src_w) + src_ctr_x;
pred_ctr_y = (dst_ctr_y .* src_h) + src_ctr_y;
pred_w     = exp(dst_scl_x) .* src_w;
pred_h     = exp(dst_scl_y) .* src_h;

bbox_pred = [pred_ctr_x - 0.5*pred_w, pred_ctr_y - 0.5*pred_h, ...
             pred_ctr_x + 0.5*pred_w, pred_ctr_y + 0.5*pred_h];
end
