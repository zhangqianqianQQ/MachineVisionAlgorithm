function convertNetwork(obj)
% convertNetwork(obj)
%
% Converts a network from test to train, inserting lossed, dropout and
% adopting the classification layer.
%
% Copyright by Holger Caesar, 2015

fprintf('Converting test network to train network (dropout, loss, etc.)...\n');

% Add dropout layers after relu6 and relu7
fprintf('Adding dropout to network...\n');
dropout6Layer = dagnn.DropOut();
dropout7Layer = dagnn.DropOut();
insertLayer(obj.net, 'relu6', 'fc7', 'dropout6', dropout6Layer);
insertLayer(obj.net, 'relu7', 'fc8', 'dropout7', dropout7Layer);

% Rename variable prob to x%d+ style to make insertLayer work
% (Required for beta18 or later matconvnet default networks)
predVarIdx = obj.net.getVarIndex('prediction');
if ~isnan(predVarIdx)
    freeVarName = getFreeVariable(obj.net);
    obj.net.renameVar('prediction', freeVarName);
end

% Replace softmax with correct loss for training (default: softmax)
switch obj.nnOpts.lossFnObjective
    case 'softmaxlog'
        softmaxlossBlock = dagnn.LossWeighted('loss', 'softmaxlog');
        replaceLayer(obj.net, 'prob', 'softmaxloss', softmaxlossBlock, 'label');
        objectiveName = obj.net.layers(obj.net.getLayerIndex('softmaxloss')).outputs;
        obj.net.renameVar(objectiveName, 'objective');
    case 'hinge'
        hingeLossBlock = dagnn.Loss('loss', 'hinge');
        replaceLayer(obj.net, 'prob', 'hingeloss', hingeLossBlock, 'label');
        objectiveName = obj.net.layers(obj.net.getLayerIndex('hingeloss')).outputs;
        obj.net.renameVar(objectiveName, 'objective');
    otherwise
        error('Unknown loss specified');
end

% Adapt number of classes in softmaxloss layer from 1000 to numClasses
fc8Idx = obj.net.getLayerIndex('fc8');
obj.net.layers(fc8Idx).block.size(4) = obj.imdb.numClasses;
newParams = obj.net.layers(fc8Idx).block.initParams();
obj.net.params(obj.net.layers(fc8Idx).paramIndexes(1)).value = newParams{1} / std(newParams{1}(:)) * 0.01; % Girshick initialization
obj.net.params(obj.net.layers(fc8Idx).paramIndexes(2)).value = newParams{2}';

% Rename input
if ~isnan(obj.net.getVarIndex('x0'))
    % Input variable x0 is renamed to input
    obj.net.renameVar('x0', 'input');
else
    % Input variable already has the correct name
    assert(~isnan(obj.net.getVarIndex('input')));
end

% Modify for Fast Rcnn (ROI pooling, bbox regression etc.)
if obj.nnOpts.fastRcnn
    obj.convertNetworkToFastRcnn();
end