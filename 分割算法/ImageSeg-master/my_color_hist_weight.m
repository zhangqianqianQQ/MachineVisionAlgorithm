function c_hist = my_color_hist_weight(img, weight)
% img in format (H,W,3)
% weight in format (H,W)

    num_bins = 10;
    c_hist = zeros(num_bins,num_bins,num_bins);
    img = single(img)/256;
    
    for row = 1:size(img,1)
        for col = 1:size(img,2)
            val = img(row,col,:);
            hist_bin = floor(val*num_bins)+1;
            c_hist(hist_bin(1),hist_bin(2),hist_bin(3)) = c_hist(hist_bin(1),hist_bin(2),hist_bin(3)) + weight(row,col);
        end
    end

%{
    weight = weight/max(weight(:));
    img(:,:,1) = floor(img(:,:,1) .* weight);
    img(:,:,2) = floor(img(:,:,2) .* weight);
    img(:,:,3) = floor(img(:,:,3) .* weight);
    r = histogram(img(:,:,1),100);
    g = histogram(img(:,:,2),100);
    b = histogram(img(:,:,3),100);
  %}  
end