% function calvinNNClassification()
%
% Copyright by Holger Caesar, 2016

% Global variables
global glDatasetFolder glFeaturesFolder;
assert(~isempty(glDatasetFolder) && ~isempty(glFeaturesFolder));

%%% Settings
% Dataset
vocYear = 2010;
trainName = 'train';
testName  = 'val';

% Specify paths
vocName = sprintf('VOC%d', vocYear);
datasetDir = [fullfile(glDatasetFolder, vocName), '/'];
outputFolder = fullfile(glFeaturesFolder, 'CNN-Models', 'CLS', vocName, sprintf('%s-testRelease', vocName));
netPath = fullfile(glFeaturesFolder, 'CNN-Models', 'matconvnet', 'imagenet-vgg-verydeep-16.mat');
logFilePath = fullfile(outputFolder, 'log.txt');

% Fix randomness
randSeed = 42;
rng(randSeed);

% Setup dataset specific options and check validity
setupDataOpts(vocYear, testName, datasetDir);
global DATAopts;
assert(~isempty(DATAopts), 'Error: Dataset not initialized properly!');

% Task-specific
nnOpts.testFn = @testClassification;
nnOpts.lossFnObjective = 'hinge';
nnOpts.derOutputs = {'objective', single(1)};

% Disable Fast R-CNN (default is on)
nnOpts.fastRcnn = false;
nnOpts.fastRcnnParams = false; % learning rates and weight decay
nnOpts.misc.roiPool.use = false;
nnOpts.misc.roiPool.freeform.use = false;
nnOpts.bboxRegress = false;

% General
nnOpts.batchSize = 64;
nnOpts.numSubBatches = 1;  % 64 images per sub-batch
nnOpts.weightDecay = 5e-4;
nnOpts.momentum = 0.9;
nnOpts.numEpochs = 16;
nnOpts.learningRate = [repmat(1e-3, 12, 1); repmat(1e-4, 4, 1)];
nnOpts.misc.netPath = netPath;
nnOpts.gpus = 1; % for automatic selection use: SelectIdleGpu();
nnOpts.expDir = outputFolder;

% Create outputFolder
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% Start logging
diary(logFilePath);

%%% Setup
% Start from pretrained network
net = load(nnOpts.misc.netPath);

% Setup imdb
imdb = setupImdbClassification(trainName, testName, net);
imdb.targetImSize = [224, 224];

% Create calvinNN CNN class
calvinn = CalvinNN(net, imdb, nnOpts);

%%% Train
calvinn.train();

%%% Test
stats = calvinn.test();

%%% Eval
evalClassification(imdb, stats, nnOpts);
