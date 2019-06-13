function [P, P0, output] = cp_wopt(Z,W,R,varargin)
%CP_WOPT Fits a weighted CP model to a tensor via optimization.
%
%   K = CP_WOPT(X,W,R) fits an R-component weighted CANDECOMP/PARAFAC
%   (CP) model to the tensor X, where W is an indicator for missing
%   data (0 = missing, 1 = present). The result K is a ktensor. It is
%   assumed that missing entries of X have been sent to zero (but not
%   that all zeros correspond to missing entries.) The function being
%   optimized is F(K) = 1/2 || W .* (X - K) ||^2.
% 
%   K = CP_WOPT(X,W,R,'param', value,...) specifies additional
%   parameters for the method. Specifically...
%
%   'alg' - Specfies optimization algorithm (default: 'ncg')
%      'ncg'   Nonlinear Conjugate Gradient Method
%      'lbfgs' Limited-Memory BFGS Method
%      'tn'    Truncated Newton
%
%   'init' - Initialization for factor matrices. (default:
%   'random'). This can be a cell array with the initial matrices or
%   one of the following strings:
%      'random' Randomly generated via randn function
%      'nvecs'  Selected as leading left singular vectors of X(n)
%
%   'alg_options' - Parameter settings for selected optimization
%   algorithm. For example, type OPTIONS = NCG('defaults') to get
%   the NCG algorithm options which can then me modified as passed
%   through this function to NCG.
%   
%   'fun' - Specifies the type of implementation (default: 'auto')
%       'auto'           Dense implementation
%       'sparse'         Sparse implementation
%       'sparse_lowmem'  Memory efficient sparse implementation
%
%   [K, U0] = CP_WOPT(...) also returns the initial guess.
%
%   [K, U0, OUT] = CP_WOPT(...) also returns a structure with the
%   optimization exit flag, the final relative fit, and the full
%   output from the optimization method.
%
%   REFERENCE: E. Acar, D. M. Dunlavy, T. G. Kolda and M. Mørup, Scalable
%   Tensor Factorizations for Incomplete Data, Chemometrics and Intelligent
%   Laboratory Systems 106(1):41-56, March 2011
%   (doi:10.1016/j.chemolab.2010.08.004)   
%
%   See also CP_OPT.
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


%% Check for POBLANO
if ~exist('poblano_params','file')
    error(['CP_WOPT requires Poblano Toolbox for Matlab. This can be ' ...
           'downloaded at http://software.sandia.gov/trac/poblano.']);
end

%% Set parameters
params = inputParser;
params.addParameter('alg','ncg', @(x) ismember(x,{'ncg','tn','lbfgs'}));
params.addParameter('init','random', @(x) (iscell(x) || ismember(x,{'random','nvecs'}))); %#ok<*NVREPL>
params.addParameter('fun','auto', @(x) ismember(x,{'auto','default','sparse','sparse_lowmem'}));
params.addParameter('alg_options', '', @isstruct);
params.parse(varargin{:});

%% Set up optimization algorithm
switch (params.Results.alg)
    case 'ncg'
        opthandle = @ncg;
    case 'tn'
        opthandle = @tn;
    case 'lbfgs'
        opthandle = @lbfgs;
end

%% Set up optimization algorithm options
if isempty(params.Results.alg_options)
    options = feval(opthandle, 'defaults');
else
    options = params.Results.alg_options;
end

%% Set up function handle
normZsqr = norm(Z)^2;
funtype = params.Results.fun;

if (isequal(funtype,'auto') && isa(Z,'tensor')) || isequal(funtype,'default')
    funhandle = @(x) tt_cp_wfun(Z,W,x,normZsqr);
else
    if ~isa(Z,'sptensor') || ~isa(W,'sptensor')
        warning('Converting dense tensor to sparse');
        Z = sptensor(Z);
        W = sptensor(W);
    end
    Zvals = tt_cp_wfg_sparse_setup(Z,W);
    fflag = ~isequal(funtype,'sparse_lowmem');
    funhandle = @(x) tt_cp_wfun(Zvals,W,x,normZsqr,fflag);
end
    
%% Initial guess
sz = size(Z);
N = length(sz);

if iscell(params.Results.init)
    P0 = params.Results.init;
