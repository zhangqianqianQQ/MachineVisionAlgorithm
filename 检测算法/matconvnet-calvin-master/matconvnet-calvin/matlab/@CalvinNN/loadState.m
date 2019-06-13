function[net, stats] = loadState(fileName)
% [net, stats] = loadState(fileName)
%
% Loads a training snapshot of the network.
%
% Copyright by Matconvnet
% Modified by Holger Caesar, 2015

netStruct = load(fileName, 'net', 'stats');
net = dagnn.DagNN.loadobj(netStruct.net);
stats = netStruct.stats;