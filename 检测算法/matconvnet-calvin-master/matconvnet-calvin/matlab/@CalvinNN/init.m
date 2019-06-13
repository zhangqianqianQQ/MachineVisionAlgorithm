function init(obj, varargin)
% init(obj, varargin)
%
% Initialize the CalvinNN network with the default options.
% Also starts up GPU pool.
%
% Copyright by Holger Caesar, 2016

defnnOpts.expDir = fullfile('data', 'exp');
defnnOpts.continue = true;
defnnOpts.batchSize = 2;
defnnOpts.numSubBatches = 2;
defnnOpts.gpus = [];
defnnOpts.numEpochs = 16;
defnnOpts.learningRate = [repmat(1e-3, [1, 12]), repmat(1e-4, [1, 4])];
defnnOpts.weightDecay = 0.0005;
defnnOpts.momentum = 0.9;
defnnOpts.derOutputs = {'objective', 1};
defnnOpts.lossFnObjective = 'softmaxlog'; % Default is softmax
defnnOpts.extractStatsFn = @CalvinNN.extractStats;
defnnOpts.testFn = @(imdb, nnOpts, net, inputs, batchInds) error('Error: Test function not implemented'); % function used at test time to evaluate performance
defnnOpts.misc = struct(); % fields used by custom layers are stored here
defnnOpts.plotEval = true;
defnnOpts.plotAccuracy = true;

% Network options
defnnOpts.convertToTrain = true;

% Fast R-CNN options
defnnOpts.fastRcnn = true;
defnnOpts.fastRcnnParams = true; % learning rates and weight decay
defnnOpts.misc.roiPool.use = true;
defnnOpts.misc.roiPool.freeform.use = false;
defnnOpts.bboxRegress = true;

% Merge input settings with default settings
nnOpts = vl_argparse_old(defnnOpts, varargin, 'nonrecursive');

% Check settings
assert(numel(nnOpts.learningRate) == 1 || numel(nnOpts.learningRate) == nnOpts.numEpochs);

% Do not create directory in evaluation mode
if ~exist(nnOpts.expDir, 'dir') && ~isempty(nnOpts.expDir),
    mkdir(nnOpts.expDir);
end

% Setup GPU
numGpus = numel(nnOpts.gpus);
assert(numGpus <= 1);
if numGpus == 1,
    gpuDevice(nnOpts.gpus);
end

% Set new fields
obj.nnOpts = nnOpts;