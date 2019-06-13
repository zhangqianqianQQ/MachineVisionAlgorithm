function[pixAcc, meanClassPixAcc, classPixAccs] = evaluatePixAccPaint(dataset, imageList, probs, segmentFolder, varargin)
% [pixAcc, meanClassPixAcc, classPixAccs] = evaluatePixAccPaint(dataset, imageList, probs, segmentFolder, varargin)
%
% Evaluate the current iteration of the SVM/CRF optimization in terms of pixel
% accuracy.
%
% Note: Maxing the scores is better for classPixAcc, whereas summing them
% is better fo pixAcc.
%
% Copyright by Holger Caesar, 2015

% Parse input
p = inputParser;
addParameter(p, 'printStatus', true);
parse(p, varargin{:});

printStatus = p.Results.printStatus;

% Check inputs
assert(~isempty(dataset));
assert(~isempty(probs));
assert(numel(imageList) == numel(probs));

% Get parameters
imageCount = numel(imageList);
labelCount = dataset.labelCount;

% Initialize
pixCorrectHisto = zeros(labelCount, 1);
pixTotalHisto = zeros(labelCount, 1);

% Compute accuracy to ground-truth
for imageIdx = 1 : imageCount,
    if printStatus,
        printProgress('Evaluating pixel accuracy for image', imageIdx, imageCount);
    end;
    
    % Get GT labels
    imageName = imageList{imageIdx};
    labelMap = dataset.getImLabelMap(imageName);
    
    % Only create an outputMap if regions have been assigned
    if ~isempty(probs{imageIdx}),
        % Get segmentation
        segmentPath = fullfile(segmentFolder, [imageName, '.mat']);
        segmentStruct = load(segmentPath, 'propBlobs');
        propBlobs = segmentStruct.propBlobs(:);
        propCount = numel(propBlobs);
        assert(propCount == size(probs{imageIdx}, 1));
        
        % Get assignments and probs
        regionProbs = probs{imageIdx};
        [~, regionAss] = max(regionProbs, [], 2);
        
        % Sort blobs (assignments, probs) by probs
        probsInds = sub2ind([propCount, labelCount], (1:propCount)', regionAss);
        regionProbs = regionProbs(probsInds);
        [regionProbs, sortOrder] = sort(regionProbs, 'descend');
        regionAss = regionAss(sortOrder);
        propBlobs = propBlobs(sortOrder);
        
        % Extract most likely label per pixel (not region proposal)
        outputMap = blobProbsToOutputMap(propBlobs, regionAss, regionProbs, size(labelMap));
    else
        if printStatus,
            % As this warning is quite common, we want to surpress it if specified
            fprintf('Warning: Creating dummy output map, as no regions have been assigned to this image!\n');
        end;
        outputMap = nan(size(labelMap));
    end;
    
    % Go through all ground-truth labels
    labelMapUn = unique(labelMap(:));
    labelMapUn(labelMapUn == 0) = [];
    for labelMapUnIdx = 1 : numel(labelMapUn),
        label = labelMapUn(labelMapUnIdx);
        
        selection = labelMap(:) == label;
        pixCorrectHisto(label) = pixCorrectHisto(label) + sum(outputMap(selection) == label);
        pixTotalHisto(label) = pixTotalHisto(label) + sum(selection);
    end;
end;

% Compute total accuracy
pixAcc = sum(pixCorrectHisto) / sum(pixTotalHisto);
classPixAccs = pixCorrectHisto ./ pixTotalHisto;
meanClassPixAcc = nanmean(classPixAccs);