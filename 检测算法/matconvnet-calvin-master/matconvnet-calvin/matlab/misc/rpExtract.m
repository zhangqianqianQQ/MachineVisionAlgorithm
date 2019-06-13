function rpExtract(varargin)
% rpExtract(varargin)
%
% Extract region proposals for each image.
%
% This differs from rpExtractAndScore in that the performance of the
% proposals is not  evaluated.
%
% Copyright by Holger Caesar, 2014

% Initial settings
p = inputParser;
addParameter(p, 'dataset', SiftFlowDatasetMC);
addParameter(p, 'projectName', 'WeaklySupervisedLearning');
addParameter(p, 'proposalName', 'Uijlings2013');
addParameter(p, 'proposalsVars', {});
addParameter(p, 'proposalNameAppend', '');
addParameter(p, 'randomOrder', false);
addParameter(p, 'subset', 'all');
parse(p, varargin{:});

dataset = p.Results.dataset;
projectName = p.Results.projectName;
proposalName = p.Results.proposalName;
proposalsVars = p.Results.proposalsVars;
proposalNameAppend = p.Results.proposalNameAppend;
randomOrder = p.Results.randomOrder;
subset = p.Results.subset;
callArgs = p.Results; %#ok<NASGU>

% Default arguments
proposalsVars = rpGetProposalsVars(proposalName, proposalsVars);
proposalNameAppend = [appendNotEmpty(proposalNameAppend, '-'), varargToStr('-', proposalsVars)];

%%%% Program start
imagesProcessed = 0;

% Make program reproducible
rng(42);

% Folders
global glFeaturesFolder;
segmentFolder = fullfile(glFeaturesFolder, projectName, dataset.name, 'segmentations', [proposalName, prependNotEmpty(proposalNameAppend, '-')]);

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

% Add required folders to Matlab path
rpAddPath(proposalName);

% Define region proposal function
rpFunc = rpGetFunc(proposalName);

% Start timer
scoreRegionTimer = tic;

for imageIdx = 1 : imageCount,
    imagesRemaining = imageCount - imageIdx;
    secsPerImage = toc(scoreRegionTimer) / imagesProcessed;
    hoursLeft = secsPerImage / 60 / 60 * imagesRemaining;
    fprintf('Segmenting image %d / %d (%.1fs/im, %.1fmin left)...\n', imageIdx, imageCount, secsPerImage, hoursLeft*60);
    
    % Get image name
    imageName = imageList{imageIdx};
    segmentPath = fullfile(segmentFolder, [imageName, '.mat']);
    if exist(segmentPath, 'file'),
        fprintf('Warning: File already exists. Skipping: %s\n', segmentPath);
        continue;
    end;
    
    % Read in image and convert to double
    image = dataset.getImage(imageName);
    
    % Extract region proposals
    propBlobs = rpFunc(dataset, imageName, image, proposalsVars{:});
    propBlobs = propBlobs(:); %#ok<NASGU>
    
    % Save blobs to disk
    propPathDir = filePathRemoveFile(segmentPath);
    if ~exist(propPathDir, 'dir'),
        mkdir(propPathDir);
    end;
    save(segmentPath, 'propBlobs', '-v6');
    
    % Update imagesProcessed counter (not done if we skip a file)
    imagesProcessed = imagesProcessed + 1;
end;

scoreRegionTime = toc(scoreRegionTimer);

% Send status mail
fprintf('rpExtract: Finished %s after %.1fs for %d images!\n', proposalName, scoreRegionTime, max(0, imagesProcessed-1));