function geoDist = GeodesicSaliency(adjcMatrix, bdIds, colDistM, clip_value, doRenorm,un)

spNum = size(adjcMatrix, 1);

bgIds = bdIds;
% Calculate pair-wise geodesic distance
adjcMatrix(bdIds, bdIds) = 1;
[row,col] = find(adjcMatrix);

% Here we add a virtual background node which is linked to all background
% super-pixels with 0-cost. To do this, we padding an extra row and column 
% to adjcMatrix_lb, and get adjcMatrix_virtual.
adjcMatrix_virtual = sparse([row; repmat(spNum + 1, [length(bgIds), 1]); bgIds], ...
    [col; bgIds; repmat(spNum + 1, [length(bgIds), 1])], 1, spNum + 1, spNum + 1);
if ~isempty(un)
     adjcMatrix_virtual(un,1:end-1)=0;
     adjcMatrix_virtual(1:end-1,un)=0;
end
% Specify edge weights for the new graph
colDistM_virtual = zeros(spNum+1);
colDistM_virtual(1:spNum, 1:spNum) = colDistM;

adjcMatrix_virtual = tril(adjcMatrix_virtual, -1);
edgeWeight = colDistM_virtual(adjcMatrix_virtual > 0);
edgeWeight = max(0, edgeWeight - clip_value);
geoDist = graphshortestpath(sparse(adjcMatrix_virtual), spNum + 1, 'directed', false, 'Weights', edgeWeight);
geoDist = geoDist(1:end-1); % exclude the virtual background node

%re-normalize saliency map, normalize saliency value of the top 1% pixels to 1
topRate = 0.01;
if doRenorm
    tmp = sort(geoDist, 'descend');
    pos = round(topRate * length(tmp));
    maxVal = tmp(pos);
    geoDist = geoDist / maxVal; %minVal = 0
    geoDist(geoDist > 1) = 1;
end