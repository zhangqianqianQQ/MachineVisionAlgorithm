function [X_norm] = featureNormalize(X,type)
%FEATURENORMALIZE Normalizes the features in X

%   FEATURENORMALIZE(X) returns a normalized version of X where
%   the mean value of each feature is 0 and the standard deviation
%   is 1. This is often a good preprocessing step to do when
%   working with learning algorithms.

if type==1
    mu = mean(X);
    X_norm = bsxfun(@minus, X, mu);
    sigma = std(X_norm);
    X_norm = bsxfun(@rdivide, X_norm, sigma);
elseif type==2
    minX = min(X);
    maxX = max(X);
    X_norm = bsxfun(@minus, X, minX);
    X_norm = bsxfun(@rdivide, X_norm, maxX-minX);
elseif type ==3
    minX = min(X);
    maxX = max(X);
    X_norm = bsxfun(@minus, X, minX);
    X_norm = bsxfun(@rdivide, X_norm, maxX-minX);
    X_norm = X_norm*0.8 + 0.1;
end

end
