function[image] = labelMapToColorImage(labelMap, labelCount, cmap)
% [image] = labelMapToColorImage(labelMap, [labelCount], [cmap])
%
% Convert an mxn labelMap to a color image.
% Each index is replaced by a certain color from a colormap.
% If labelCount is specified, we use absolute colors, otherwise the colors
% are sorted by label indices.
%
% Copyright by Holger Caesar, 2014

% Default arguments
if ~exist('labelCount', 'var'),
    labelCount = [];
end;
if ~exist('cmap', 'var'),
    cmap = @jet;
end;

% Get a unique list of all labels
labelList = unique(labelMap(:));
labelList(labelList == 0) = [];
labelListCount = numel(labelList);

% Initialize result
image = zeros(size(labelMap, 1), size(labelMap, 2), 3);
if isempty(labelCount),
    % Take a variable color scheme
    colormap = cmap(labelListCount);
else
    % Take a fixed color scheme relative to the number of labels in the
    % dataset
    colormap = cmap(labelCount);
    colormap = colormap(labelList, :);
end;

% Go through each label and replace its pixels by a color
for labelListIdx = 1 : labelListCount,
    labelIdx = labelList(labelListIdx);
    indices = labelMap == labelIdx;
    
    curImage = cat(3, ...
        indices .* colormap(labelListIdx, 1), ...
        indices .* colormap(labelListIdx, 2), ...
        indices .* colormap(labelListIdx, 3));
    image = image + curImage;
end;