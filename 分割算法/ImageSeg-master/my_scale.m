function scaled = my_scale(img, threshold)
    % threshold is a percentage (0~1) indicating the max % of elements as
    % threshold for scaling
    img_s = sort(img(:));
    thre_ind = ceil(length(img_s) * (1-threshold));
    thre_val = img_s(thre_ind);
    scaled = img / thre_val;
    
    if threshold == 0
        scaled = img / max(img(:));
    end
end