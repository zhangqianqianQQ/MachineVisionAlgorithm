function[pixAcc, meanClassPixAcc, classPixAccs] = evaluatePixAcc(dataset, imageList, probs, segmentFolder, varargin)
% [pixAcc, meanClassPixAcc, classPixAccs] = evaluatePixAcc(dataset, imageList, probs, segmentFolder, varargin)
%
% Evaluates pixel-level accuracies either directly or using Selective Search hierarchies.
%
% Copyright by Holger Caesar, 2015

% Test if hierarchy information is available
assert(~isempty(segmentFolder));
imageIdx = 1;
imageName = imageList{imageIdx};
segmentPath = fullfile(segmentFolder, [imageName, '.mat']);
matObj = matfile(segmentPath);
info = whos(matObj, 'superPixelLabelHistos');
if numel(info) == 1,
    hasHierarchy = true;
else
    hasHierarchy = false;
end;
usePreload = false;

% Evaluate pixel accuracy
if hasHierarchy,
    if usePreload,
        % Init
        imageCount = numel(imageList); %#ok<UNRCH>
        spLabelHistosCell = cell(imageCount, 1);
        overlapListCell = cell(imageCount, 1);
        
        % Preload segmentation info
        for imageIdx = 1 : imageCount,
            imageName = imageList{imageIdx};
            segmentPath = [segmentFolder, filesep, imageName, '.mat'];
            segmentStruct = load(segmentPath, 'superPixelLabelHistos', 'overlapList');
            spLabelHistosCell{imageIdx} = segmentStruct.superPixelLabelHistos';
            overlapListCell{imageIdx} = double(segmentStruct.overlapList);
        end;
        
        [pixAcc, meanClassPixAcc, classPixAccs] = evaluatePixAccHierarchy_preload(imageList, probs, segmentFolder, overlapListCell, spLabelHistosCell, varargin{:});
    else
        [pixAcc, meanClassPixAcc, classPixAccs] = evaluatePixAccHierarchy(imageList, probs, segmentFolder, varargin{:});
    end;
else
    [pixAcc, meanClassPixAcc, classPixAccs] = evaluatePixAccPaint(dataset, imageList, probs, segmentFolder, varargin{:});
end;