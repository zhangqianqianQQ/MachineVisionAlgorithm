function [model, pcamodel] = projectmodel(model, coeff, k)

% [model, pcamodel] = projectmodel(model, coeff, k)
%
% Project a model's filters onto the top k PCA eigenvectors
% stored in the columns of the matrix coeff.  The output
% variable 'model' holds the original model augmented to
% hold the PCA filters as extra data.  The output variable
% 'pcamodel' has its filters replaced with the PCA filters.

% take the top k eigenvectors from coeff as the projection matrix
coeff = coeff(:, 1:k);
% augment the projection matrix by adding a vector with all zeros ...
coeff = padarray(coeff, [1 1], 0, 'post');
% ... except in the last position to preserve the occlusion feature
coeff(end,end) = 1;
% save the projection matrix in the model
model.coeff = coeff;
% make a new model with projected filters
pcamodel = model;
for i = 1:model.numfilters
  w = model.filters(i).w;
  wpca = project(w, coeff);
  pcamodel.filters(i).w = wpca;
  model.filters(i).wpca = wpca;
  pcamodel.blocksizes(model.filters(i).blocklabel) = numel(wpca);
end
