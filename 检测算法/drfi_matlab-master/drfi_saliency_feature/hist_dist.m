function diff = hist_dist( hist1, hist2, method )
    switch method
        case 'x2'
            % diff = 0.5 * sum((hist1 - hist2).^2) ./ sum(hist1 + hist2 + eps);
            diff = 0.5 * sum( (hist1 - hist2).^2 ./ (hist1 + hist2 + eps) );
        case 'jsd'      % Jensen-Shannon Divergence
            diff = 0.5*(sum(hist1.*log((hist1+eps)./(hist2+eps))) + sum(hist2.*log((hist2+eps)./(hist1+eps))));
        otherwise
            error( 'unknown type for computing histogram distance' );
    end
end