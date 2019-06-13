function[scoresSP, mapSP] = regionToPixel_forward(scoresAll, overlapListAll)
% [scoresSP, mapSP] = regionToPixel_forward(scoresAll, overlapListAll)
%
% Go from a region level to a pixel level.
% (to be able to compute a loss there)
%
% Copyright by Holger Caesar, 2015

% Move to CPU
gpuMode = isa(scoresAll, 'gpuArray');
if gpuMode
    scoresAll = gather(scoresAll);
end

% Check inputs
assert(~any(isnan(scoresAll(:)) | isinf(scoresAll(:))));

% Reshape scores
scoresAll = reshape(scoresAll, [size(scoresAll, 3), size(scoresAll, 4)]);

% Init
labelCount = size(scoresAll, 1);
spCount = size(overlapListAll, 2);
scoresSP = nan(labelCount, spCount, 'single'); % Note that zeros will be counted anyways!
mapSP = nan(labelCount, spCount);

% Compute maximum scores and map/mask for the backward pass
for spIdx = 1 : spCount
    ancestors = find(overlapListAll(:, spIdx));
    if ~isempty(ancestors)
        % For each label, compute the ancestor with the highest score
        [scoresSP(:, spIdx), curInds] = max(scoresAll(:, ancestors), [], 2);
        curBoxInds = ancestors(curInds);
        mapSP(:, spIdx) = curBoxInds;
    end
end

% Reshape the scores
scoresSP = reshape(scoresSP, [1, 1, size(scoresSP)]);

% Convert outputs back to GPU if necessary
if gpuMode
    scoresSP = gpuArray(scoresSP);
end