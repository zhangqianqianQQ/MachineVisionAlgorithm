function[meanIOU] = evaluateMeanIOU(imageList, probs, segmentFolder, varargin)
% [meanIOU] = evaluateMeanIOU(imageList, probs, segmentFolder, varargin)
%
% Computes mean-class Intersection over Union with the ground-truth.
% Takes into account the SS hierarchy.
% To use this hierarchy, run reconstructSelSearchHierarchyFromFz().
%
% Note: Void pixels are not taken into consideration!
%
% Copyright by Holger Caesar, 2015

% Parse input
p = inputParser;
addParameter(p, 'printStatus', true);
addParameter(p, 'backgroundBelowThresh', []);
parse(p, varargin{:});

printStatus = p.Results.printStatus;
backgroundBelowThresh = p.Results.backgroundBelowThresh;

% Init
labelCount = size(probs{1}, 2);
assert(labelCount > 1);
pixConfMatrix = zeros(labelCount, labelCount); % gt x output

imageCount = numel(imageList);
for imageIdx = 1 : imageCount,
    if printStatus,
        printProgress('Evaluating meanIOU for image', imageIdx, imageCount);
    end;
    
    % Skip images without ground-truth
    if isempty(probs{imageIdx}),
        continue;
    end;
    
    % Create segmentation path
    imageName = imageList{imageIdx};
    segmentPath = [segmentFolder, filesep, imageName, '.mat'];
    
    % Precompute maximum over labels
    if ~isempty(backgroundBelowThresh),
        % Set all regions with low prob to be background
        [maxProbs, maxInds] = max(double(probs{imageIdx}(:, 2:end)), [], 2);
        maxInds = maxInds + 1;
        curThresh = backgroundBelowThresh;
        sel = maxProbs < curThresh;
        maxProbs(sel) = curThresh-eps;
        maxInds(sel) = 1;
    else
        [maxProbs, maxInds] = max(double(probs{imageIdx}), [], 2);
    end;
    
    %%% Max over all ancestors
    % Load superpixel information
    segmentStruct = load(segmentPath, 'superPixelLabelHistos', 'overlapList');
    spLabelHistos = segmentStruct.superPixelLabelHistos';
    overlapList = segmentStruct.overlapList;
    assert(~isempty(spLabelHistos));
    
    % Compute confusion matrix
    pixConfMatrix = evaluatePixConfMatrix_loop_mex(maxProbs, maxInds, full(double(overlapList)), spLabelHistos, pixConfMatrix);
end;

% Compute IOU per class
labelIOUs = zeros(labelCount, 1);
for labelIdx = 1 : labelCount,
    truePos = pixConfMatrix(labelIdx, labelIdx);
    gtPos = sum(pixConfMatrix(labelIdx, :));
    outPos = sum(pixConfMatrix(:, labelIdx));
    labelIOUs(labelIdx) = truePos / (gtPos + outPos - truePos);
end;

% Compute mean (over classes) intersection-over-union
meanIOU = nanmean(labelIOUs);