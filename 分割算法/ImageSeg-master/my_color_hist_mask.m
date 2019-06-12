function c_hist = my_color_hist_mask(img, mask, mask_offset)
% img in format (H,W,3)
% mask in format (h,w)
% mask_offset in format (dh,dw)

    num_bins = 10;
    c_hist = zeros(num_bins,num_bins,num_bins);
    img = single(img)/256;

    dh = mask_offset(1);
    dw = mask_offset(2);
    
    for row = dh : (dh+size(mask,1)-1)
        for col = dw : (dw+size(mask,2)-1)
            val = img(row,col,:);
            hist_bin = floor(val*num_bins)+1;
            c_hist(hist_bin(1),hist_bin(2),hist_bin(3)) = c_hist(hist_bin(1),hist_bin(2),hist_bin(3)) + mask(row-dh+1,col-dw+1);
        end
    end
    
end