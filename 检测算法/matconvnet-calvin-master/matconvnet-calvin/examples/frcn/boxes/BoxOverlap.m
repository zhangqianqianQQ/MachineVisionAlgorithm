function [IoU, IoA, IoB] = BoxOverlap(boxesA, boxesB)
% scores = BoxOverlap(boxesA, boxesB)
% Get overlap scores between boxesA and boxesB.
% boxesA and boxesB must be of the same length or one of the two
% must be a single box. In the latter case this single box is compared to 
% all boxes of the other argument
%
% boxesA:       Nx4 OR 1x4 matrix containing boxes
% boxesB:       Nx4 OR 1x4 matrix containing boxes
%
% IoU:          Nx1 IoU scores per comparison
% IoA:          Nx1 IoA scores per comparison
% IoB:          Nx1 IoB scores per comparison
%
% Note: IoA is intersection divided by size of A

% Get intersection of the boxes
intersectBox = BoxIntersection(boxesA, boxesB);
goodIdx = intersectBox(:,1) ~= -1; % find where boxes overlap

[~, ~, intersectSize] = BoxSize(intersectBox(goodIdx,:));



% Get area of boxesA and boxesB
% If statement deals with multiple/single boxes in argument
if size(boxesA,1) == 1
    [~, ~, sizeBoxesA] = BoxSize(boxesA);
else
    [~, ~, sizeBoxesA] = BoxSize(boxesA(goodIdx,:));
end

if size(boxesB,1) == 1
    [~, ~, sizeBoxesB] = BoxSize(boxesB);
else
    [~, ~, sizeBoxesB] = BoxSize(boxesB(goodIdx,:));
end

% Union = sizeBoxA + sizeBoxB - intersection(A,B)
IoU = zeros(size(intersectBox,1),1);
IoU(goodIdx,:) = intersectSize ./ (sizeBoxesA + sizeBoxesB - intersectSize);

IoA = zeros(size(intersectBox,1),1);
IoA(goodIdx,:) = intersectSize ./ sizeBoxesA;

IoB = zeros(size(intersectBox,1),1);
IoB(goodIdx,:) = intersectSize ./ sizeBoxesB;