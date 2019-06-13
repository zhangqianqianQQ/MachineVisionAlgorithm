% Function to perform Principle Component Analysis over a set of training
% vectors passed as a concatenated matrix.
%
% Usage:- [V,D,M] = pca(X,n)
%         [V,D] = pca(X,aM,n)
%
% where:-
%        <input>
%        X = concatenated set of column vectors
%        aM = assume that the mean is aM
%        n = number of principal components to extract (optional)
%        <output>
%        V = ensemble of column eigen-vectors
%        D = vector of eigen-values
%        M = mean of X (optional)
%
%
% by Simon Lucey 2006

function [v,d,varargout] = pca(X,varargin)

% Check arguments
neigs = min(size(X)) - 1; % Set the number of eigen-vectors
aM = mean(X,2); % Otherwise set to data mean
if nargin > 1
  % Check if second argument is a vector
  if size(varargin{1},1) == size(X,1)
    aM = varargin{1}; % Set to specified mean
    if nargin == 3
      neigs = varargin{2}; % Set the number of eigen-vectors
    end
  else
    neigs = varargin{1}; % Set the number of eigen-vectors
  end
end

N = size(X,2); % Get number of samples in training set
D = size(X,1); % Get dimension of training set

% Remove the mean from the data
nX = X - repmat(aM,[1,size(X,2)]);

if N > D
  [v,d] = pca_NgtD(nX,neigs);
else
  [v,d] = pca_NltD(nX,neigs);
end

% Set outputs
if nargout == 3
  varargout(1) = {aM};
end

% Function to do PCA if N is greater than (gt) D
function [v,d] = pca_NgtD(nX,n)

% Get the number of samples
N = size(nX,2);

% Calculate correlation matrix
R = (nX*nX')/N;

% Now calculate the eigen vectors of this matrix
[v,d] = eig(R);
d = diag(d); % Get main diagonal of eigen values
[dummy,i] = sort(d); % Sort values in ascending order
i = flipud(i); % Change to be in descending order

% Check if n is less than one
if n < 1
    n = num_neigs(d(i),n);
end

v = v(:,i(1:n)); % Set the eigen-vectors
d = d(i(1:n)); % Set the eigen-values

% Function to do PCA if N is less than (lt) D
function [v,d] = pca_NltD(nX,n)

N = size(nX,2);
D = size(nX,1);

% Now lets get the autocorrelation matrix for mxm not nxn matrix
S = (nX'*nX)/D;

% Now calculate eigenvectors and eigen values
[v,d] = eig(S);

% Set transpose of vectors
v = nX*v; % New eigen vectors as per pg 40 of Fukunaga
v = v*inv(sqrt(D*d)); % Re-weight the vectors

d = D*diag(d)/N; % Get main diagonal of eigen values
[dummy,i] = sort(d); % Sort values in ascending order
i = flipud(i); % Change to be in descending order

% Check if n is less than one
if n < 1
    n = num_neigs(d(i),n);
end

v = v(:,i(1:n)); % Set the eigen-vectors
d = d(i(1:n)); % Set the eigen-values

function n = num_neigs(d,p)

k = cumsum(d)./sum(d); % Get the cumulative sum
j = find(k >= p); % Find the index
n = j(1);