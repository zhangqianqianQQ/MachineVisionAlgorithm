function[pixelAccuracy, meanAccuracy, meanIU] = confMatToAccuracies(confusion)
% [pixelAccuracy, meanAccuracy, meanIU] = confMatToAccuracies(confusion)
%
% Compute accuracies from a confusion matrix.
%
% Copyright by Holger Caesar, 2016

% compute various statistics of the confusion matrix
total = sum(confusion(:));
pos = sum(confusion, 2);
res = sum(confusion, 1)';
tp = diag(confusion);
IUs = tp ./ (pos + res - tp);
missing = pos == 0;

% Modified metrics to ignore classes for which we didn't see
% any pixels yet in this epoch
pixelAccuracy = sum(tp) / total;
meanAccuracy = nanmean(tp ./ pos);
meanIU = mean(IUs(~missing));