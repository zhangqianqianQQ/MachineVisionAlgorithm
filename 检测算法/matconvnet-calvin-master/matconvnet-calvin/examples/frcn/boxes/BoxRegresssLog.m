function regressedBox = BoxRegresssLog(box, regressionFactor)
% regressedBox = BoxRegresss(box, regressionFactor)
%
% Apply the regressionFactor to the box to get better bounding box:
% regressedBox(4) = boxMiddle + 1/2 boxWidth + regressionFactor(4) * 1/2 boxWidth
%                 = boxMiddle + (1+regressionFactor(4)) * 1/2 boxWidth
%
% box:              N x 4 vector with BB coordinates
% regressionFactor: N x 4 vector with regression factors
%
% regressedBox:     N x 4 vector with updated BB coordinates
%
% In log-space, like Girshick
%
% Jasper Uijlings - 2015

% regressedBox(N) = boxMiddle + (1+regressionFactor(N)) * 1/2 boxWidth
regressionFactor = 2 * (exp(regressionFactor / 6.537) - 0.5);

% Obtain middle
middleOdd = (box(:,1) + box(:,3)) / 2;
middleEven = (box(:,2) + box(:,4)) / 2;

% Apply factors with respect to middle.
% regress coord = middle       + distance to middle      .* F 
regressedBox(:,4) = middleEven + (box(:,4) - middleEven) .* regressionFactor(:,4);
regressedBox(:,3) = middleOdd  + (box(:,3) - middleOdd)  .* regressionFactor(:,3);
regressedBox(:,2) = middleEven + (box(:,2) - middleEven) .* regressionFactor(:,2);
regressedBox(:,1) = middleOdd  + (box(:,1) - middleOdd)  .* regressionFactor(:,1);
