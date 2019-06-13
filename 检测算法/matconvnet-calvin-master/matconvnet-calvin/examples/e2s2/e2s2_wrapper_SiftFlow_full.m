 function e2s2_wrapper_SiftFlow_full(varargin)
% e2s2_wrapper_SiftFlow_full(varargin)
%
% A wrapper for Fast-RCNN with Matconvnet that allows to train and test a network.
% Note: The network is prone to exploding gradients and therefore only
% works with the beta16 MatConvNet networks.
%
% Copyright by Holger Caesar, 2015

% Default settings
global glFeaturesFolder;
projectName = 'WeaklySupervisedLearning';
run = 1;
exp = 2;
netName = 'VGG16';
dataset = SiftFlowDatasetMC();
gpus = 1;
roiPool.use = true;
roiPool.freeform.use = true;
roiPool.freeform.combineFgBox = true;
roiPool.freeform.shareWeights = false;
regionToPixel.use = true;
randSeed = 422;
logFile = 'log.txt';
batchSize = 10;
numEpochs = 25;
highLRNumEpochs = 20;
lowLRNumEpochs  = numEpochs - highLRNumEpochs;
highLR = repmat(1e-3, [1, highLRNumEpochs]);
lowLR  = repmat(1e-4, [1,  lowLRNumEpochs]);
learningRate = [highLR, lowLR];
segments.minSize = 100;
segments.switchColorTypesEpoch = true;
segments.switchColorTypesBatch = true;
segments.colorTypes = {'Rgb', 'Hsv', 'Lab'};
segments.colorTypeIdx = 1;
fastRcnnParams = false;
invFreqWeights = true;

% Initialize random number generator seed
if ~isempty(randSeed);
    rng(randSeed);
    if ~isempty(gpus),
        randStream = parallel.gpu.RandStream('CombRecursive', 'Seed', randSeed);
        parallel.gpu.RandStream.setGlobalStream(randStream);
    end;
end;

% Parse input
p = inputParser;
addParameter(p, 'dataset', dataset);
addParameter(p, 'run', run);
addParameter(p, 'exp', exp);
addParameter(p, 'netName', netName);
addParameter(p, 'gpus', gpus);
addParameter(p, 'roiPool', roiPool);
addParameter(p, 'segments', segments);
addParameter(p, 'invFreqWeights', invFreqWeights);
parse(p, varargin{:});

dataset = p.Results.dataset;
run = p.Results.run;
exp = p.Results.exp;
netName = p.Results.netName;
gpus = p.Results.gpus;
roiPool = p.Results.roiPool;
segments = p.Results.segments;
invFreqWeights = p.Results.invFreqWeights;

% Create paths
if strcmp(netName, 'AlexNet'),
    netFileName = 'imagenet-caffe-alex_beta16';
elseif strcmp(netName, 'VGG16'),
    netFileName = 'imagenet-vgg-verydeep-16_beta16';
else
    error('Error: Unknown netName!');
end;
outputFolderName = sprintf('%s_e2s2_run%d_exp%d', dataset.name, run, exp);
netPath = fullfile(glFeaturesFolder, 'CNN-Models', 'matconvnet', [netFileName, '.mat']);
segmentFolder = fullfile(glFeaturesFolder, projectName, dataset.name, 'segmentations');
outputFolder = fullfile(glFeaturesFolder, 'CNN-Models', 'E2S2', dataset.name, sprintf('Run%d', run), outputFolderName);

% Create outputFolder
if ~exist(outputFolder, 'dir'),
    mkdir(outputFolder);
end;

% Start logging
if ~isempty(logFile),
    diary(fullfile(outputFolder, logFile));
end;

% Get images
imageListTrn = dataset.getImageListTrn();
imageListTst = dataset.getImageListTst();

% Store in imdb
imdb = ImdbE2S2(dataset, segmentFolder);
imdb.data.train = imageListTrn;
imdb.data.val   = imageListTst; % val is always the same as test
imdb.data.test  = imageListTst;
imdb.batchOpts.segments = structOverwriteFields(imdb.batchOpts.segments, segments);
imdb.updateSegmentNames();

% Create nnOpts
nnOpts = struct();
nnOpts.expDir = outputFolder;
nnOpts.numEpochs = numEpochs;
nnOpts.batchSize = batchSize;
nnOpts.numSubBatches = batchSize; % Always the same as batchSize!
nnOpts.gpus = gpus;
nnOpts.continue = CalvinNN.findLastCheckpoint(outputFolder) > 0;
nnOpts.learningRate = learningRate;
nnOpts.misc.roiPool = roiPool;
nnOpts.misc.regionToPixel = regionToPixel;
nnOpts.misc.invFreqWeights = invFreqWeights;
nnOpts.bboxRegress = false;
nnOpts.fastRcnnParams = fastRcnnParams;

% Save the current options
netOptsPath = fullfile(outputFolder, 'net-opts.mat');
save(netOptsPath, 'nnOpts', 'imdb', '-v6');

% Create network
nnClass = E2S2NN(netPath, imdb, nnOpts);

% Train the network
nnClass.train();

% Test the network
stats = nnClass.test();
disp(stats);