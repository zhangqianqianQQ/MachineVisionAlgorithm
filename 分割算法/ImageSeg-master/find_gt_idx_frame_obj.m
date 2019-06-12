function indices = find_gt_idx_frame_obj(gt,frames,obj_ids)
% find row indices of gt matrix such that:
%    1. gt(row_index, 1) belongs to frames array
%    2. gt(row_index, 2) belongs to obj_ids array
    indices = [];
    for r = 1:size(gt,1)
        if belongs(gt(r,1),frames) && belongs(gt(r,2),obj_ids)
            indices = [indices r];
        end
    end
end