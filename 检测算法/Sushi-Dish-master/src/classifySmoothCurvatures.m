% classifySmoothCurvatures classifies edges using Curvatures from given
% linearly segmented edge list so that every edge doesn't have a sudden
% change which is called sharp turn and a inflexion point.
% Input     - SegmentList : The list of edges which are linearly segmented.
%             SharpTurnThreshold : The threshold to decide sharp turn.
% Output    - SmoothCurvatures = The list of edges with Smooth Curvature.
%             Each of them doesn't have any sharp turn and inflexion point.
function SmoothCurvatures = classifySmoothCurvatures(SegmentList, SharpTurnThreshold)

%% Initialize
NumberOfEdges = length(SegmentList);

%% Detect edge portions with smooth curvatures for each edge.
EdgeIndex = 1;
while EdgeIndex <= NumberOfEdges
    
    % Take edge of number EdgeIndex.
    LineSegments = SegmentList{EdgeIndex};
    NumberOfPoints = length(LineSegments);
    
    % To deal with inflexion points, use the sign of the angle as direction.
    % It has 1 if positive, -1 if negative.
    direction = 0;
    
    % When this edge consists of multiple Line Segments.
    if NumberOfPoints >= 3
        
        % Check the angle theta at every middle point.
        for PointIndex = 2:NumberOfPoints-1
            
            % Calculate the angle between two vectors.
            va = LineSegments(PointIndex,:) - LineSegments(PointIndex-1,:);
            vb = LineSegments(PointIndex+1,:) - LineSegments(PointIndex,:);
            theta =  calcAngleBetweenTwoVectors2D (va, vb);
            
            % Deal with sharp turn
            if abs(theta) > SharpTurnThreshold
                
                % If this point is sharp turn, split the edge at this
                % point. To do that, replace this edge with
                % Left-portion-edge and insert the remaining edge at the
                % last of Segment list.
                SegmentList{EdgeIndex} = LineSegments(1:PointIndex,:);
                NumberOfEdges = NumberOfEdges + 1;
                SegmentList{NumberOfEdges} = LineSegments(PointIndex:NumberOfPoints,:);
                
                % After split, terminate the loop for this edge and
                % continue for the remaining edges.
                break;
            end
            
            % Deal with inflexion point
            if direction == 0
                if theta > 0
                    direction = 1;
                elseif theta < 0
                    direction = -1;
                end
            else
                % If theta has the opposite sign of the one of the previous
                % theta, regard this point as inflexion point.
                if direction * theta < 0
                    % If this point is inflexion, split the edge at this
                    % point. To do that, replace this edge with
                    % Left-portion-edge and insert the remaining edge at
                    % the last of Segment list.
                    SegmentList{EdgeIndex} = LineSegments(1:PointIndex,:);
                    NumberOfEdges = NumberOfEdges + 1;
                    SegmentList{NumberOfEdges} = LineSegments(PointIndex:NumberOfPoints,:);
                    
                    % After split, terminate the loop for this edge and
                    % continue for the remaining edges.
                    break;
                end
            end
        end
    end
    EdgeIndex = EdgeIndex + 1;
end

%% Collect the curved segments only by filtering out the line segments.
SmoothCurvatures = cell(1, 1);
CurveIndex = 0;
for SegIndex = 1 : length(SegmentList)
    Segment = SegmentList{SegIndex};
    if length(Segment) > 2
        CurveIndex = CurveIndex + 1;
        SmoothCurvatures{CurveIndex} = Segment;
    end
end

end

% calcAngleBetweenTwoVectors2D calculates the angle between two vectors.
% Since it is calculated using arctangent, it is relative, which means that
% this(va, vb) = - this(vb, ba)
% Input     - va : 2-dimensional vector based.
%             vb : 2-dimensional vector relatively compared.
% Output    - theta : Relative angle between va and vb.
function theta = calcAngleBetweenTwoVectors2D (va, vb)
theta = atan2d(va(1)*vb(2)-va(2)*vb(1),va(1)*vb(1)+va(2)*vb(2));
end