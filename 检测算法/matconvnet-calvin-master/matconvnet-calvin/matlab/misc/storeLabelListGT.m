function storeLabelListGT(varargin)
% storeLabelListGT(varargin)
%
% Create the labelListGT entry for each ground-truth segmentation file of the dataset.
%
% Copyright by Holger Caesar, 2015

% Parse input
p = inputParser;
addParameter(p, 'projectName', 'WeaklySupervisedLearning');
addParameter(p, 'dataset', SiftFlowDatasetMC());
addParameter(p, 'proposalNameGT', 'GroundTruth');
addParameter(p, 'subset', 'all');
parse(p, varargin{:});

projectName = p.Results.projectName;
dataset = p.Results.dataset;
proposalNameGT = p.Results.proposalNameGT;
subset = p.Results.subset;

% Create paths
global glFeaturesFolder;
segmentFolder = fullfile(glFeaturesFolder, projectName, dataset.name, 'segmentations', proposalNameGT);

% Get list of images in dataset
if strcmp(subset, 'all'),
    [imageList, imageCount] = dataset.getImageList();
elseif strcmp(subset, 'train'),
    [imageList, imageCount] = dataset.getImageListTrn();
elseif strcmp(subset, 'test'),
    [imageList, imageCount] = dataset.getImageListTst();
else
    error('Error: Unknown subset: %s', subset);
end;

for imageIdx = 1 : imageCount,
    printProgress('Processing image', imageIdx, imageCount, 50);
    
    % Get segmentation
    imageName = imageList{imageIdx};
    segmentPath = [segmentFolder, filesep, imageName, '.mat'];
    segmentStruct = load(segmentPath);
    if isfield(segmentStruct, 'labelListGT'),
        fprintf('Skipping existing file %s...\n', segmentPath);
        continue;
    end;
    propBlobs = segmentStruct.propBlobs;
    blobCount = numel(propBlobs);
    
    % Get labelMap
    labelMap = dataset.getImLabelMap(imageName);
    labelListGT = nan(blobCount, 1);
    
    for blobIdx = 1 : blobCount,
        % Get labels for that blob
        blob = propBlobs(blobIdx);        
        blobInds = blobToImageInds(blob, size(labelMap));
        blobLabel = unique(labelMap(blobInds));
        assert(numel(blobLabel) == 1 && blobLabel > 0);
        labelListGT(blobIdx) = blobLabel;
    end;
    
    % Sanity check
    assert(~any(isnan(labelListGT)));
    
    % Append to file
    save(segmentPath, 'labelListGT', '-append');
end;