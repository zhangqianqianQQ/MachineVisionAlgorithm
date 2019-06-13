function regionHist = computeRegionHist(Q, bins, segimage)
    num_region = max(segimage(:));
    
    num_bin = bins(1)*bins(2)*bins(3);
    
    regionHist = zeros(num_region, num_bin);
    
    spstats = regionprops(segimage, 'PixelIdxList');
    
    for ix = 1 : num_region
        pixel_ind = spstats(ix).PixelIdxList;
        bin_ind = sort(Q(pixel_ind));
        [v m n] = unique(bin_ind);
        mm = [0; m(1:end-1)];
        freq = m - mm;
        regionHist(ix,v) = regionHist(ix,v) + freq';
    end
    