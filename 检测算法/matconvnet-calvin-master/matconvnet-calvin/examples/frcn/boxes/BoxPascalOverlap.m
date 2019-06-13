function scores = BoxPascalOverlap(targetBox, testBoxes)
% scores = PascalOverlap(targetBox, testBoxes)
%
% Function obtains the pascal overlap scores between the targetBox and
% all testBoxes
%
% targetBox:            1 x 4 array containing target box
% testBoxes:            N x 4 array containing test boxes
%
% scores:               N x 1 array containing for each testBox the pascal
%                       overlap score.

intersectBoxes = BoxIntersection(targetBox, testBoxes);
overlapI = intersectBoxes(:,1) ~= -1; % Get which boxes overlap

% Intersection size
[~, ~, intersectionSize] = BoxSize(intersectBoxes(overlapI,:));

% Union size
[~, ~, testBoxSize] = BoxSize(testBoxes(overlapI,:));
[~, ~, targetBoxSize] = BoxSize(targetBox);
unionSize = testBoxSize + targetBoxSize - intersectionSize;

scores = zeros(size(testBoxes,1),1);
scores(overlapI) = intersectionSize ./ unionSize;
