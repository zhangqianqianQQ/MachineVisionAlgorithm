function reconstructSelSearchHierarchyFromFz(varargin)
% reconstructSelSearchHierarchyFromFz(varargin)
%
% Reconstruct a Selective Search hierachy to find out which superpixels make up the image.
%
% Note that labelHistos require pixel-level ground-truth.
%
% Copyright by Holger Caesar, 2015

% Parse input
p = inputParser;
addParameter(p, 'dataset', SiftFlowDatasetMC);
addParameter(p, 'projectName', 'WeaklySupervisedLearning');
addParameter(p, 'segmentationNameSS', 'Uijlings2013-ks100-sigma0.8-colorTypesRgb'); %can also be used for Felzen regions (but then has to be equal to segmentationNameFz)
addParameter(p, 'segmentationNameFz', 'Felzenszwalb2004-k100-sigma0.8-colorTypesRgb');
addParameter(p, 'subset', 'all');
addParameter(p, 'overwrite', false); % replaces the fields added by this script, but keeps all other fields
addParameter(p, 'randomOrder', false);
parse(p, varargin{:});

dataset = p.Results.dataset;
projectName = p.Results.projectName;
segmentationNameSS = p.Results.segmentationNameSS;
segmentationNameFz = p.Results.segmentationNameFz;
subset = p.Results.subset;
overwrite = p.Results.overwrite;
randomOrder = p.Results.randomOrder;

% Make program reproducible
rng(42);

% Init
globalTimer = tic;
labelCount = dataset.labelCount; %#ok<NASGU>
imagesProcessed = 0;

% Get image list and image size
[imageList, imageCount] = dataset.getImageListSubset(subset);

% Randomize image order
if randomOrder,
    % Store old randomness
    seed = rng;
    
    % Create randomness and shuffle image list
    rng('shuffle');
    imageList = imageList(randperm(imageCount));
    
    % Reset
    rng(seed.Seed);
end;

% Create paths
global glFeaturesFolder;
segmentationFolderSS = fullfile(glFeaturesFolder, projectName, dataset.name, 'segmentations', segmentationNameSS);
segmentationFolderFz = fullfile(glFeaturesFolder, projectName, dataset.name, 'segmentations', segmentationNameFz);

for imageIdx = 1 : imageCount,
    imagesRemaining = imageCount - imageIdx;
    secsPerImage = toc(globalTimer) / imagesProcessed;
    minutesLeft = secsPerImage / 60 * imagesRemaining;
    fprintf('Reconstructing hierarchy for image %d of %d (%.1fmin left) ##\n', imageIdx, imageCount, minutesLeft);
    
    imageName = imageList{imageIdx};
    imageSize = dataset.getImageSize(imageName);
    
    % Get SS propBlobs
    segmentPathSS = fullfile(segmentationFolderSS, [imageName, '.mat']);
    segmentStructSS = load(segmentPathSS);
    propBlobsSS = segmentStructSS.propBlobs;
    if ~overwrite,
        if isfield(segmentStructSS, 'overlapList'),
            fprintf('Skipping file which has already been processed: %s\n', segmentPathSS);
            continue;
        end;
    end;
    
    % Get Fz propBlobs
    segmentPathFz = fullfile(segmentationFolderFz, [imageName, '.mat']);
    segmentStructFz = load(segmentPathFz, 'propBlobs');
    propBlobsFz = segmentStructFz.propBlobs;
    
    % Find superpixels in region proposals
    spCount = numel(propBlobsFz);
    blobSizesSS = [propBlobsSS.size]';
    for spIdx = 1 : spCount,
        candidates = find(blobSizesSS == propBlobsFz(spIdx).size);
        
        for candidateIdx = 1 : numel(candidates),
            regionIdx = candidates(candidateIdx);
            if isequal(propBlobsFz(spIdx), propBlobsSS(regionIdx)),
                break;
            end;
        end;
    end;
    
    % Find Fz segments among the SS regions
    overlapList = sparse(computeBlobOverlapAny(propBlobsFz, propBlobsSS, imageSize))';
    
    % Construct GT label histograms
    superPixelLabelHistos = [];
    
    % Store new information
    segmentStructSS.superPixelLabelHistos = superPixelLabelHistos;
    segmentStructSS.overlapList = overlapList;
    save(segmentPathSS, '-struct', 'segmentStructSS', '-v6');
    imagesProcessed = imagesProcessed + 1;
end;