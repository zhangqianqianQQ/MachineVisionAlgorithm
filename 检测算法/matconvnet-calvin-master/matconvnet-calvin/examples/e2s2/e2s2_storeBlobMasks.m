function e2s2_storeBlobMasks(varargin)
%  e2s2_storeBlobMasks(varargin)
%
% Augment the region proposal structure with a downscaled version of each
% blobs mask.
%
% Copyright by Holger Caesar, 2015

% Parse input
p = inputParser;
addParameter(p, 'dataset', SiftFlowDatasetMC());
addParameter(p, 'projectName', 'WeaklySupervisedLearning');
addParameter(p, 'proposalName', 'Uijlings2013-ks100-sigma0.8-colorTypesRgb');
addParameter(p, 'roiPoolFreeformDilateSize', []); % Don't change this!
addParameter(p, 'roiPoolFreeformThresh', 0);      % Don't change this!
addParameter(p, 'roiPoolSize', [7, 7]); %6x6 for AlexNet, 7x7 for VGG16
addParameter(p, 'skipExisting', true);
parse(p, varargin{:});

dataset = p.Results.dataset;
projectName = p.Results.projectName;
proposalName = p.Results.proposalName;
roiPoolFreeformDilateSize = p.Results.roiPoolFreeformDilateSize;
roiPoolFreeformThresh = p.Results.roiPoolFreeformThresh;
roiPoolSize = p.Results.roiPoolSize;
skipExisting = p.Results.skipExisting;

% Create paths
global glFeaturesFolder;
segmentFolder = fullfile(glFeaturesFolder, projectName, dataset.name, 'segmentations', proposalName);

% Get blob mask variable name
masksName = sprintf('blobMasks%dx%d', roiPoolSize(1), roiPoolSize(2));

% Get image list
[imageList, imageCount] = dataset.getImageList();

for imageIdx = 1 : imageCount,
    printProgress(sprintf('Storing blob mask (%s) for image', proposalName), imageIdx, imageCount, 50);
    
    % Get segmentation
    imageName = imageList{imageIdx};
    segmentPath = fullfile(segmentFolder, [imageName, '.mat']);
    assert(exist(segmentPath, 'file') ~= 0);
    segmentStruct = load(segmentPath, 'propBlobs');
    propBlobs = segmentStruct.propBlobs;
    blobCount = numel(propBlobs);
    if matFileHasField(segmentPath, masksName) && skipExisting,
        fprintf('Skipping existing blob masks in file: %s\n', segmentPath);
        continue;
    end;
    
    % Compute blob masks
    blobMasks = cell(blobCount, 1);    
    for blobIdx = 1 : blobCount,
        % Resize and keep an element if the majority of pixels belong
        % to that class
        blobMaskOri = propBlobs(blobIdx).mask;
        
        if ~isempty(roiPoolFreeformDilateSize),
            filterSize = ceil(size(blobMaskOri) * roiPool.roiPoolFreeformDilateSize);
            filter = strel('rectangle', filterSize);
            blobMaskOri = imdilate(blobMaskOri, filter);
        end;
        
        blobMaskOri = double(blobMaskOri);
        blobMask = imresize(blobMaskOri, roiPoolSize, 'Method', 'bilinear', 'Antialiasing', false);
        blobMasks{blobIdx} = blobMask > roiPoolFreeformThresh;
    end;

    % Append the blobMasks to the existing segmentStruct
    eval(sprintf('%s = blobMasks;', masksName));
    save(segmentPath, masksName, '-append');
end;