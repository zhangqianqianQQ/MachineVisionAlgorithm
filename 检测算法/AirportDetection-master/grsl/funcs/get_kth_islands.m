function [reg_kth_largest,num_regions] = get_kth_islands(img_b,k_th)
% extract the kth largest image island from a binary image, and 
% give the total number of islands in this binary image
    img_label = bwlabel(img_b);
    reg_size = regionprops(img_label,'Area');  
    reg = cat(1,reg_size.Area);
    num_regions = length(reg);
    if num_regions == 0
        error('cannot find any image island');
    end
    reg_sorted = sort(reg,'descend');
    ind = find(reg == reg_sorted(k_th));
    reg_kth_largest = ismember(img_label,ind);
end

