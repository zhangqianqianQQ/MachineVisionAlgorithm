function[blobs] = rpGroundTruth(dataset, imageName, varargin)
% [blobs] = rpGroundTruth(dataset, imageName, varargin)
%
% Create a list of region proposals (blobs) of an image using the
% ground-truth labels.
% 
% For information on the returned blobs see blob().
%
% Copyright by Holger Caesar, 2014

% Get label map
labelMap = dataset.getImLabelMap(imageName);

% Create segmentation
regionMap = groundTruthExtractRegions(labelMap);

% Initialize
blobCount = max(regionMap(:));
blobs = cell(blobCount, 1);

for blobIdx = 1 : blobCount,
    % Create blob
    iMask = regionMap == blobIdx;
    
    % Convert pixel mask to blob
    blob = maskToBlob(iMask);
    
    % Store result
    blobs{blobIdx} = blob;
end;

% Convert to col struct
blobs = [blobs{:}];
blobs = blobs(:);