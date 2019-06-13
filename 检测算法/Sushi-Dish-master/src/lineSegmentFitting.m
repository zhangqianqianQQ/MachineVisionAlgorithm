% lineSegmentFitting extracts LineSegments from each EdgeContour.
% Input     - EdgeContours : The list of Edge Contours.
%           - DeviationThreshold : The threshold chosen to determine how
%                       close the line segments fit on to the edge contour.
% output    - SegmentList : The list of Segments. Each of them corresponds
%                          to each Edge Contour.
function SegmentList = lineSegmentFitting(EdgeContours, DeviationThreshold)

%% Initialize
NumberOfContours = length(EdgeContours);
SegmentList = cell(1,NumberOfContours);

%% Exctrace Line Segemnts from each Edge Contour.
for i =1:NumberOfContours
    EdgePoints = EdgeContours{i};
    LastIndex = length(EdgePoints);
    LastPoint = EdgePoints(LastIndex,:);
    LineSegments = [extractLinearCue(EdgePoints, DeviationThreshold);
        LastPoint];
    SegmentList{i} = LineSegments;
end

end

% extractLinearCue transforms the point-wise Edge Contour into
% the piece-wise linear segments.
% Input     - EdgePoints : The subset points of EdgeContour which will be
%                         transformed into the LineSegment
%           - DeviationThreshold : The threshold chosen to determine how
%                       close the line segments fit on to the edge contour.
% output    - LineSegments : The Line Segments extracted from edge points.
%                           For efficient recursion, It doesn't contain the
%                           last point.
% Example   - Given EdgePoints = [first, p_2, p_3, ..., p_n-1, last],
%             LineSegments could be [first, p_k1, p_k2, ..., p_km], (last)
%             , where k1 < k2 < ... < km
%               and each p_ki belongs to p_j for 2<=j<=n-1
function LineSegments = extractLinearCue(EdgePoints, DeviationThreshold)
%% Initialize
EdgeLength = length(EdgePoints);

% Initialize first and last points.
FirstPoint = EdgePoints(1,:);
LastPoint = EdgePoints(EdgeLength,:);

% If EdgePoints contains only two points, which are first and last,
% return only first point. (Since we remove the last point from the output)
if EdgeLength == 2
    LineSegments = FirstPoint;
else
    
    
    max_d = 0;
    
    % Find maximum deviation
    for i = 2:EdgeLength-1
        CurPoint = EdgePoints(i,:);
        % The deviation di for Point i is denoted :
        % di = | xi(y1-yn)+yi(xn-x1)+ynx1-y1xn |/sqrt((y1-yn)^2+(xn-x1)^2)
        d = abs( CurPoint(2)*(FirstPoint(1)-LastPoint(1)) + ...
            CurPoint(1)*(LastPoint(2)-FirstPoint(2)) + ...
            LastPoint(1)*FirstPoint(2) - FirstPoint(1)*LastPoint(2) ) / ...
            sqrt((FirstPoint(1)-LastPoint(1))^2 + (LastPoint(2)-FirstPoint(2))^2);
        
        % Compare di with maximum value
        if max_d < d
            max_d = d;
            max_idx = i;
            
        end
    end
    
    % If the maximum deviation is smaller than the Threshold,
    % consider FirstPoint-LastPoint as one line segment.
    % Since we remove the last point from the output, return only
    % first point.
    if max_d < DeviationThreshold
        LineSegments = FirstPoint;
    else
        LeftEdgePoints = EdgePoints(1:max_idx,:);
        RightEdgePoints = EdgePoints(max_idx:EdgeLength,:);
        LineSegments = [ extractLinearCue(LeftEdgePoints, DeviationThreshold) ;
            extractLinearCue(RightEdgePoints, DeviationThreshold)];
    end
    
end
end