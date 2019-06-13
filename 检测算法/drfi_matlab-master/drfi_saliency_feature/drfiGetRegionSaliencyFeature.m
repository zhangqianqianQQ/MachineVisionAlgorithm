function feat = drfiGetRegionSaliencyFeature( imsegs, spdata, imdata, pbgdata )    
    % hopefully, this will be much faster than the version of cvpr 2013
    nseg = imsegs.nseg;
    
    iDim = 29 * 2 + 35;
    feat = zeros( nseg, iDim );
        
    spstats = regionprops( imsegs.segimage, 'Centroid', 'PixelIdxList', 'Area', 'Perimeter' );
    
    adjmat = double( imsegs.adjmat ) .* (1 - eye(nseg, nseg));
    
    r = double( imdata.image_rgb(:,:,1) );
    g = double( imdata.image_rgb(:,:,2) );
    b = double( imdata.image_rgb(:,:,3) );
    L = imdata.image_lab(:,:,1);
    a = imdata.image_lab(:,:,2);
    bb = imdata.image_lab(:,:,3);
    h = imdata.image_hsv(:,:,1);
    s = imdata.image_hsv(:,:,2);
    v = imdata.image_hsv(:,:,3);
    
    [imh imw] = size(r);
    
    position = zeros(nseg, 2);
    area = zeros(1, nseg);
    
    for ix = 1 : length(spstats)                   
        position(ix, :) = (spstats(ix).Centroid);
        area(ix) = spstats(ix).Area;
    end
    position = position / max(imh, imw);
    
    area_weight = repmat(area, [nseg, 1]) .* adjmat;
    adj_area = sum(area_weight);
    area_weight = area_weight ./ repmat(sum(area_weight, 2) + eps, [1, nseg]);
    
    sp = 1 / 0.4;%0.5 / ( 0.25 * 0.25 );
    dp = mexFeatureDistance( position', [], 'L2' );
    dist_weight = exp( -sp * dp );
    
    feat_dist_mat = zeros(nseg, nseg, 29);
    
    % mean R, G, B distance, and x2 distance of RGB histogram
    feat_dist_mat(:,:,1) = mexFeatureDistance(spdata.R, [], 'L1');
    feat_dist_mat(:,:,2) = mexFeatureDistance(spdata.G, [], 'L1');
    feat_dist_mat(:,:,3) = mexFeatureDistance(spdata.B, [], 'L1');
    feat_dist_mat(:,:,4) = mexFeatureDistance(spdata.RGBHist, [], 'x2');    
    
    % mean L, a, b distance, and x2 distance of Lab histogram
    feat_dist_mat(:,:,5) = mexFeatureDistance(spdata.L, [], 'L1');
    feat_dist_mat(:,:,6) = mexFeatureDistance(spdata.a, [], 'L1');
    feat_dist_mat(:,:,7) = mexFeatureDistance(spdata.b, [], 'L1');    
    feat_dist_mat(:,:,8) = mexFeatureDistance(spdata.LabHist, [], 'x2');
    
    % mean H, S, V distance, and x2 distance of HSV histogram
    feat_dist_mat(:,:,9) = mexFeatureDistance(spdata.H, [], 'L1');
    feat_dist_mat(:,:,10) = mexFeatureDistance(spdata.S, [], 'L1');
    feat_dist_mat(:,:,11) = mexFeatureDistance(spdata.V, [], 'L1');    
    feat_dist_mat(:,:,12) = mexFeatureDistance(spdata.HSVHist, [], 'x2');
    
    for ix = 1 : imdata.ntext
        feat_dist_mat(:,:,12+ix) = mexFeatureDistance(spdata.texture(ix,:), [], 'L1');
    end
    
    feat_dist_mat(:,:,28) = mexFeatureDistance(spdata.textureHist, [], 'x2');
    
    feat_dist_mat(:,:,29) = mexFeatureDistance(spdata.lbpHist, [], 'x2');
    
    % regional contrast
    for ix = 1 : 29
        % feat(:, ix) = sum(feat_dist_mat(:,:,ix) .* area_weight, 2);
        feat(:, ix) = sum(feat_dist_mat(:,:,ix) .* dist_weight, 2) ./ (sum(dist_weight, 2) + eps);
    end
    
    % regional backgroundness
    dim = 29;
    feat(:, dim + 1) = abs( spdata.R - pbgdata.R );
    feat(:, dim + 2) = abs( spdata.G - pbgdata.G );
    feat(:, dim + 3) = abs( spdata.B - pbgdata.B );
    
    feat(:, dim + 4) = hist_dist( spdata.RGBHist, repmat(pbgdata.RGBHist, [1 nseg]), 'x2' );
    
    feat(:, dim + 5) = abs( spdata.L - pbgdata.L );
    feat(:, dim + 6) = abs( spdata.a - pbgdata.a );
    feat(:, dim + 7) = abs( spdata.b - pbgdata.b );
    
    feat(:, dim + 8) = hist_dist( spdata.LabHist, repmat(pbgdata.LabHist, [1 nseg]), 'x2' );
    
    feat(:, dim + 9) = abs( spdata.H - pbgdata.H );
    feat(:, dim + 10) = abs( spdata.S - pbgdata.S );
    feat(:, dim + 11) = abs( spdata.V - pbgdata.V );
    
    feat(:, dim + 12) = hist_dist( spdata.HSVHist, repmat(pbgdata.HSVHist, [1 nseg]), 'x2' );
    
    for ift = 1 : imdata.ntext
        feat(:, dim + 12 + ift) = abs( spdata.texture(ift, :) - pbgdata.texture(ift) );
    end
    
    feat(:, dim + 28) = hist_dist( spdata.textureHist, repmat(pbgdata.textureHist, [1 nseg]), 'x2' );
    
    feat(:, dim + 29) = hist_dist( spdata.lbpHist, repmat(pbgdata.lbpHist, [1 nseg]), 'x2' );
    
    ii = 29 * 2;
    
    % regional property
    for reg = 1 : nseg
        pixels = spstats(reg).PixelIdxList;
        
        xvals = imdata.xim( pixels );
        yvals = imdata.yim( pixels );
        
        sx = sort( xvals );
        sy = sort( yvals );
        
        LEFT = sx( ceil(numel(sx)/10) );
        TOP = sy( ceil(numel(sy)/10) );
        RIGHT = sx( ceil(numel(sx)/10*9) );
        BOTTOM = sy( ceil(numel(sy)/10*9) );
        
        ix = ii;
        feat(reg, ix+1) = mean( xvals );
        feat(reg, ix+2) = mean( yvals );
        
        feat(reg, ix+3) = LEFT;
        feat(reg, ix+4) = TOP;
        feat(reg, ix+5) = RIGHT;
        feat(reg, ix+6) = BOTTOM;
        
        feat(reg, ix+7) = spstats(reg).Perimeter / (imw + imh);                  
        
        feat(reg, ix+8) = (RIGHT - LEFT) / (BOTTOM - TOP + eps);  % aspect ratio
        
        feat(reg, ix+8+(1:3)) = [var( r(pixels) ), var( g(pixels) ), var( b(pixels) )];
        feat(reg, ix+11+(1:3)) = [var( L(pixels) ), var( a(pixels) ), var( bb(pixels) )];
        feat(reg, ix+14+(1:3)) = [var( h(pixels) ), var( s(pixels) ), var( v(pixels) )];
        
        for it = 1 : imdata.ntext
            temp_text = imdata.imtext(:,:,it);
            feat(reg, ix+17+it) = var( temp_text(pixels) );
        end
        
        feat(reg, ix+33) = var( imdata.imlbp(pixels) );
        
        feat(reg, ix+34) = length(pixels) / imdata.imh / imdata.imw;       % area
        
        feat(reg, ix+35) = adj_area(reg) / imdata.imh / imdata.imw; % area of neighbor
    end
end