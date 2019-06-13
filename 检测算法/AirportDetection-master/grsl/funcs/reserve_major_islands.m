function major_islands = reserve_major_islands(smap_b)
    [row,col] = size(smap_b);
    img_label = bwlabel(smap_b);
    reg_size = regionprops(img_label,'Area');  
    reg = cat(1,reg_size.Area);
    reg_sorted = sort(reg,'descend');
    % side = sqrt(row*col);
    % th_smallest = (side*0.01)^2;
    % n = max(find(reg_sorted>th_smallest));
    n = 1;
    major_islands = zeros(row,col);
    for k_th = 1 : n
        label = find(reg==reg_sorted(k_th));
        major_islands = major_islands + ismember(img_label,label);    
    end
end

