function labels = trimapGenerateMultipleSegmentations( image, imsegs )
    adjmat = imsegs.adjmat;
    segimage = imsegs.segimage;
    
    image_lab = rgb2lab( image );
    bins = [8 16 16];
    Q = computeQuantMatrix( image_lab, bins );
    region_hist = computeRegionHist(Q, bins, segimage);
    
    num_region = max(segimage(:));
    region_dist = zeros(num_region, num_region);
    
    ind = find(adjmat);
    for ix = 1 : length(ind)
        [x y] = ind2sub([num_region, num_region], ind(ix));
        region_dist(x, y) = histDist(region_hist(x,:), region_hist(y,:));
    end
    
    t = 0.2:0.05:0.8;
    labels = mexMergeAdjacentRegions(region_dist, t);
    
    for jx = 1 : size(labels, 2)
        L = labels(:, jx);
        temp_label = unique(L);
        for ix = 1 : length(temp_label)
            idx = find( L == temp_label(ix) );
            labels(idx, jx) = ix;
        end
    end
            