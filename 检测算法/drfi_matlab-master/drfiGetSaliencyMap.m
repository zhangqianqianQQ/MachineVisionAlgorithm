% Compute saliency map using the Discriminative Regional Feature
% Integration approach.
function smap = drfiGetSaliencyMap( image, para )
    % input
    % image       rgb image with type of uint8, can be got using imread
    % para        parameters including the number of segmentations,
    %             saliency fusion weight, and saliency regressor
    
    % smap        saliency map with type of uint8
    
    num_segmentation = para.num_segmentation;
    w = para.w;
    seg_para_mat = para.seg_para;
    segment_saliency_regressor = para.segment_saliency_regressor;
    
    [imh, imw, imc] = size( image );
    smap_mat = zeros(imh, imw, num_segmentation);
    
    % prepare data for feature generation
    imdata = drfiGetImageData( image );
    
    % data of the pesudo-background
    pbgdata = drfiGetPbgFeat( imdata );
    
    for p = 1 : num_segmentation
        % segmentation
        imsegs = im2superpixels( image, 'pedro', seg_para_mat(p, :) );
        
        % data of each superpixel
        spdata = drfiGetSuperpixelData( imdata, imsegs );
        
        % saliency feature of each segment (region)
        sp_sal_data = drfiGetRegionSaliencyFeature( imsegs, spdata, imdata, pbgdata );
        
        % run regression for each segment (region) using the random forest
        sp_sal_prob = regRF_predict( sp_sal_data, segment_saliency_regressor );
        
        % propagate saliency of segments (regions) to pixels
        smap_mat(:, :, p) = spSaliency2Pixels( sp_sal_prob, imsegs ) * w( p );
    end
    
    % multi-level saliency fusion
    smap = sum(smap_mat, 3);
    
    % normalization
    smap = (smap - min(smap(:))) / (max(smap(:)) - min(smap(:)) + eps) * 255;
    smap = uint8(smap);
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