function [labels adjlist pE] = trimapGenerateMultipleSegmentations2( image, imsegs, edgeClassifier, ecal, t, size_array )
    adjmat = imsegs.adjmat;
    segimage = imsegs.segimage;
    
    spFeat = getSuperpixelData_ver2(image, imsegs);
    [edgeFeat adjlist] = getEdgeData_ver2( imsegs, spFeat );
%     spFeat = mcmcGetSuperpixelData( image, imsegs );
%     [edgeFeat adjlist] = mcmcGetEdgeData( imsegs, spFeat );
    pE=test_boosted_dt_mc(edgeClassifier,edgeFeat);
    pE = 1 ./ (1+exp(ecal(1)*pE+ecal(2)));
    
    nSuperpixel = max(segimage(:));
    % labels = mexMergeAdjacentRegions2( adjlist, pE, nSuperpixel, t );
    labels = mexMergeAdjRegs_Felzenszwalb( adjlist, pE, nSuperpixel, t, size_array );
    
%     image_lab = rgb2lab( image );
%     bins = [8 16 16];
%     Q = computeQuantMatrix( image_lab, bins );
%     region_hist = computeRegionHist(Q, bins, segimage);
%     
%     num_region = max(segimage(:));
%     region_dist = zeros(num_region, num_region);
%     
%     ind = find(adjmat);
%     for ix = 1 : length(ind)
%         [x y] = ind2sub([num_region, num_region], ind(ix));
%         region_dist(x, y) = histDist(region_hist(x,:), region_hist(y,:));
%     end
%     
%     t = 0.2:0.05:0.8;
%     labels = mexMergeAdjacentRegions(region_dist, t);
    
    for jx = 1 : size(labels, 2)
        L = labels(:, jx);
        temp_label = unique(L);
        for ix = 1 : length(temp_label)
            idx = find( L == temp_label(ix) );
            labels(idx, jx) = ix;
        end
    end
            