function [Zpca T U mu eigVecs] = myPCA(Z,r)
%--------------------------------------------------------------------------
% Syntax:       Zpca = myPCA(Z,r);
%               [Zpca T U mu] = myPCA(Z,r);
%               [Zpca T U mu eigVecs] = myPCA(Z,r);
%               
% Inputs:       Z is an (d x n) matrix containing n samples of a
%               d-dimensional random vector
%               
%               r is the desired number of principal components
%               
% Outputs:      Zpca is a (r x n) matrix containing the r principal
%               components - scaled to variance 1 - of the input samples
%               
%               U and T are the PCA transformation matrices such that
%               Zr = U / T * Zpca + repmat(mu,1,n);
%               is the r-dimensional PCA approximation of Z
%               
%               mu is the (d x 1) sample mean of Z
%               
%               eigVecs is a (d x r) matrix containing the scaled
%               eigenvectors of the sample covariance of Z
%               
% Description:  This function performs principal component analysis (PCA)
%               on the input samples
%               
% Author:       Brian Moore
%               brimoor@umich.edu
%               
% Date:         April 26, 2015
%--------------------------------------------------------------------------

% Center data
[Zc mu] = myCenter(Z);

% Compute truncated SVD
%[U S V] = svds(Zc,r); % Equivalent, but usually slower than svd()
[U S V] = svd(Zc,'econ');
U = U(:,1:r);
S = S(1:r,1:r);
V = V(:,1:r);

% Compute principal components
Zpca = S * V';
%Zpca = U' * Zc; % Equivalent but slower

% Whiten data, if desired
%[Zpca T] = myWhiten(Zpca);
T = eye(r); % No whitening

% Return scaled eigenvectors, if necessary
if (nargout >= 5)
    [~,n] = size(Z);
    eigVecs = bsxfun(@times,U,diag(S)' / sqrt(n));
end
