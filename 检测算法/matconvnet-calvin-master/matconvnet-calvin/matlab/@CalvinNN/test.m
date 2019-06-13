function[stats] = test(obj)
% [stats] = test(obj)
%
% Test function
% - Does a single processing of an epoch for testing
% - Uses the nnOpts.testFn function for the testing (inside process_epoch)
% - Automatically changes softmaxloss to softmax, removes hinge loss. Other losses are not yet supported
%
% Copyright by Jasper Uijlings, 2015
% Modified by Holger Caesar, 2016

% Check that we only use one GPU
numGpus = numel(obj.nnOpts.gpus);
assert(numGpus <= 1);

% Replace softmaxloss layer with softmax layer
softMaxLossIdx = obj.net.getLayerIndex('softmaxloss');
if ~isnan(softMaxLossIdx)
    softmaxlossInput = obj.net.layers(softMaxLossIdx).inputs{1};
    obj.net.removeLayer('softmaxloss');
    obj.net.addLayer('softmax', dagnn.SoftMax(), softmaxlossInput, 'scores', {});
    softmaxIdx = obj.net.layers(obj.net.getLayerIndex('softmax')).outputIndexes;
    assert(numel(softmaxIdx) == 1);
end

% Remove hinge loss layer
hingeLossIdx = obj.net.getLayerIndex('hingeloss');
if ~isnan(hingeLossIdx)
    theInputs = obj.net.layers(hingeLossIdx).inputs;
    finalLayerOutputIdx = find(ismember(theInputs, {'label'}) == 0);
    assert(numel(finalLayerOutputIdx) == 1);
    finalLayerOutputName = obj.net.layers(hingeLossIdx).inputs{finalLayerOutputIdx};
    obj.net.removeLayer('hingeloss');
    obj.net.renameVar(finalLayerOutputName, 'scores');
end

% Set datasetMode in imdb
datasetMode = 'test';
obj.net.mode = datasetMode; % Disable dropout
obj.imdb.setDatasetMode(datasetMode);
state.epoch = 1;
state.allBatchInds = obj.imdb.getAllBatchInds();

% Process the epoch
obj.stats.(datasetMode) = obj.processEpoch(obj.net, state);

% The stats are the desired results
stats = obj.stats.(datasetMode);