function insertLayer(obj, leftLayerName, rightLayerName, newLayerName, newBlock, addInputs, addOutputs, newParams)
% insertLayer(obj, leftLayerName, rightLayerName, newLayerName, newBlock, [addInputs], [addOutputs], [newParams])
%
% Takes a DAG and inserts a new layer before an existing layer.
% The outputs of the previous layer and inputs of the following layer are
% adapted accordingly.
%
% Copyright by Holger Caesar, 2015

% Find the old layers and their outputs/inputs
leftLayerIdx = obj.getLayerIndex(leftLayerName);
rightLayerIdx = obj.getLayerIndex(rightLayerName);
leftLayer = obj.layers(leftLayerIdx);
rightLayer = obj.layers(rightLayerIdx);
leftOutputs = leftLayer.outputs;
rightInputs = rightLayer.inputs;

% Check whether left and right are actually connected
assert(leftLayerIdx ~= rightLayerIdx);

% Introduce new free variables for new layer outputs
rightInputs = replaceVariables(obj, rightInputs);

% Change the input of the right layer (to avoid cycles)
obj.layers(rightLayerIdx).inputs = rightInputs;

newInputs = leftOutputs;

% % % Automatic filtering is problematic for different variable names, do
% % % everything manually!
% % % newOutputs = rightInputs;

% Remove special inputs from rightInputs (i.e. labels)
newOutputs = regexp(rightInputs, '^(x\d+)', 'match', 'once');
newOutputs = newOutputs(~cellfun(@isempty, newOutputs));

% Adapt inputs, outputs and params
if exist('addInputs', 'var') && ~isempty(addInputs),
    newInputs = [newInputs, addInputs];
end;
if exist('addOutputs', 'var') && ~isempty(addOutputs),
    newOutputs = [newOutputs, addOutputs];
end;
if ~exist('newParams', 'var') || isempty(newParams),
    newParams = {};
end;

% Add the new layer
obj.addLayer(newLayerName, newBlock, newInputs, newOutputs, newParams);
