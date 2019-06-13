function [edata, imdata] = drfiGetSameLabelFeat( imsegs, spdata, pbgdata, imdata )    
    imh = imdata.imh;
    imw = imdata.imw;
    
    % boundmap = imdata.boundmap;
    [boundmap perim] = mcmcGetSuperpixelBoundaries_fast( imsegs );
    
    boundx = cell(size(boundmap));
    boundy = cell(size(boundmap));
    
    for ix = 1 : numel(boundmap)
        [boundy{ix}, boundx{ix}] = ind2sub([imh, imw], boundmap{ix});        
%         boundy{ix} = mod(boundmap{ix}, imh) + 1;
%         boundx{ix} = ceil(boundmap{ix} / imh);
    end
   
    nadj = 0;
    for s1 = 1:imsegs.nseg
        nadj = nadj + numel(find(perim(s1, s1+1:end)>0));
    end
    
    adjlist = zeros(nadj, 2);
    c = 0;
    for s1 = 1:imsegs.nseg
        ns1 = numel(find(perim(s1, s1+1:end)>0));
        adjlist(c+1:c+ns1, 1) = s1;
        adjlist(c+1:c+ns1, 2) = s1 + find(perim(s1, s1+1:end)>0);
        c = c + ns1;
    end
    
    imdata.adjlist = adjlist;
    imdata.spstats = regionprops( imsegs.segimage, 'PixelIdxList' );
    
    % superpixel saliency
    sp_saliency = drfiGetRegionSaliencyFeature(imsegs, spdata, imdata, pbgdata);
    
%     texton_id = [29 58];
%     sp_saliency(:, texton_id) = [];
    
    saliency_dim = size(sp_saliency, 2);
    
    edata = zeros(nadj, 2 * saliency_dim + 29 + 7);
    
    for k = 1 : nadj
        s1 = adjlist(k, 1);
        s2 = adjlist(k, 2);
        
        % saliency for s1
        edata(k, 1:saliency_dim) = sp_saliency(s1, :);
        % saliency for s2
        edata(k, saliency_dim+(1:saliency_dim)) = sp_saliency(s2, :);
        
        dim = 2 * saliency_dim;
        % superpixel contrast
        edata(k, dim + 1) = abs( spdata.R(s1) - spdata.R(s2) );
        edata(k, dim + 2) = abs( spdata.G(s1) - spdata.G(s2) );
        edata(k, dim + 3) = abs( spdata.B(s1) - spdata.B(s2) );
        
        edata(k, dim + 4) = hist_dist( spdata.RGBHist(:,s1), spdata.RGBHist(:,s2), 'x2' );
        
        edata(k, dim + 5) = abs( spdata.L(s1) - spdata.L(s2) );
        edata(k, dim + 6) = abs( spdata.a(s1) - spdata.a(s2) );
        edata(k, dim + 7) = abs( spdata.b(s1) - spdata.b(s2) );
        
        edata(k, dim + 8) = hist_dist( spdata.LabHist(:,s1), spdata.LabHist(:,s2), 'x2' );
        
        edata(k, dim + 9) = abs( spdata.H(s1) - spdata.H(s2) );
        edata(k, dim + 10) = abs( spdata.S(s1) - spdata.S(s2) );
        edata(k, dim + 11) = abs( spdata.V(s1) - spdata.V(s2) );
        
        edata(k, dim + 12) = hist_dist( spdata.HSVHist(:,s1), spdata.HSVHist(:,s2), 'x2' );
        
        for ift = 1 : imdata.ntext
            edata(k, dim + 12 + ift) = abs( spdata.texture(ift, s1) - spdata.texture(ift, s2) );
        end
        
        edata(k, dim + 28) = hist_dist( spdata.textureHist(:,s1), spdata.textureHist(:,s2), 'x2' );
        
        edata(k, dim + 29) = hist_dist( spdata.lbpHist(:, s1), spdata.lbpHist(:,s2), 'x2' );
        
        % boundary geometry
        x = boundx{s1, s2} / imw;
        y = boundy{s1, s2} / imh;
        sx = sort(x);
        sy = sort(y);
        
        edata(k, dim+30) = mean(x);
        edata(k, dim+31) = mean(y);
        edata(k, dim+32) = sx(ceil(numel(sx)/10));
        edata(k, dim+33) = sx(ceil(9*numel(sx)/10));
        edata(k, dim+34) = sy(ceil(numel(sy)/10));
        edata(k, dim+35) = sy(ceil(9*numel(sy)/10));
        edata(k, dim+36) = length(x) / (imh + imw);
    end
end