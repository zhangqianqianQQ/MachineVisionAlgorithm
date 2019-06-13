function regressionTarget = BoxRegressionTarget(gtBox, trainBox)
% regressionTarget = BoxRegressionTarget(gtBox, trainBox)
%
% Obtain regression factors in terms of four scalars with respect to the centre box
% Jasper: This is a simplified and more intuitive way of doing BB regression than
% what is proposed by Girshick. Regression factors of 0 means no scaling.
% Note that gtBox = BoxRegresss(trainBox, regressTarget)
% gtBox(1) = trainBoxCenter - 1/2 trainBoxWidth + F * 1/2 trainBoxWidth
%
%
% gtBox:            N x 4 OR 1 x 4 vector with target BB coordinates
% trainBox:         N x 4 OR 1 x 4 vector with train BB coordinates
%
% regressionTarget: N x 4 vector with regression factors for each trainBox
%
% Jasper Uijlings - 2015

% Get middles
middleOdd  = (trainBox(:,1) + trainBox(:,3)) / 2;
middleEven = (trainBox(:,2) + trainBox(:,4)) / 2;

% Get scaling factors
regressionTarget(:,4) = (gtBox(:,4) - middleEven) ./ (trainBox(:,4) - middleEven);
regressionTarget(:,3) = (gtBox(:,3) - middleOdd)  ./ (trainBox(:,3) - middleOdd);
regressionTarget(:,2) = (gtBox(:,2) - middleEven) ./ (trainBox(:,2) - middleEven);
regressionTarget(:,1) = (gtBox(:,1) - middleOdd)  ./ (trainBox(:,1) - middleOdd);

% We want zero-mean regression targets.
regressionTarget = regressionTarget - 1;


%%% Debugging function
% function test
% 
% figure(1); clf;
% 
% gtBox = [0 300 100 500];
% 
% drawBoxes(gtBox, 1, 'r');
% 
% trainBoxes = [0 300 100 500;
%               0 300 100 500];
%           
% displacement = 10;
% displacementDim = 2;
% trainBoxes(1,displacementDim) = trainBoxes(1,displacementDim) + displacement;
% trainBoxes(2,displacementDim) = trainBoxes(2,displacementDim) - displacement
%         
% rT = BoxRegressionTarget(gtBox, trainBoxes)
% BoxRegresss(trainBoxes, rT)
% 
%         
% drawBoxes(trainBoxes(1,:), 1, 'g-');
% drawBoxes(trainBoxes(2,:), 1, 'b-');
% 
% 
% function drawBoxes(boxes, figN, style)
% 
% figure(figN);
% hold on;
% 
% if nargin ~= 3
%     style = 'r-';
% end
% 
% for i=1:size(boxes,1)
%     box = boxes(i,:);
%     plot(box([1 1]), box([2 4]), style);
%     plot(box([3 3]), box([2 4]), style);
%     plot(box([1 3]), box([2 2]), style);
%     plot(box([1 3]), box([4 4]), style);
% end
