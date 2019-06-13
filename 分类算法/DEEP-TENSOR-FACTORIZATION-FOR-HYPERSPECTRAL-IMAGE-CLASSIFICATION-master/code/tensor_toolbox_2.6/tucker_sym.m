function [T,Xinit] = tucker_sym(S,R,varargin)
%TUCKER_SYM Symmetric Tucker approximation.
%
%   T = TUCKER_SYM(S,R) computes the best rank-(R,R,...,R) approximation of
%   the symmetric tensor S, according to the specified dimension R. The
%   result returned in T is a ttensor (with all factors equal), i.e.,
%   T = G x_1 X x_2 X ... x_N X where X is the optimal factor matrix and G
%   is the corresponding core.  
%
%   T = TUCKER_SYM(S,R,'param',value,...) specifies optional parameters and
%   values. Valid parameters and their default values are:
%      'tol' - Tolerance on difference in X {1.0e-10}
%      'maxiters' - Maximum number of iterations {1000}
%      'init' - Initial guess [{'random'}|'nvecs'|cell array]
%      'printitn' - Print fit every n iterations {1}
%      'return' - First return argument is T or X [{'ttensor'},'matrix']
%
%   [T,X0] = TUCKER_SYM(...) also returns the initial guess.
%
%   See also TUCKER_SYM.
%
%   Reference: Phillip A. Regalia, Monotonically Convergent Algorithms for
%   Symmetric Tensor Approximation, Linear Algebra and its Applications
%   438(2):875-890, 2013, http://dx.doi.org/10.1016/j.laa.2011.10.033.   
%
%MATLAB Tensor Toolbox.
%Copyright 2015, Sandia Corporation.

% This is the MATLAB Tensor Toolbox by T. Kolda, B. Bader, and others.
% http://www.sandia.gov/~tgkolda/TensorToolbox.
% Copyright (2015) Sandia Corporation. Under the terms of Contract
% DE-AC04-94AL85000, there is a non-exclusive license for use of this
% work by or on behalf of the U.S. Government. Export of this data may
% require a license from the United States Government.
% The full license terms can be found in the file LICENSE.txt


%% Input checking
if ~issymmetric(S)
    error('S must be symmetric');
end

if numel(R) ~= 1
    error('R must be a scalar');
end

N = ndims(S);
D = size(S,1);

%% Set algorithm parameters from input or by using defaults
params = inputParser;
params.addParameter('tol',1e-10,@isscalar);
params.addParameter('maxiters',1000,@(x) isscalar(x) & x > 0);
params.addParameter('init', 'random');
params.addParameter('printitn',1,@isscalar);
params.addParameter('return','ttensor');
params.parse(varargin{:});

%% Copy from params object
tol = params.Results.tol;
maxiters = params.Results.maxiters;
init = params.Results.init;
printitn = params.Results.printitn;

%% Error checking 
% Error checking on maxiters
if maxiters < 0
    error('OPTS.maxiters must be positive');
end

%% Set up and error checking on initial guess for U.
if isnumeric(init)
    Xinit = init;
    if ~isequal(size(Xinit),[D R])
        error('OPTS.init is the wrong size');
    end
else
    if strcmp(init,'random')
        Xinit = rand(D,R);
    elseif strcmp(init,'nvecs') || strcmp(init,'eigs') 
        % Compute an orthonormal basis for the dominant
        % Rn-dimensional left singular subspace of
        % X_(n) (1 <= n <= N).
        fprintf('Computing %d leading e-vectors.\n',R);
        Xinit = nvecs(S,1,R);
    else
        error('The selected initialization method is not supported');
    end
end

%% Set up for iterations - we ensure that X is orthogonal
X = Xinit;
[X,~] = qr(X,0);

% Roughly the same tolerance as is used by pinv
svdtol = D^(N-1) * norm(S) * eps(1.0);

if printitn > 0
    fprintf('\nSymmetric Tucker:\n');
end

%% Main Loop: Iterate until convergence
Xcell = cell(N,1);
for iter = 1:maxiters

    Xold = X;

    % For the remainder tensor
    [Xcell{:}] = deal(X);
    Rem = ttm(S, Xcell, -1, 't');
    Rem = double(tenmat(Rem, 1));
    
    % Form gradient 
    % NOTE: We use the SVD directly rather than PINV, which could be
    % invoked by the line: X = 2*N*Rem*pinv(Rem)*X;
    [UU,SS,~] = svd(Rem,0);
    ii = find(diag(SS) > svdtol, 1, 'last');
    UU = UU(:,1:ii);
    X = 2*N*UU*(UU'*X);
    
    % Update X
    [X,~] = qr(X,0);
    
    % Check for convergence   
    fit = norm(X-Xold)/norm(X);

    % Check for convergence
    if (fit < tol)
        break;
    end
    
    % Print results
    if mod(iter,printitn)==0
        fprintf(' Iter %2d: rel. change in X = %e\n', iter, fit);
    end

end

% Print final result
if (printitn > 0) && (iter < maxiters)
    fprintf(' Iter %2d: rel. change in X = %e\n', iter, fit);
end

% Do they want just the matrix or the full tensor back?
if strcmpi(params.Results.return,'matrix')
    T = X;
else
    [Xcell{:}] = deal(X);
    core = ttm(S, Xcell, 1:N, 't');
    T = ttensor(core, Xcell);
end