elseif strcmpi(params.Results.init,'random')
    P0 = cell(N,1);
    for n=1:N
        P0{n} = randn(sz(n),R);
        for j=1:R
            P0{n}(:,j) = P0{n}(:,j) / norm(P0{n}(:,j));
        end
    end
elseif strcmpi(params.Results.init,'nvecs')
    P0 = cell(N,1);
    for n=1:N
        P0{n} = nvecs(Z,n,R);
    end
else
    error('Initialization type not supported')
end

%% Fit CP using CP_WOPT by ignoring missing entries
out = feval(opthandle, funhandle, tt_fac_to_vec(P0), options);

P  = ktensor(tt_cp_vec_to_fac(out.X,Z));
if nargout > 1
    output.ExitFlag  = out.ExitFlag;
    output.FuncEvals = out.FuncEvals;
    output.f = out.F;
    output.G = tt_cp_vec_to_fac(out.G,W);
    output.OptOut = out;
end


%% Clean up final result
% Arrange the final tensor so that the columns are normalized.
P = arrange(P);
% Fix the signs
P = fixsigns(P);

function [f,G] = tt_cp_wfg(Z,W,A,normZsqr)
%TT_CP_WFG Function and gradient of CP with missing data.
%
%   [F,G] = TT_CP_WFG(Z,W,A) computes the function and gradient values of
%   the function 0.5 * || W .* (Z - ktensor(A)) ||^2. The input A is a
%   cell array containing the factor matrices. The input W is a (dense
%   or sparse) tensor containing zeros wherever data is missing. The
%   input Z is a (dense or sparse) tensor that is assumed to have
%   zeros wherever there is missing data. The output is the function F
%   and a cell array G containing the partial derivatives with respect
%   to the factor matrices.
%
%   [F,G] = TT_CP_WFG(Z,W,A,NORMZSQR) also passes in the pre-computed
%   norm of Z, which makes the computations faster. 
%
%   See also TT_CP_WFUN, TT_CP_WFG_SPARSE, TT_CP_WFG_SPARSE_SETUP.
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


%% Compute B = W.*ktensor(A)
if isa(W,'sptensor')
    B = W.*ktensor(A);
else
    B = W.*full(ktensor(A));
end

%% Compute normZ
if ~exist('normZsqr','var')
    normZsqr = norm(Z)^2;
end

% function value
f = 0.5 * normZsqr - innerprod(Z,B) + 0.5 * norm(B)^2;

% gradient computation
N = ndims(Z);
G = cell(N,1);
T = Z - B;
for n = 1:N
    G{n} = zeros(size(A{n}));
    G{n} = -mttkrp(T,A,n);
end

function [f,g] = tt_cp_wfun(Zdata,W,x,normZsqr,memflag)
%TT_CP_WFUN Computes function and gradient for weighted CP.
%
%   [F,G] = TT_CP_WFUN(Z,W,x,normZsqr) calculates the function and gradient
%   for the function 0.5 * || W .* (Z - ktensor(A)) ||^2 where W is an
%   indicator for missing data (0 = missing, 1 = present), Z is the data
%   tensor that is being fit (assumed that missing entries have already
%   been set to zero), A is a cell array of factor matrices that is created
%   from the vector x, and normZsqr in the norm of Z squared.
%
%   [F,G] = TT_CP_WFUN(Zvals,W,x,normZsqr) is a special version that takes
%   just the nonzeros in Z as calculated by the helper function
%   CP_WFG_SPARSE_SETUP.
%
%   [F,G] = TT_CP_WFUN(....,false) uses a more memory efficient version for
%   the sparse code.
%
%   See also TT_CP_WFG, TT_CP_WFG_SPARSE, TT_CP_WFG_SPARSE_SETUP
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


%% Convert x to factor matrices (i.e., a cell array).
% Normally we would pass in the data tensor, but we may have a data
% tensor or a data array if we are doing the sparse
% calculation. Therefore, we exploit the fact that W is the same
% size as Z and pass it into the function.
A = tt_cp_vec_to_fac(x,W);

%% Compute the function and gradient
if isa(Zdata,'tensor') || isa(Zdata,'sptensor')
    if ~exist('normZsqr','var')
        normZsqr = norm(Zdata)^2;
    end
    [f,G] = tt_cp_wfg(Zdata,W,A,normZsqr);
