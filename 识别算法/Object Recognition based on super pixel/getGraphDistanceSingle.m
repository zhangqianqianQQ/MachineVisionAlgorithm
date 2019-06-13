%
% Takes labelGraph which is the graph obtained from getLabelGraph method.
% From is the node you are, to is the node you will go. It will return you
% distance between these two nodes. 
%

function [dist] = getGraphDistanceSingle(labelGraph,from,to)
    path = shortestpath(labelGraph,from,to);
    dist = length(path) - 1;
end

