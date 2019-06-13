function[outputMap, outputMapProbs] = blobProbsToOutputMap(propBlobs, regionAss, regionProbs, imageSize, varargin)
% [outputMap, outputMapProbs] = blobProbsToOutputMap(propBlobs, regionAss, regionProbs, imageSize, varargin)
%
% Convert blobs and their probs to an outputMap.
% Blobs need not be sorted by score in advance.
% fallBackLabel is 1
% Note: This file cannot be used in Matlab coder.
%
% Copyright by Holger Caesar, 2015

% Parse input
p = inputParser;
addParameter(p, 'fallBackLabel', 1);
addParameter(p, 'checkProbs', true);
parse(p, varargin{:});

fallBackLabel = p.Results.fallBackLabel;
checkProbs = p.Results.checkProbs;

% Check inputs
if checkProbs,
    assert(min(regionProbs) >= 0, 'Error: regionProbs are not valid probabilities!');
end;

% Initialize
outputMapProbs = zeros(imageSize);
outputMap = ones(imageSize) * fallBackLabel;

% Sort blobs to reduce the number of blobs we have to look at
[~, sortOrder] = sort(regionProbs, 'descend');

% Extract most likely label per pixel (not region proposal)
imageNumel = prod(imageSize);
pixelSetCount = 0;
propCount = numel(propBlobs);
for sortOrderIdx = 1 : propCount,
    propIdx = sortOrder(sortOrderIdx);
    blob = propBlobs(propIdx);
    
    % Get blob label and score
    blobLabel = regionAss(propIdx);
    blobScore = regionProbs(propIdx);
       
    % Get indices of blob in image (Fast alternative to sub2ind)
    outputInds = blobToImageInds(blob, imageSize);
    
    % Take only inds which are not set yet
    outputInds = outputInds(outputMapProbs(outputInds) == 0);

    % Update pixel probs and labels
    pixelSetCount = pixelSetCount + numel(outputInds);
    outputMapProbs(outputInds) = blobScore;
    outputMap(outputInds) = blobLabel;
    
    % Check if we're done
    if pixelSetCount >= imageNumel,
        break;
    end;
end;