function [varargout] = eig_geap(A,B,varargin)
%EIG_GEAP Shifted power method for generalized tensor eigenproblem.
%
%   [LAMBDA,X] = EIG_GEAP(A,B) finds an eigenvalue (LAMBDA) and eigenvector
%   (X) for the real tensor A and the positive definite tensor B such that 
%   Ax^{m-1} = lambda * Bx^{m-1}.
%
%   [LAMBDA,X] = EIG_GEAP(A,B,parameter,value,...) can specify additional
%   parameters as follows: 
% 
%     'Shift'    : Shift for eigenvalue calculation (Default: 'Adaptive')
%     'Margin'   : Margin for positive/negative definiteness in adaptive
%                  shift caluclation. (Default: 1e-6)
%     'MaxIts'   : Maximum power method iterations (Default: 1000)
%     'Start'    : Initial guess (Default: normal random vector)
%     'Tol'      : Tolerance on norm of change in |lambda| (Default: 1e-15)
%     'Concave'  : Treat the problem as concave rather than convex.
%                  (Default: true for negative shift; false otherwise.)
%     'Display'  : Display every n iterations (Default: -1 for no display)
%
%   [LAMBDA,X,FLAG] = EIG_GEAP(...) also returns a flag indicating
%   convergence. 
%
%      FLAG = 0  => Succesfully terminated 
%      FLAG = -1 => Norm(X) = 0
%      FLAG = -2 => Maximum iterations exceeded
%
%   INFO = EIG_GEAP(...) returns a structure with the above plus other
%   information, including the starting guess, the number of iterations,
%   the final shift, the number of monotinicity violations, and a trace of
%   the lambdas.
%
%   REFERENCE: T. G. Kolda and J. R. Mayo, An Adaptive Shifted Power Method
%   for Computing Generalized Tensor Eigenpairs, SIAM Journal on Matrix
%   Analysis and Applications 35(4):1563-1581, December 2014,
%   http://dx.doi.org/10.1137/140951758 
%
%   See also EIG_SSHOPM, TENSOR, SYMMETRIZE, ISSYMMETRIC.
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


%% Error checking on A
N = size(A,1);


%% Check inputs
p = inputParser;
p.addParamValue('Shift', 'adaptive', @(x) strcmpi(x,'adaptive') || isscalar(x));
p.addParamValue('MaxIts', 1000, @(x) isscalar(x) && (x > 0));
p.addParamValue('Start', [], @(x) isequal(size(x),[N 1]));
p.addParamValue('Tol', 1.0e-15, @(x) isscalar(x) && (x > 0));
p.addParamValue('Display', -1, @isscalar);
p.addParamValue('Concave', false, @islogical);
p.addParamValue('Margin', 1e-6, @(x) isscalar(x) && (x > 0));
p.addParamValue('SkipChecks', false);
p.parse(varargin{:});

%% Copy inputs
maxits = p.Results.MaxIts;
x0 = p.Results.Start;
shift = p.Results.Shift;
tol = p.Results.Tol;
display = p.Results.Display;
concave = p.Results.Concave;
margin = p.Results.Margin;
skipchecks = p.Results.SkipChecks;

%% Check inputs
if ~skipchecks
    if ~issymmetric(A)
        error('Tensor A must be symmetric')
    end
    
    if ~isempty(B)        
        if ~issymmetric(B)
            error('Tensor B must be symmetric');
        end
        
        if ~isequal(size(A),size(B))
            error('A and B must be the same size');
        end        
    end
end

%% Check shift
if ~isnumeric(shift)
    adaptive = true;
    shift = 0;
else
    adaptive = false;
end

%% Check starting vector
if isempty(x0)
    x0 = 2*rand(N,1)-1;
end

if norm(x0) < eps
    error('Zero starting vector');
end

%% Check concavity
if concave
    beta = -1;
else
    beta = 1;
end

if ~adaptive
    if (shift < 0) && (beta == 1)
        error('Set ''concave'' to true for a negative shift');
    elseif (shift > 0) && (beta == -1)
        error('Set ''concave'' to false for a positive shift');
    end
