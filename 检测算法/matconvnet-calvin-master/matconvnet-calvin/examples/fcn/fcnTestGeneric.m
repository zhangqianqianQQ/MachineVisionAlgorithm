function[stats] = fcnTestGeneric(varargin)
% [stats] = fcnTestGeneric(varargin)
%
% Copyright by Holger Caesar, 2016

% Initial settings
p = inputParser;
addParameter(p, 'dataset', SiftFlowDatasetMC());
addParameter(p, 'modelType', 'fcn16s');
addParameter(p, 'gpus', 1);
addParameter(p, 'randSeed', 42);
addParameter(p, 'expNameAppend', 'testRelease');
addParameter(p, 'epoch', 50);
addParameter(p, 'subset', 'test'); % train / test
addParameter(p, 'expSubFolder', '');
addParameter(p, 'findMapping', false); % Find the best possible label mapping from ILSVRC to target dataset
addParameter(p, 'storeOutputMaps', true);
addParameter(p, 'extractFeatsVarName', ''); % If used we don't measure performance
addParameter(p, 'plotFreq', 15);
parse(p, varargin{:});

dataset = p.Results.dataset;
modelType = p.Results.modelType;
gpus = p.Results.gpus;
randSeed = p.Results.randSeed;
expNameAppend = p.Results.expNameAppend;
epoch = p.Results.epoch;
subset = p.Results.subset;
expSubFolder = p.Results.expSubFolder;
findMapping = p.Results.findMapping;
storeOutputMaps = p.Results.storeOutputMaps;
extractFeatsVarName = p.Results.extractFeatsVarName;
plotFreq = p.Results.plotFreq;
callArgs = p.Results; %#ok<NASGU>

% Experiment and data paths
global glFeaturesFolder;
expName = [modelType, prependNotEmpty(expNameAppend, '-')];
expDir = fullfile(glFeaturesFolder, 'CNN-Models', 'FCN', dataset.name, expSubFolder, expName);
netPath = fullfile(expDir, sprintf('net-epoch-%d.mat', epoch));
netOptsPath = fullfile(expDir, 'net-opts.mat');

% Fix randomness
rng(randSeed);

% Check if directory exists
if ~exist(expDir, 'dir')
    error('Error: Experiment directory does not exist %s\n', expDir);
end

% Load imdb and nnOpts from file
if exist(netOptsPath, 'file')
    netOptsStruct = load(netOptsPath, 'callArgs', 'nnOpts', 'imdbFcn');
    nnOpts = netOptsStruct.nnOpts;
    imdbFcn = netOptsStruct.imdbFcn;
    assert(isequal(dataset.name, imdbFcn.dataset.name));
else
    error('Error: Cannot find netOpts path: %s', netOptsPath);
end

% If there is no validation set specified, use val as test set
if ~isfield(imdbFcn.data, 'test')
    imdbFcn.data.test = imdbFcn.data.val;
    imdbFcn.data = rmfield(imdbFcn.data, 'val');
end

imdbFcn.numClasses = imdbFcn.dataset.labelCount;

% Overwrite some settings
nnOpts.gpus = gpus;
nnOpts.convertToTrain = false;
nnOpts.expDir = expDir;

% Create network
nnClass = FCNNN(netPath, imdbFcn, nnOpts);

if isempty(extractFeatsVarName)
    % Test the network performance
    stats = nnClass.testOnSet('subset', subset, 'findMapping', findMapping, 'storeOutputMaps', storeOutputMaps, 'plotFreq', plotFreq);
else
    % Extract the specified features
    nnClass.extractFeatures('outputVarName', extractFeatsVarName);
end
