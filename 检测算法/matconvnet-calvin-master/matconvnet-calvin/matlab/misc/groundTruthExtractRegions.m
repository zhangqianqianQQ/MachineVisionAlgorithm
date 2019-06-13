function[regionMap, labelList, regionPixelCounts] = groundTruthExtractRegions(gtMap)
% [regionMap, labelList, regionPixelCounts] = groundTruthExtractRegions(gtMap)
%
% Takes a map of ground-truth labels and extracts different 8-connected
% regions from it.
%
% Copyright by Holger Caesar, 2014

% Get a list of the labels in the image and remove background (0)
labels = double(unique(gtMap(:)));
labels(labels == 0) = [];
labelCount = numel(labels);

% Extract all 8-connected regions of the same label in the image
% regions = cell(labelCount, 1);
labelList = zeros(labelCount, 1);
regionPixelCounts = zeros(labelCount, 1);
regionIdx = 1;
regionMap = zeros(size(gtMap));
for labelIdx = 1 : labelCount,
    % Find the number of different regions with the current label
    regionStruct = bwconncomp(gtMap == labels(labelIdx));
    regionsPixels = regionStruct.PixelIdxList';
    regionCount = numel(regionsPixels);
    
    for labelRegionIdx = 1 : regionCount,
        regionMap(regionsPixels{labelRegionIdx}) = regionIdx;
        
        % Count the number of pixels in the region
        regionPixelCounts(regionIdx, 1) = numel(regionsPixels{labelRegionIdx});
        
        % Assign the current label
        labelList(regionIdx, 1) = labels(labelIdx);
        
        % Increment counter
        regionIdx = regionIdx + 1;
    end;
end;