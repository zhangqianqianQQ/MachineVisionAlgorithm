function e2s2_loadAndEvaluate(varargin)
% e2s2_loadAndEvaluate(varargin)
%
% Evaluate a network snapshot on a given dataset.
%
% Copyright by Holger Caesar, 2016

% Initial settings
p = inputParser;
addParameter(p, 'dataset', SiftFlowDatasetMC());
addParameter(p, 'weaklySupervised', false);
addParameter(p, 'run', 28);
addParameter(p, 'exp', 25);
addParameter(p, 'epochs', [1, 5:5:30]);
addParameter(p, 'gpus', 1);
addParameter(p, 'subset', 'test');
addParameter(p, 'plotStats', true);
addParameter(p, 'minSize', []); % typically 100
addParameter(p, 'maxSizeRel', []);
addParameter(p, 'doCache', true);
addParameter(p, 'storeOutputMaps', false);
addParameter(p, 'limitImageCount', Inf);
addParameter(p, 'subsamplePosRange', []);
addParameter(p, 'testColorSpace', []);
parse(p, varargin{:});

dataset = p.Results.dataset;
weaklySupervised = p.Results.weaklySupervised;
run = p.Results.run;
exp = p.Results.exp;
epochs = p.Results.epochs;
gpus = p.Results.gpus;
subset = p.Results.subset;
plotStats = p.Results.plotStats;
minSize = p.Results.minSize;
maxSizeRel = p.Results.maxSizeRel;
doCache = p.Results.doCache;
storeOutputMaps = p.Results.storeOutputMaps;
limitImageCount = p.Results.limitImageCount;
subsamplePosRange = p.Results.subsamplePosRange;
testColorSpace = p.Results.testColorSpace;

% Settings
plotStats = plotStats && strcmp(subset, 'test') && numel(epochs) > 1;
stats = cell(numel(epochs), 1);
if ~isempty(minSize) || ~isempty(maxSizeRel) || ~isinf(limitImageCount),
    fprintf('Warning: Cannot cache results due to custom (blob size or limitImageCount) settings!\n');
    doCache = false;
end

% Create paths
global glFeaturesFolder;
if weaklySupervised,
    wsStr = 'ws';
else
    wsStr = '';
end
outputName = sprintf('%s_e2s2%s_run%d_exp%d', dataset.name, wsStr, run, exp);
netFolder = fullfile(glFeaturesFolder, 'CNN-Models', 'E2S2', dataset.name, sprintf('Run%d', run), outputName);

%%% Load and set netOpts
netOptsPath = fullfile(netFolder, 'net-opts.mat');
netOptsStruct = load(netOptsPath, 'imdb', 'nnOpts');
netOptsStruct.nnOpts.gpus = gpus;
netOptsStruct.nnOpts.expDir = netFolder;

% Disable conversion from test to train
netOptsStruct.nnOpts.convertToTrain = false;

% Update the dataset in the imdb to avoid a nasty bug due to changed dataset classes
netOptsStruct.imdb.dataset = dataset;

% Set testing options to restrict regions by size
if ~isempty(maxSizeRel),
    netOptsStruct.nnOpts.misc.testOpts.maxSizeRel = maxSizeRel;
end
if ~isempty(minSize),
    netOptsStruct.nnOpts.misc.testOpts.minSize = minSize;
end
if ~isempty(subsamplePosRange),
    netOptsStruct.nnOpts.misc.testOpts.subsamplePosRange = subsamplePosRange;
end
if ~isempty(testColorSpace)
    netOptsStruct.nnOpts.misc.testOpts.testColorSpace = testColorSpace;
end

for epochIdx = 1 : numel(epochs),
    epoch = epochs(epochIdx);
    netPath = fullfile(netFolder, sprintf('net-epoch-%d.mat', epoch));
    
    % Load net
    netIn = load(netPath, 'net', 'stats');
    
    % Create network
    nnClass = E2S2NN(netIn, netOptsStruct.imdb, netOptsStruct.nnOpts);
    
    % Test network
    stats{epochIdx} = nnClass.testOnSet('subset', subset, 'doCache', doCache, 'limitImageCount', limitImageCount, 'storeOutputMaps', storeOutputMaps);
    fprintf('Displaying stats for epoch %d of exp %s...\n', epoch, outputName);
    disp(stats{epochIdx});
end

% Create a plot of the above stats
if plotStats,
    trainLoss = cell2mat({nnClass.stats.train.objective});
    valLoss   = cell2mat({nnClass.stats.val.objective});
    paccs = cellfun(@(s) s.pacc, stats);
    maccs = cellfun(@(s) s.macc, stats);
    mius  = cellfun(@(s) s.miu, stats);
    
    figure(1); clf;
    
    subplot(2, 1, 1);
    hold on;
    plot(1:numel(trainLoss), trainLoss);
    plot(1:numel(valLoss),     valLoss);
    legend({'train', 'val'});
    xlabel('epoch');
    ylabel('loss');
    ax = gca;
    axis([0, numel(trainLoss), ax.YLim]);
    grid on;
    
    subplot(2, 1, 2);
    hold on;
    plot(epochs, paccs);
    plot(epochs, maccs);
    plot(epochs, mius);
    legend({'Pix. Acc. test', 'Class Acc. test', 'Mean IU test'}, 'Location', 'SouthEast');
    xlabel('epoch');
    ylabel('accuracy');
    ax = gca;
    axis([0, numel(trainLoss), ax.YLim]);
    grid on;
    
    plotPath = fullfile(netFolder, 'net-test.pdf');
    if exist(plotPath, 'file'),
        error('Error: plotPath already exists: %s', plotPath);
    end
    print(1, plotPath, '-dpdf'); %#ok<MCPRT>
end
