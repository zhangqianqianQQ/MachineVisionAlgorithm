function train(obj)
% train(obj)
%
% Main training script used for training and validation.
% Only <= 1 GPUs supported.
% 
% Copyright by Holger Caesar, 2016

modelPath = @(ep) fullfile(obj.nnOpts.expDir, sprintf('net-epoch-%d.mat', ep));
modelFigPath = fullfile(obj.nnOpts.expDir, 'net-train.pdf');
numGpus = numel(obj.nnOpts.gpus);
assert(numGpus <= 1);

% Load previous training snapshot
lastCheckPoint = CalvinNN.findLastCheckpoint(obj.nnOpts.expDir);
if isnan(lastCheckPoint)
    % No checkpoint found
    start = 0;
    
    % Save untrained net
    obj.saveState(modelPath(start));
else
    % Load existing checkpoint and continue
    start = obj.nnOpts.continue * lastCheckPoint;
    fprintf('Resuming by loading epoch %d\n', start);
    if start >= 1
        [obj.net, obj.stats] = CalvinNN.loadState(modelPath(start));
    end
end

for epoch = start + 1 : obj.nnOpts.numEpochs
    
    % Set epoch and it's learning rate
    state.epoch = epoch;
    state.learningRate = obj.nnOpts.learningRate(min(epoch, numel(obj.nnOpts.learningRate)));
    
    % Set the current epoch in imdb
    obj.imdb.initEpoch(epoch);
    
    % Do training and validation
    datasetModes = {'train', 'val'};
    for datasetModeIdx = 1 : numel(datasetModes)
        datasetMode = datasetModes{datasetModeIdx};
        
        % Set train/val mode (disable Dropout etc.)
        obj.imdb.setDatasetMode(datasetMode);
        if strcmp(datasetMode, 'train'),
            obj.net.mode = 'train';
        else % val
            obj.net.mode = 'test';
        end;
        state.allBatchInds = obj.imdb.getAllBatchInds();
        
        obj.stats.(datasetMode)(epoch) = obj.processEpoch(obj.net, state);
    end
    
    % Save current snapshot
    obj.saveState(modelPath(epoch));
    
    % Plot statistics
    if obj.nnOpts.plotEval
        plotAccuracy = isfield(obj.stats.val, 'accuracy') && obj.nnOpts.plotAccuracy;
        obj.plotStats(1:epoch, obj.stats, plotAccuracy);
        
        drawnow;
        print(1, modelFigPath, '-dpdf'); %#ok<MCPRT>
    end
end