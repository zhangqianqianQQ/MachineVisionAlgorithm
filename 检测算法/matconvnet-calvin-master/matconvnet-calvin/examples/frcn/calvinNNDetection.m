% function calvinNNDetection()
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
outputFolder = fullfile(glFeaturesFolder, 'CNN-Models', 'FRCN', vocName, sprintf('%s-testRelease', vocName));
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
nnOpts.testFn = @testDetection;
nnOpts.misc.overlapNms = 0.3;
nnOpts.derOutputs = {'objective', 1, 'regressObjective', 1};

% General
nnOpts.batchSize = 2;
nnOpts.numSubBatches = nnOpts.batchSize; % 1 image per sub-batch
nnOpts.weightDecay = 5e-4;
nnOpts.momentum = 0.9;
nnOpts.numEpochs = 16;
nnOpts.learningRate = [repmat(1e-3, 12, 1); repmat(1e-4, 4, 1)];
nnOpts.misc.netPath = netPath;
nnOpts.expDir = outputFolder;
nnOpts.gpus = 1; % for automatic selection use: SelectIdleGpu();

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
imdb = setupImdbDetection(trainName, testName, net);

% Create calvinNN CNN class
% By default, network is transformed into fast-rcnn with bbox regression
calvinn = CalvinNN(net, imdb, nnOpts);

%%% Train
calvinn.train();

%%% Test
stats = calvinn.test();

%%% Eval
evalDetection(testName, imdb, stats, nnOpts);
