function regressionTarget = BoxRegressionTargetGirshick(gtBox, trainBox)
% regressionTarget = BoxRegressionTarget(gtBox, trainBox)
%
% Obtain regression factors as specified by Girshick. The first two coordinates
% represent the offset wrt the middle of the box. The last two coordinates
% represent the scaling of the box in log-space.
%
% gtBox:            N x 4 OR 1 x 4 vector with target BB coordinates
% trainBox:         N x 4 OR 1 x 4 vector with train BB coordinates
%
% regressionTarget: N x 4 vector with regression factors for each trainBox
%
% Jasper Uijlings - 2015

% Extract widths and middles (in Row and Col direction)
[trainR, trainC] = BoxSize(trainBox);
[gtR, gtC] = BoxSize(gtBox);
middleR  = (trainBox(:,1) + trainBox(:,3)) / 2;
middleC = (trainBox(:,2) + trainBox(:,4)) / 2;
middleRGt  = (gtBox(:,1) + gtBox(:,3)) / 2;
middleCGt = (gtBox(:,2) + gtBox(:,4)) / 2;

% Get scaling factors
regressionTarget(:,4) = log(gtC ./ trainC);
regressionTarget(:,3) = log(gtR ./ trainR);

% Get offset
regressionTarget(:,2) = (middleCGt - middleC) ./ trainC;
regressionTarget(:,1) = (middleRGt - middleR) ./ trainR;

% We want zero-mean regression targets. Empirically determined on Pascal VOC 2007
% regressionTarget = regressionTarget - 1;
regressionTarget = bsxfun(@rdivide, regressionTarget, [0.1131 0.1277 0.2173 0.2173]);


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
