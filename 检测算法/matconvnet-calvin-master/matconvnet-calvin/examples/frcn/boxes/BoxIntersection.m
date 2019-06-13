function intersection = BoxIntersection(a, b)
% intersection = BoxIntersection(a, b)
%
% Creates the intersection of two bounding box sets. Returns minus ones if
% there is no intersection
%
% a:            Input bonding boxes "a"
% b:            Input bounding boxes "b"
%   Note: size(a,1) == size(b,1) OR either size(a,1) = 1 or size(b,1) = 1
%
% intersection: Intersection of box a and b

intersection = [max(a(:,1),b(:,1)) max(a(:,2),b(:,2)) ...
                min(a(:,3),b(:,3)) min(a(:,4),b(:,4))];
                
[numRows, numColumns] = BoxSize(intersection);

% There is no intersection box
negIds = numRows < 1 | numColumns < 1;
intersection(negIds,:) = -1;


