% Compute saliency map using the Discriminative Regional Feature
% Integration approach.
function smap = drfiGetSaliencyMapSingleLevel( image, segment_saliency_regressor, sigma, k, min_size )
    % input
    % image       rgb image with type of uint8, can be got using imread
    % segment_saliency_regressor random forest regressor
    % sigma
    % k
    % min_size    parameters including the number of segmentations,
    %             saliency fusion weight, and saliency regressor
    
    % smap        saliency map with type of uint8
    
    
    % prepare data for feature generation
    imdata = drfiGetImageData( image );
    
    % data of the pesudo-background
    pbgdata = drfiGetPbgFeat( imdata );
    
    seg_para = [sigma, k, min_size];
    
    imsegs = im2superpixels( image, 'pedro', seg_para );
        
    % data of each superpixel
    spdata = drfiGetSuperpixelData( imdata, imsegs );

    % saliency feature of each segment (region)
    sp_sal_data = drfiGetRegionSaliencyFeature( imsegs, spdata, imdata, pbgdata );

    % run regression for each segment (region) using the random forest
    sp_sal_prob = regRF_predict( sp_sal_data, segment_saliency_regressor );

    % propagate saliency of segments (regions) to pixels
    smap = spSaliency2Pixels( sp_sal_prob, imsegs );

    smap = uint8(smap * 255);
end

function temp_smap = spSaliency2Pixels( sp_sal_prob, imsegs, enhance )
    if nargin < 3
        enhance = true;
    end
    
    % normalization
    sp_sal_prob = (sp_sal_prob - min(sp_sal_prob)) /...
        (max(sp_sal_prob) - min(sp_sal_prob) + eps);
    
    % enhance the difference between salient and background regions
    if enhance
        sp_sal_prob = exp( 1.25 * sp_sal_prob );
        sp_sal_prob = (sp_sal_prob - min(sp_sal_prob)) /...
            (max(sp_sal_prob) - min(sp_sal_prob) + eps);
    end
    
    % assign the saliency value of each segment to its contained pixels
    spstats = regionprops( imsegs.segimage, 'PixelIdxList' );
    temp_smap = zeros( size(imsegs.segimage) );
    for r = 1 : length(spstats)
        temp_smap( spstats(r).PixelIdxList ) = sp_sal_prob( r );
    end
end