end

%% Execute power method
if (display >= 0)
    fprintf('Generalized Adaptive Tensor Eigenpair Power Method: ');
    if (beta == -1)
        fprintf('Concave ');
    else
        fprintf('Convex  ');
    end
    fprintf('\n');
    fprintf('----  --------- ----- ------------ -----\n');
    fprintf('Iter  Lambda    Diff  |newx-x|     Shift\n');
    fprintf('----  --------- ----- ------------ -----\n');
end

flag = -2;

x = x0 / norm(x0);
data = geap_data(x,A,B);
lambda = data.Axm / data.Bxm;
nviols = 0;
lambdatrace = zeros(maxits+1,1);
lambdatrace(1) = lambda;
if adaptive
    shifttrace = zeros(maxits,1);
else
    shifttrace = shift * ones(maxits,1);
end

for its = 1:maxits
    
    if adaptive
        tmp = min( eig( beta * geap_hessian(data) ) );
        shift = beta * max(0, ( margin / data.m ) - tmp);
        shifttrace(its) = shift;
    end
    if data.Bex
        newx = beta * (data.Axm1 - lambda * data.Bxm1 + (shift + lambda) * data.Bxm * x);
    else
        newx = beta * (data.Axm1 + shift * x);
    end
      
    nx = norm(newx);
    if nx < eps, 
        flag = -1; 
        break; 
    end
    newx = newx / nx;    
    newdata = geap_data(newx,A,B);
    newlambda = newdata.Axm / newdata.Bxm;
      
   
    if norm(abs(newlambda-lambda)) < tol
        flag = 0;
    elseif (beta == 1) && (newlambda < lambda) 
        if (display > 0)
        warning('Lambda is decreasing by %e when it should be increasing', abs(lambda-newlambda));
        end
        nviols = nviols + 1;
    elseif (beta == -1) && (newlambda > lambda) 
        if (display > 0)
        warning('Lambda is increasing by %e when it should be decreasing', abs(lambda-newlambda));        
        end
        nviols = nviols + 1;
    end
       
    if (display > 0) && ((flag == 0) || (mod(its,display) == 0))
        
        % Iteration Number
        fprintf('%4d  ', its);
        
        % Lambda
        fprintf('%9.6f ', newlambda);
        d = newlambda-lambda;
        if (d ~= 0)
            if (d < 0), c = '-'; else c = '+'; end
            fprintf('%ce%+03d ', c, round(log10(abs(d))));
        else
            fprintf('      ');
        end
        
        % Change in X
        fprintf('%8.6e ', norm(newx-x));          
        
        % Shift
        fprintf('%5.2f', shift);

        % Line end
        fprintf('\n');
    end
    
    x = newx;
    data = newdata;
    lambda = newlambda;
    lambdatrace(its+1) = lambda;
    
    if flag == 0
        break
    end
end

%% Check results
if (display >=0)
    switch(flag)
        case 0
            fprintf('Successful Convergence');
        case -1 
            fprintf('Converged to Zero Vector');
        case -2
            fprintf('Exceeded Maximum Iterations');
        otherwise
            fprintf('Unrecognized Exit Flag');
    end
    fprintf('\n');
end

%% Process output

nout = max(nargout,1);
if nout == 1

    % Save everything in info
    info.lambda = lambda;
    info.x = x;
    info.flag = flag;
    info.x0 = x0;
    info.its = its;
    info.nviols = nviols;
    info.shift = shift;
    info.lambdatrace = lambdatrace(1:its+1);
    info.shifttrace = shifttrace(1:its);
    
    varargout{1} = info;
    
elseif nout >= 2
    
    varargout{1} = lambda;
    varargout{2} = x;
    
    if nout == 3
        varargout{3} = flag;
    end
end

