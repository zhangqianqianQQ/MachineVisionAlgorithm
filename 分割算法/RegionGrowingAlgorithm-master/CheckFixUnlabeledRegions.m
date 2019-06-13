function [ regionMatrix ] = CheckFixUnlabeledRegions( regionMatrixInput )
%CHECKFIXUNLABELEDREGIONS Summary of this function goes here
%   Detailed explanation goes here

    regionMatrix = regionMatrixInput;

    [zeroRows, zeroCols] = find(regionMatrixInput == 0);

    for ii = 1 : numel(zeroRows)
        
        [isCandidate, region] = IsZeroSeedCandidate(regionMatrixInput, zeroRows(ii), zeroCols(ii));
            
        if ~isCandidate
            regionMatrix(zeroRows(ii), zeroCols(ii)) = region;
        end
        
    end

end

function [ isCandidate, region ] = IsZeroSeedCandidate(regionMatrix, zeroRow, zeroCol)

import java.util.ArrayDeque;
neighbor_List = ArrayDeque();

[r, c] = size(regionMatrix);

visitedMatrix = zeros(r, c);

AddNeighbors(r, c, zeroRow, zeroCol, 8, neighbor_List, visitedMatrix);

regionLabels = [];

while ~neighbor_List.isEmpty()
    neighborData = neighbor_List.pop();
    regionLabels = [regionLabels regionMatrix(neighborData(1), neighborData(2))];
end

% regionLabels = [];
% 
% % Left Neighbor
% regionLabels = [regionLabels regionMatrix(zeroRow, zeroCol - 1)];
% 
% % Top Neighbor
% regionLabels = [regionLabels regionMatrix(zeroRow - 1, zeroCol)];
% 
% % Right Neighbor
% regionLabels = [regionLabels regionMatrix(zeroRow, zeroCol + 1)];
% 
% % Bottom Neighbor
% regionLabels = [regionLabels regionMatrix(zeroRow + 1, zeroCol)];
% 
% % Top Left Neighbor
% regionLabels = [regionLabels regionMatrix(zeroRow - 1, zeroCol - 1)];
% 
% % Top Right Neighbor
% regionLabels = [regionLabels regionMatrix(zeroRow - 1, zeroCol + 1)];
% 
% % Bottom Right Neigbor
% regionLabels = [regionLabels regionMatrix(zeroRow + 1, zeroCol + 1)];
% 
% % Bottom Left Neighbor
% regionLabels = [regionLabels regionMatrix(zeroRow + 1, zeroCol - 1)];

region = mode(regionLabels);

[rows, cols] = find(regionLabels == 0);

if numel(rows) > 3
    isCandidate = 1;
else
    isCandidate = 0;
end



end
