function [scores, index] = BoxBestOverlap(targetBoxes, testBoxes)
% [scores, index] = BoxBestOverlap(targetBoxes, testBoxes)
% 
% Get overlap scores (Pascal-wise) for testBoxes bounding boxes
%
% gtBoxes:        N x 4 Target bounding boxes
% testBoxes:      M x 4 Test bounding boxes
%
% scores:         M x 1 Highest overlap scores for each test bounding box
% index:          M x 1 Index for each testBoxes box which target box is best

numGT = size(targetBoxes,1);
numTest = size(testBoxes,1);

scoreM = zeros(numTest, numGT);

for j=1:numGT
    scoreM(:,j) = BoxPascalOverlap(targetBoxes(j,:), testBoxes);
end

[scores, index] = max(scoreM, [], 2);


