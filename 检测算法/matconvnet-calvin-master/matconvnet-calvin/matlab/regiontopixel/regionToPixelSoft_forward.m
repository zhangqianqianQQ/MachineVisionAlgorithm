function[scoresSP, weightsSP] = regionToPixelSoft_forward(scoresAll, overlapListAll, decay)
% [scoresSP, weightsSP] = regionToPixelSoft_forward(scoresAll, overlapListAll, decay)
%
% Go from a region level to a pixel level.
% (to be able to compute a loss there)
%
% Outputs:
% - scoresSP: Per-class scores for each superpixel.
% - weightsSP: Per-class weight of each region for each superpixel.
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
rpCount = size(overlapListAll, 1);
spCount = size(overlapListAll, 2);
scoresSP = nan(labelCount, spCount, 'single'); % Note that zeros will be counted anyways!
weightsSP = zeros(labelCount, spCount, rpCount);

% Compute maximum scores and map/mask for the backward pass
for spIdx = 1 : spCount
    ancestors = find(overlapListAll(:, spIdx));
    if ~isempty(ancestors)
        for labelIdx = 1 : labelCount
            % For each label, compute the ancestor with the highest score
            ancestorScores = scoresAll(labelIdx, ancestors);
            [~, sortOrder] = sort(ancestorScores, 'descend');
            [~, rank] = sort(sortOrder, 'ascend');
            masses = decay .^ (rank - 1);
            masses = masses ./ sum(masses);
            outScore = sum(masses .* ancestorScores);
            scoresSP(labelIdx, spIdx) = outScore;
            weightsSP(labelIdx, spIdx, ancestors) = masses;
            
%             weightsSP(labelIdx, spIdx, outCoord) = 1; before more like that
        end
    end
end

% Reshape the scores
scoresSP = reshape(scoresSP, [1, 1, size(scoresSP)]);

% Convert outputs back to GPU if necessary
if gpuMode
    scoresSP = gpuArray(scoresSP);
end