function e2s2_storeSPGTOverlap(varargin)
% e2s2_storeSPGTOverlap(varargin)
%
% Augment the superpixel structure with the overlap with the GT blob.
%
% Copyright by Holger Caesar, 2015

% Parse input
p = inputParser;
addParameter(p, 'dataset', SiftFlowDatasetMC());
addParameter(p, 'projectName', 'WeaklySupervisedLearning');
addParameter(p, 'spName', 'Felzenszwalb2004-k100-sigma0.8-colorTypesRgb');
addParameter(p, 'gtName', 'GroundTruth');
parse(p, varargin{:});

dataset = p.Results.dataset;
projectName = p.Results.projectName;
spName = p.Results.spName;
gtName = p.Results.gtName;

% Create paths
global glFeaturesFolder;
segmentFolderSP = fullfile(glFeaturesFolder, projectName, dataset.name, 'segmentations', spName);
segmentFolderGT = fullfile(glFeaturesFolder, projectName, dataset.name, 'segmentations', gtName);

% Get image list
[imageList, imageCount] = dataset.getImageList(true);

for imageIdx = 1 : imageCount,
    printProgress(sprintf('Storing GT-SP (%s) overlap for image', spName), imageIdx, imageCount, 50);
    imageName = imageList{imageIdx};
    imageSize = dataset.getImageSize(imageName);
    
    % Get SP blobs
    segmentPathSP = fullfile(segmentFolderSP, [imageName, '.mat']);
    assert(exist(segmentPathSP, 'file') ~= 0);
    segmentStructSP = load(segmentPathSP, 'propBlobs');
    blobsSP = segmentStructSP.propBlobs;
    
    % Get GT blobs
    segmentPathGT = fullfile(segmentFolderGT, [imageName, '.mat']);
    assert(exist(segmentPathGT, 'file') ~= 0);
    segmentStructGT = load(segmentPathGT, 'propBlobs');
    blobsGT = segmentStructGT.propBlobs;
    
    % Compute overlap
    overlapRatiosSPGT = computeBlobOverlapSum(blobsSP, blobsGT, imageSize); %#ok<NASGU>
    
    % Store to disk (append)
    assert(exist(segmentPathSP, 'file') ~= 0);
    save(segmentPathSP, 'overlapRatiosSPGT', '-append');
end;