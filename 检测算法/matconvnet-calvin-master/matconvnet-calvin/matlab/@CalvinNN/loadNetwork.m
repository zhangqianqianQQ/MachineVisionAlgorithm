function loadNetwork(obj, netIn)
% loadNetwork(obj, netIn)
%
% Loads a network and converts it into DAG format.
%
% Network can be:
%  - DAG (netIn.net, [netIn.stats] or netIn.layers, netIn.vars, ...)
%  - SimpleNN (netIn.layers, [netIn.normalization] , ...)
%  - Path to any of the above

% Load the network from file if necessary
if ischar(netIn),
    netIn = load(netIn);
end

% Convert the network
if isfield(netIn, 'net')
    if isa(netIn.net, 'dagnn.DagNN')
        % DagNN as class object
        obj.net = netIn.net;
    else
        % Any network as struct
        % Recurse on the net structure
        obj.loadNetwork(netIn.net);
    end
    
    % Load stats of a snapshot
    if isfield(netIn, 'stats')
        obj.stats = netIn.stats;
    end;
elseif isfield(netIn, 'vars')
    % DagNN as struct: Only DAG formats have the 'vars' field
    obj.net = dagnn.DagNN.loadobj(netIn);
    
elseif isfield(netIn, 'layers') && iscell(netIn.layers)
    % SimpleNN as struct
    % Convert SimpleNN to DagNN
    obj.net = dagnn.DagNN.fromSimpleNN(netIn);
else
    error('Error: Network is neither in SimpleNN nor DAG format!');
end

% Remove unused/incorrect meta fields from old network
if isprop(obj.net, 'meta')
    if isfield(obj.net.meta, 'normalization')
        fields = {'keepAspect', 'border', 'imageSize', 'interpolation'};
        for i = 1 : numel(fields)
            fieldName = fields{i};
            if isfield(obj.net.meta.normalization, fieldName)
                obj.net.meta.normalization = rmfield(obj.net.meta.normalization, fieldName);
            end
        end
    end
    if isfield(obj.net.meta, 'classes')
        obj.net.meta = rmfield(obj.net.meta, 'classes');
    end
end