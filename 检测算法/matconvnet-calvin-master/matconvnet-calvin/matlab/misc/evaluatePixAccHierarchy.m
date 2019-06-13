function[pixAcc, meanClassPixAcc, classPixAccs] = evaluatePixAccHierarchy(imageList, probs, segmentationFolder, varargin)
% [pixAcc, meanClassPixAcc, classPixAccs] = evaluatePixAccHierarchy(imageList, probs, segmentationFolder, varargin)
%
% Same as evaluatePixAccPaint, but much faster by taking into account the SS hierarchy.
% To use this hierarchy, run reconstructSelSearchHierarchyFromFz().
%
% Copyright by Holger Caesar, 2015

% Parse input
p = inputParser;
addParameter(p, 'printStatus', true);
parse(p, varargin{:});

printStatus = p.Results.printStatus;

% Init
labelCount = size(probs{1}, 2);
assert(labelCount > 1);
pixCorrectHisto = zeros(labelCount, 1);
pixTotalHisto = zeros(labelCount, 1);

imageCount = numel(imageList);
for imageIdx = 1 : imageCount,
    if printStatus,
        printProgress('Evaluating pixel accuracy for image', imageIdx, imageCount);
    end;
    
    % Skip images without ground-truth
    if isempty(probs{imageIdx}),
        continue;
    end;
    
    % Create segmentation path
    imageName = imageList{imageIdx};
    segmentPath = [segmentationFolder, filesep, imageName, '.mat'];
    
    % Precompute maximum over labels
    [maxProbs, maxInds] = max(probs{imageIdx}, [], 2);
    
    % Load superpixel information
    segmentStruct = load(segmentPath, 'superPixelLabelHistos', 'overlapList');
    superPixelLabelHistos = segmentStruct.superPixelLabelHistos';
    overlapList = double(segmentStruct.overlapList);
    
    % Compute maximum over regions (that contain a superpixel) and count pixels
    [pixCorrectHisto, pixTotalHisto] = evaluatePixAccHierarchy_loop(maxProbs, maxInds, full(overlapList), superPixelLabelHistos, pixCorrectHisto, pixTotalHisto);
end;

% Compute overall accuracies
pixAcc = sum(pixCorrectHisto) / sum(pixTotalHisto);
classPixAccs = pixCorrectHisto ./ pixTotalHisto;
meanClassPixAcc = nanmean(classPixAccs);