else
    if ~exist('normZsqr','var')
        normZsqr = sum(Zdata.^2);
    end
    if ~exist('memflag','var')
        memflag = true;
    end
    [f,G] = tt_cp_wfg_sparse(Zdata,W,A,normZsqr,memflag);
end

%% Convert gradient to a vector
g = tt_fac_to_vec(G);


function Zvals = tt_cp_wfg_sparse_setup(Z,W)
%CP_WFG_SPARSE_SETUP Creates a special array.
%
%   ZVALS = CP_WFG_SPARSE_SETUP(Z,W) creates an array ZVALS that
%   contains the values of Z corresponding to the indices specified
%   by W.subs. 
%
%   See also CP_WFG_SPARSE.
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


Zsubs = Z.subs;
Wsubs = W.subs;
Zvals = zeros(size(W.vals));
[junk,loc] = ismember(Zsubs,Wsubs,'rows');
Zvals(loc) = Z.vals;

function [f,G] = tt_cp_wfg_sparse(Zvals,W,A,normZsqr,memflag)
%TT_CP_WFG_SPARSE Computes weighted CP function and gradient.
%
%   [F,G] = TT_CP_WFG_SPARSE(ZVALS,W,A) computes the function and
%   gradient with respect to A of || W .* (Z - ktensor(A)) ||^2 where
%   Z = W .* X. The variable ZVALS contains the values of the tensor Z
%   at the locations specified by W.subs. (ZVALS can be computed using
%   a provided preprocessing function.) The variable A is a cell array
%   of component matrices. The tensor W is a sparse tensor that has
%   ones in entries where we know the values.
%
%   [F,G] = TT_CP_WFG_SPARSE(ZVALS,W,A,NORMZSQR) also passes in the
%   pre-computed norm of Z, which makes the computations faster.
%
%   [F,G] = TT_CP_WFG_SPARSE(ZVALS,A,W,NORMZSQR,false) uses less memory
%   but more time and is appropriate for very large sparse tensors.
% 
%   See also TT_CP_WFG_SPARSE_SETUP, CP_WFG, CP_WFUN.
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


%% Set-up
N = ndims(W);
R = size(A{1},2);
sz = cellfun(@(x)size(x,1),A);
Wsubs = W.subs;
Wvals = W.vals;
Nvals = length(Wvals);

if ~exist('memflag','var')
    memflag = true;
end

%% Compute B = W.*ktensor(A)
Bvals = zeros(Nvals,1);
for r = 1:R
    newvals = Wvals;
    for n = 1:N
        bigArn = A{n}(Wsubs(:,n),r);
        newvals = newvals .* bigArn;
    end
    Bvals = Bvals + newvals;
end

%% Compute normZ
if ~exist('normZsqr','var')
    normZsqr = sum(Zvals.^2);
end

%% function value: f = 0.5 * normZsqr - innerprod(Z,B) + 0.5 * norm(B)^2
f = 0.5 * normZsqr - Zvals'*Bvals + 0.5 * sum(Bvals.^2);

%% gradient computation
Tvals = Zvals - Bvals;

G = cell(N,1);
for n = 1:N
    G{n} = zeros(size(A{n}));
end

for r = 1:R
    if (memflag)
        bigAr = cell(N,1);
        for n = 1:N
            bigAr{n} = A{n}(Wsubs(:,n),r);
        end
        for SkipN = 1:N
            newvals = Tvals;
            for n = [1:SkipN-1,SkipN+1:N]
                newvals = newvals .* bigAr{n};
            end
            G{SkipN}(:,r) = accumarray(Wsubs(:,SkipN),newvals,[sz(SkipN) 1]);
        end
    else
        for SkipN = 1:N
            newvals = Tvals;
            for n = [1:SkipN-1,SkipN+1:N]
                bigArn = A{n}(Wsubs(:,n),r);
                newvals = newvals .* bigArn;
            end
            G{SkipN}(:,r) = accumarray(Wsubs(:,SkipN),newvals,[sz(SkipN) 1]);
        end
    end

end

for n = 1:N
    G{n} = -G{n};
end
