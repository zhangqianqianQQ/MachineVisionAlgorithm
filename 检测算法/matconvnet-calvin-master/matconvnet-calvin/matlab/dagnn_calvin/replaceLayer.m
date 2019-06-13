function replaceLayer(obj, layerName, newLayerName, newBlock, addInputs, addOutputs, addParams, removeOldInputs)
% replaceLayer(obj, layerName, newLayerName, newBlock, [addInputs], [addOutputs], [addParams], [removeOldInputs])
%
% Takes a DAG and replaces an existing layer with a new one.
% If not specified, the inputs, outputs and params are reused from the
% previous layer.
%
% Copyright by Holger Caesar, 2015

% Default settings
if ~exist('removeOldInputs', 'var') || isempty(removeOldInputs),
    removeOldInputs = false;
end;

% Find the old layer
layerIdx = obj.getLayerIndex(layerName);
layer = obj.layers(layerIdx);

% Keep old settings (or not)
if removeOldInputs
    newInputs = {};
else
    newInputs = layer.inputs;
end
newOutputs = layer.outputs;
newParams  = layer.params;

% Add new settings
if exist('addInputs', 'var') && ~isempty(addInputs)
    newInputs = [newInputs, addInputs];
end
if exist('addOutputs', 'var') && ~isempty(addOutputs)
    newOutputs = [newOutputs, addOutputs];
end
if exist('addParams', 'var') && ~isempty(addParams)
    newParams = [newParams, addParams];
end

% Remove the old layer (must come before add to avoid conflicts)
obj.removeLayer(layerName);

% Add the new layer
obj.addLayer(newLayerName, newBlock, newInputs, newOutputs, newParams);