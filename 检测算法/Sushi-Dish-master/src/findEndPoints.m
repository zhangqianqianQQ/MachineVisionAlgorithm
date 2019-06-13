% findEndPoints finds all end points of given Edge Map.
% Input     - EdgeMap : Preprocessed Edge Map.
% Output    - re : The list of row position of end points.
%             ce : The list of column position of end points.
function [re, ce] = findEndPoints(EdgeMap)

re = [];
ce = [];

[r, c] = size(EdgeMap);
for i = 1:r
    for j = 1:c
        if checkEndPoint (EdgeMap, i, j)
            re = [re; i];
            ce = [ce; j];
        end
    end
end
end

% checkEndPoint checks if the point of given position (r,c ) is the end
%               point in Edge Map.
% Input     - EdgeMap : Preprocessed Edge Map.
%           - r : Row position of the point.
%           - c : Column position of the point.
% Output    - bool : True if the point of given position is end point
%                   , which means it has only one neighbor.
function bool = checkEndPoint(EdgeMap, r, c)

% Return false if the point doesn't exist in Edge Map.
if EdgeMap(r,c) == 0
    bool = false;
    return;
else
    [ROW, COL] = size(EdgeMap);
    
    % Check 8-directional neighbors.
    rOffset = [-1 -1 -1 0 1 1 1 0];
    cOffset = [-1 0 1 1 1 0 -1 -1];
    rCheck = rOffset + r;
    cCheck = cOffset + c;
    
    % Build indices for neighbors which contained EdgeMap size.
    indices = find(rCheck>=1 & rCheck <= ROW & cCheck >=1 & cCheck <= COL);
    
    % Count the number of neighbors.
    NumberOfNeighbors = 0;
    for i=indices
        NumberOfNeighbors = NumberOfNeighbors + EdgeMap(rCheck(i),cCheck(i));
    end
    
    % Return true if it has only one neighbor.
    bool = NumberOfNeighbors == 1;
end

end
