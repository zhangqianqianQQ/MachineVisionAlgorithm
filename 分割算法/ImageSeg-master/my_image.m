function nonret = my_image(img, threshold)
    % threshold is a percentage (0~1) indicating the max % of elements as
    % threshold for scaling
    if length(size(img)) == 3
        img = sum(img, 3);
    end
    img_s = sort(img(:));
    thre_ind = floor(length(img_s) * (1-threshold));
    thre_val = img_s(thre_ind);
    img = img / thre_val;
    image(img,'CDataMapping','scale');
    %colorbar;
end