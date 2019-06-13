function AddNeighbors( imageRowCount, imageColCount, row, col, neighborhoodType, neighborList, visitedMatrix )
%ADDNEIGHBORS Adding 
%   Detailed explanation goes here

    if row < 1 || row > imageRowCount || col < 1 || col > imageColCount
        return;
    end
    
    % Left Neighbor
    AddNeighborToList(imageRowCount, imageColCount, row, col - 1, neighborList, visitedMatrix);
    
    % Top Neighbor
    AddNeighborToList(imageRowCount, imageColCount, row - 1, col, neighborList, visitedMatrix);
    
    % Right Neighbor
    AddNeighborToList(imageRowCount, imageColCount, row, col + 1, neighborList, visitedMatrix);
    
    % Bottom Neighbor
    AddNeighborToList(imageRowCount, imageColCount, row + 1, col, neighborList, visitedMatrix);
    
    if neighborhoodType == 8
        
        % Top Left Neighbor
        AddNeighborToList(imageRowCount, imageColCount, row - 1, col - 1, neighborList, visitedMatrix);
        
        % Top Right Neighbor
        AddNeighborToList(imageRowCount, imageColCount, row - 1, col + 1, neighborList, visitedMatrix);
        
        % Bottom Right Neigbor
        AddNeighborToList(imageRowCount, imageColCount, row + 1, col + 1, neighborList, visitedMatrix);
        
        % Bottom Left Neighbor
        AddNeighborToList(imageRowCount, imageColCount, row + 1, col - 1, neighborList, visitedMatrix);
        
    end

end

function AddNeighborToList(imageRowCount, imageColCount, row, col, neighborList, visitedMatrix)

    if row < 1 || row > imageRowCount || col < 1 || col > imageColCount
        return;
    end
    
    if visitedMatrix(row, col) == 0
        neighborList.add([row col]);
    end

end