%% ----------------------------------------------------
function data = geap_data(x,A,B)
%GEAP_DATA Computes values needed for Generalized Tensor Eigenproblem
%
%   DATA = GEAP_DATA(X,A,B) assumes X is a vector and A and B are symmetric
%   tensors of appropriate sizes. No checking for sizes or symmetry are
%   enforced. The following quanties are computed...
%
%   - DATA.x - original X vector
%   - DATA.m - ndims(A)
%   - DATA.normx - norm(X)
%   - DATA.normxeq1 - True if |norm(X)-1|<10*eps
%   - DATA.nxm - norm(X)^ndims(A)
%   - DATA.Axm - ttsv(A,X)
%   - DATA.Axm1 - ttsv(A,X,-1)
%   - DATA.Axm2 - ttsv(A,X,-2)
%   - DATA.Bex - true, incidating B tensor is specified.
%   - DATA.Bxm - ttsv(B,X)
%   - DATA.Bxm1 - ttsv(B,X,-1)
%   - DATA.Bxm2 - ttsv(B,X,-2)
%
%   Alternatively, if B is empty, then 
%   - DATA.Bex - false
%   - DATA.Bxm - 1
%   - DATA.Bxm1 - X
%   - DATA.Bxm2 - [] 
%
%   See also GEAP_FUNCTION, GEAP_GRADIENT, GEAP_HESSIAN, GEAP.


data.x = x;
data.m = ndims(A);
data.normx = norm(x);
data.normxeq1 = abs(data.normx-1) < 10*eps;
data.nxm = (data.normx)^(data.m);
data.Axm2 = ttsv(A,x,-2);
data.Axm1 = data.Axm2*x; 
data.Axm = data.Axm1'*x;

if isempty(B)
    
    data.Bex = false;
    data.Bxm = 1;
    data.Bxm1 = x;
    data.Bxm2 = [];
    
else

    data.Bex = true;
    data.Bxm2 = ttsv(B,x,-2);
    data.Bxm1 = data.Bxm2*x;
    data.Bxm = data.Bxm1'*x;
    
    if data.Bxm < 0
        disp(data.x)
        disp(data.Bxm)
        error('B is not positive definite')
    end
    
end

function H = geap_hessian(data,alpha,dividebym)
%GEAP_HESSIAN Computes Generalized Tensor Eigenproblem gradient.
%
%   G = GEAP_HESSIAN(DATA) returns the GEAP function Hessian divided by
%   DATA.m, where DATA is the result of calling the GEAP_DATA function.
%
%   G = GEAP_FUNTION(DATA,ALPHA) returns the Hessian of the shifted GEAP
%   function, where the shift if ALPHA. 
%
%   G = GEAP_FUNCTION(DATA,ALPHA,FALSE) does not divide the result by
%   data.m.
%
%   See also GEAP_DATA, GEAP_FUNCTION, GEAP_GRADIENT, GEAP.

if ~exist('alpha','var')
    alpha = 0;
end

if ~exist('dividebym','var')
    dividebym = true;
end

if (~data.normxeq1)
    warning('Norm(x) = %e, but should be 1.\n', data.normx);
end

m = data.m;
x = data.x;
n = size(x,1);
Axm = data.Axm;
Axm1 = data.Axm1;
Axm2 = data.Axm2;
xxt = x*x';
mat4 = eye(n) + (m-2) * xxt;

if data.Bex
    Bxm = data.Bxm;
    Bxm1 = data.Bxm1;
    Bxm2 = data.Bxm2;    
    
    mat1 = symprod(Bxm1,Bxm1);
    mat2 = symprod(Axm1,x);
    mat3 = symprod(Axm1,Bxm1);
    mat5 = symprod(Bxm1,x);
    
    H1dm = ((m*Axm)/(Bxm^3)) * mat1 ...
        + (1/Bxm) * ( (m-1) * Axm2 + m * mat2 + Axm * mat4 ) ...
        - (1/Bxm^2) * ( m * mat3 + (m-1) * Axm * Bxm2 + m * Axm * mat5);
else
    H1dm = (m-1)*Axm2;
end

H2dm = alpha * mat4;
H = H1dm + H2dm;

if ~dividebym
    H = m * H;
end
    
function M = symprod(a,b)
M = a*b' + b*a';



