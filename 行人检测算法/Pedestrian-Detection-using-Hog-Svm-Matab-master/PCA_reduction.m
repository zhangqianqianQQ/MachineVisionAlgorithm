function [reduced_features, Ureduce] = PCA_reduction(features, min_variance)
% PCA_REDUCTION applies PCA (Principal Component Analysis) to get the 
% most significant dimension of the data and reduces its dimension in
% such a way that 'min_variance' is retained in the final reduced matrix.
% Input: feature matrix, desired variance to retain.
% Output: reduced features, EigenVectors of the features matrix

%$ Author: Jose Marcos Rodriguez $ 
%$ Date: 09-Mar-2014 17:37:14 $ 
%$ Revision : 1.00 $ 
%% FILENAME  : PCA_reduction.m 


k = size(features, 2);      % initial features dimensions
m = size(features, 1);      % number of instances


%% Normalize and Compute variance matrix
features = bsxfun(@minus,features,(sum(features)./m));  % normalize
cov_matrix = 1/m .* features' * features;               % co-variance matrix

%% Singular Value Decomposition
[U,S,~] = svd(cov_matrix);
diagS = diag(S);

%% Find minimum k that satisfies variance preservation requirements
for i=1:size(diagS,1)
    variance = sum(diagS(1:i)) / sum(diagS);
    if variance > min_variance
        k = i;
        fprintf('variance: %d, componenets: %d\n', variance, k)
        break
    end
end

%% Reducing features dimension
Ureduce = U(:,1:k);
reduced_features = features*Ureduce;
whos('reduced_features')

end