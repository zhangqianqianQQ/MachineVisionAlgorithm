function W = FormingConvFilter(Datacube,ConvFilter,num_of_filters)
% For each pixel in the Datacube, extract a small
% cube: ConvFilter(Height*Width*Channel), vectorizing into a column vector
% For all pixels in the Datacube, performing PCA/WPCA to gather
% num_of_filters eigenvecs, then transforming each eigenvecs which corresponds to
% a column of W into a small cube as our 3D ConvFilter.

X = im2colstep(Datacube,[ConvFilter.PatchSize,ConvFilter.PatchSize,ConvFilter.Channel]); % Dominated by column to extract
mu = mean(X,2); 
% mu = mean(X,1);
X = bsxfun(@minus, X, mu);
Rx = X*X'/size(X,2);
[E,D] = eig(Rx);
[~, ind] = sort(diag(D),'descend');
% W = E(:,ind(1:num_of_filters));  % principal eigenvectors
W = E(:,ind(1:3));
% WPCA
% D = diag(D);
% D = D(ind(1:num_of_filters));
% W = bsxfun(@rdivide,W,sqrt(D)');

% W = cell(num_of_filters,1);
% for i=1:size(V,2)
%     W{i} = reshape(V(:,i),[Height,Width,Channel]);
% end