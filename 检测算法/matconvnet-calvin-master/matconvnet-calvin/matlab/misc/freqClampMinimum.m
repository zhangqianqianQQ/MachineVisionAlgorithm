function[freqs] = freqClampMinimum(freqs, minRatio)
% [freqs] = freqClampMinimum(freqs, minRatio)
%
% Takes absolute frequencies and clamps them such that the minimum ratio of
% a single freq. to the sum of all freqs. is minRatio.
%
% Copyright by Holger Caesar, 2015

% Early abort if there's nothing to do
if minRatio == 0 || isempty(minRatio),
    return;
end;

% Check inputs
assert(minRatio * numel(freqs) <= 1);

% Compute ratios
totalCount = sum(freqs);
ratios = freqs ./ totalCount;

% Renormalize entries that are higher than minRatio
valid = ratios >= minRatio;
if any(~valid),
    nomalizationFactor = (1 - minRatio * sum(~valid)) / sum(ratios(valid));
    ratios(valid) = ratios(valid) * nomalizationFactor;
    
    % Clamp entries that are smaller than minRatio
    ratios(~valid) = minRatio;
    
    % Go back to frequencies
    freqs = ratios * totalCount;
end;