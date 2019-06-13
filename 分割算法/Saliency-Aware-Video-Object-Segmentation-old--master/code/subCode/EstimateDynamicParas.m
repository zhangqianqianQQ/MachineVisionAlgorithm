function clipVal = EstimateDynamicParas(adjcMatrix, colDistM)
% Do statistics analysis on color distances between neighbor patches
spNum = size(adjcMatrix, 1);
adjcMatrix = double( (adjcMatrix * adjcMatrix + adjcMatrix) > 0 );  %Reachability matrix
adjcMatrix(1:spNum+1:end) = 0;
minDist = zeros(spNum, 1);      %minDist(i) means the min distance from sp_i to its neighbors
for id = 1:spNum
    isNeighbor = adjcMatrix(id,:) > 0;
    minDist(id) = min(colDistM(id, isNeighbor));
end
clipVal = mean(minDist);

