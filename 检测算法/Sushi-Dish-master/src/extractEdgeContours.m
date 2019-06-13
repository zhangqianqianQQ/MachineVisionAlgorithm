% extractEdgeContours extracts Edge Contours from given Edge Map.
% Input     - EdgeMap : Preprocessed Edge Map. There is no junction. Only
%                       endpoints, midpoints, and loops exist.
% output    - EdgeContours : The list of Edge Contours which longer than
%                           MinLengthOfEdge.
%                       ex) EdgeContours{i} is the i-th Edge Contour.
function EdgeContours = extractEdgeContours(EdgeMap)

%% Initialize
% Threshold for edge length.
MinLengthOfEdge = 10;

% For numbering every edge.
EdgeNumber = 0;

% Size of EdgeMap.
[ROW, COL] = size(EdgeMap);

% The list of points belonging to the same edge.
EdgePoints = [];

%% Build Edge Contour using end points

% Get the list of end points.
[re, ce] = findEndPoints(EdgeMap);
eLength = size(re);

% Offset for checking 8-directional neighbors.
rOffset = [-1 -1 -1 0 1 1 1 0];
cOffset = [-1 0 1 1 1 0 -1 -1];

% Build Edge Contour
for i = 1:eLength
    r = re(i); c = ce(i);
    
    % If this end point is not processed yet, start new edge.
    if EdgeMap(r,c) == 1
        EdgeNumber = EdgeNumber + 1;
    end
    
    % Until (r,c) reachs to the point processed.
    while EdgeMap(r,c) == 1
        
        % Process it following these steps:
        % 1. Remove this point from EdgeMap.
        % 2. Insert it into EdgePoints.
        EdgeMap(r,c) = 0;
        EdgePoints = [EdgePoints; r, c];
        
        % Check 8-directional neighbors.
        rCheck = rOffset + r;
        cCheck = cOffset + c;
        
        % Build indices for neighbors which contained EdgeMap size.
        indices = find(rCheck>=1 & rCheck <= ROW & cCheck >=1 & cCheck <= COL);
        
        % Check if there exists unprocessed neighbor.
        for j=indices
            if EdgeMap(rCheck(j), cCheck(j)) == 1
                r = rCheck(j);
                c = cCheck(j);
                break;
            end
        end
    end % End of EdgeNumber-th edge.
    
    % If the length of edge is short, do not insert it.
    if size(EdgePoints, 1) ~= 0 && size(EdgePoints, 1) < MinLengthOfEdge
        EdgeNumber = EdgeNumber - 1;
        EdgePoints = [];
    elseif size(EdgePoints, 1) > 0
        EdgeContours{EdgeNumber} = EdgePoints;
        EdgePoints = [];
    end
    
    
end

%% Build Edge Contours from loop.
% Only loops remain. To extract Edge Contour from loop, remove a arbitrary
% point in the loop and do the same process with previous step.

for i = 1:ROW
    for j = 1:COL
        
        % If (i,j) remains, which means it belongs to loop,
        % start process from this point.
        if EdgeMap(i,j) == 1
            
            r = i; c = j;
            EdgeNumber = EdgeNumber + 1;
            
            % Until (r,c) reachs to the point processed.
            while EdgeMap(r,c) == 1
                
                % Process it following these steps:
                % 1. Remove this point from EdgeMap.
                % 2. Insert it into EdgePoints.
                EdgeMap(r,c) = 0;
                EdgePoints = [EdgePoints; r, c];
                
                % Check 8-directional neighbors.
                rCheck = rOffset + r;
                cCheck = cOffset + c;
                
                % Build indices for neighbors which contained EdgeMap size.
                indices = find(rCheck>=1 & rCheck <= ROW & cCheck >=1 & cCheck <= COL);
                
                % Check if there exists unprocessed neighbor.
                for j=indices
                    if EdgeMap(rCheck(j), cCheck(j)) == 1
                        r = rCheck(j);
                        c = cCheck(j);
                        break;
                    end
                end
            end % End of EdgeNumber-th edge.
            
            % If the length of edge is short, do not insert it.
            if size(EdgePoints, 1) ~= 0 && size(EdgePoints, 1) < MinLengthOfEdge
                EdgeNumber = EdgeNumber - 1;
                EdgePoints = [];
            elseif size(EdgePoints, 1) > 0
                EdgeContours{EdgeNumber} = EdgePoints;
                EdgePoints = [];
            end
        end
    end
end

%% Throw error if there exists unprocessed point
if sum(sum(EdgeMap)) ~= 0
    error('Error. There exists unprocessed point in EdgeMap.')
end

end