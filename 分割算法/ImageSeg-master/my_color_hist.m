function c_hist = my_color_hist(img)
% my_color_hist
%img values within [0,256)
    
    num_bins = 10;
    c_hist = zeros(num_bins,num_bins,num_bins);
    img = single(img)/256;
    
    for row = 1:size(img,1)
        for col = 1:size(img,2)
            val = img(row,col,:);
            hist_bin = floor(val*num_bins)+1;
            c_hist(hist_bin(1),hist_bin(2),hist_bin(3)) = c_hist(hist_bin(1),hist_bin(2),hist_bin(3)) + 1;
        end
    end

end