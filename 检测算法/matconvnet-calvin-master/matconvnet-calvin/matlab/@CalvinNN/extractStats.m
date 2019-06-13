function stats = extractStats(net, ~)
% stats = extractStats(net)
%
% Extract all losses from the network.

sel = find(cellfun(@(x) isa(x, 'dagnn.Loss'), {net.layers.block}));
stats = struct();
for i = 1:numel(sel)
  stats.(net.layers(sel(i)).outputs{1}) = net.layers(sel(i)).block.average;
end