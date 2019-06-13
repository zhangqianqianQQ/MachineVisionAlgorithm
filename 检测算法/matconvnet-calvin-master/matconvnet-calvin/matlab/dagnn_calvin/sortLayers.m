function sortLayers(net)
% sortLayers(net)
%
% Takes a DAG and sorts it's layers by execution order.
% For a linear chain this means that layers are sorted by occurrence.
% This change is purely cosmetic.
%
% Copyright by Holger Caesar, 2016

order = net.getLayerExecutionOrder();
net.layers = net.layers(order);
net.rebuild();