function [ T ] = otsurec(I, ttotal)
% OTSUREC Returns a set of thresholds for the input image using the multi-level
% otsu algorith.
%
%   OTSUREC computes a set T of thresholds from the input image I employing the
%   multi-level Otsu algorithm. The multi-level Otsu algorithm consists in 
%   finding the threshold that minimizes the input image intra-class variance.
%   Then, recursively, the Otsu algorithm is applied to each image region until
%   ttotal threholds are found.
%
if ~isempty(I)
    % Convert all N-D arrays into a single column.  Convert to uint8 for
    % fastest histogram computation.
    I = im2uint8(I(:));
    
    num_bins = 256;
    counts = imhist(I, num_bins);
    
    T = zeros(ttotal, 1);
    
    otsurec_helper(1, num_bins, 1, ttotal);
    
else
    T = [];    
end;
    
    function [] = otsurec_helper(lowerBin, upperBin, tLower, tUpper)
        if ((tUpper < tLower) || (lowerBin >= upperBin))
            return
        else
            level = otsu(counts(ceil(lowerBin) : ceil(upperBin))) + lowerBin;
            insertPos = ceil((tLower + tUpper) / 2);
            T(insertPos) = level / num_bins;
            otsurec_helper(lowerBin, level, tLower, insertPos - 1);
            otsurec_helper(level + 1, upperBin, insertPos + 1, tUpper);
        end
    end
end

function [ pos ] = otsu(counts)
    % Variables names are chosen to be similar to the formulas in
    % the Otsu paper.
    p = counts / sum(counts);
    omega = cumsum(p);
    mu = cumsum(p .* (1:numel(counts))');
    mu_t = mu(end);

    previous_state = warning('off', 'MATLAB:divideByZero');
    sigma_b_squared = (mu_t * omega - mu).^2 ./ (omega .* (1 - omega));
    warning(previous_state);

    % Find the location of the maximum value of sigma_b_squared.
    % The maximum may extend over several bins, so average together the
    % locations.  If maxval is NaN, meaning that sigma_b_squared is all NaN,
    % then return 0.
    maxval = max(sigma_b_squared);
    isfinite_maxval = isfinite(maxval);
    if isfinite_maxval
        pos = mean(find(sigma_b_squared == maxval));
    else
        pos = 0;
    end;
end
