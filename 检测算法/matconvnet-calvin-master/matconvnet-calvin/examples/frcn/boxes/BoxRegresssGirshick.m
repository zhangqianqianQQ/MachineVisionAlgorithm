function regressedBox = BoxRegresssGirshick(box, regressionFactor)
% regressedBox = BoxRegresss(box, regressionFactor)
%
% Apply the regressionFactor to the box to get better bounding box
% Regression factors are Girshick-style
%
% box:              N x 4 vector with BB coordinates
% regressionFactor: N x 4 vector with regression factors
%
% regressedBox:     N x 4 vector with updated BB coordinates
%
% Jasper Uijlings - 2015

% Undo zero-mean regression targets (numbers empirically determined on Pascal VOC)
regressionFactor = bsxfun(@times, regressionFactor, [0.1131 0.1277 0.2173 0.2173]);

% Obtain middle and width
middleR = (box(:,1) + box(:,3)) / 2;
middleC = (box(:,2) + box(:,4)) / 2;
[boxR, boxC] = BoxSize(box);

% Get new box middles
newMiddleR = middleR + regressionFactor(:,1) .* boxR;
newMiddleC = middleC + regressionFactor(:,2) .* boxC;

% Get new width
newBoxR = boxR .* exp(regressionFactor(:,3));
newBoxC = boxC .* exp(regressionFactor(:,4));

% Get actual boxes
regressedBox(:,4) = newMiddleC + (newBoxC-1) ./ 2;
regressedBox(:,3) = newMiddleR + (newBoxR-1) ./ 2;
regressedBox(:,2) = newMiddleC - (newBoxC-1) ./ 2;
regressedBox(:,1) = newMiddleR - (newBoxR-1) ./ 2;
