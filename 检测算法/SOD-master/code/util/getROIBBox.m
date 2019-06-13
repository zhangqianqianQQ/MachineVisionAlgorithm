%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Translate the coordinates back into the 
% original image.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function B = getROIBBox(B, roi)

ratio = (roi([3 4]) - roi([1 2]))';
B = bsxfun(@times, B, ratio([1 2 1 2])');
B = bsxfun(@plus, B, roi([1 2 1 2]));