function rpAddPath(segmentationName)
% rpAddPath(segmentationName)
%
% Adds the required folders for a region proposal method to the Matlab path.
%
% Copyright by Holger Caesar, 2014 

% Initialize region proposal functions
if strStartsWith(segmentationName, 'GroundTruth'),
    % Do nothing
elseif strcmp(segmentationName, 'Felzenszwalb2004') || strStartsWith(segmentationName, 'Uijlings2013'),
    % Add code to path
    global glBaseFolder;
    codeFolder = fullfile(glBaseFolder, 'Code', 'SelectiveSearchCodeIJCV');
    assert(exist(codeFolder, 'dir') ~= 0)
    addpath(genpath(codeFolder));
else
    error('Error: Unknown segmentation specified!');
end;