function [lambda,x,flag,its,x0] = eig_sshopm(A,varargin)
%EIG_SSHOPM Shifted power method for finding real eigenpair of real tensor.
%
%   [LAMBDA,X]=EIG_SSHOPM(A) finds an eigenvalue (LAMBDA) and eigenvector
%   (X) for the real tensor A such that Ax^{m-1} = lambda*x.
%
%   [LAMBDA,X]=EIG_SSHOPM(A,parameter,value,...) can specify additional
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
%   [LAMBDA,X,FLAG]=EIG_SSHOPM(...) also returns a flag indicating convergence.
%
%      FLAG = 0  => Succesfully terminated 
%      FLAG = -1 => Norm(X) = 0
%      FLAG = -2 => Maximum iterations exceeded
%
%   [LAMBDA,X,FLAG,IT]=EIG_SSHOPM(...) also returns the number of iterations.
%
%   [LAMBDA,X,FLAG,IT,X0]=EIG_SSHOPM(...) also returns the intial guess.
%
%   REFERENCES: 
%   * T. G. Kolda and J. R. Mayo, Shifted Power Method for Computing Tensor
%     Eigenpairs, SIAM Journal on Matrix Analysis and Applications
%     32(4):1095-1124, October 2011, http://dx.doi/org/10.1137/100801482
%   * T. G. Kolda and J. R. Mayo, An Adaptive Shifted Power Method for
%     Computing Generalized Tensor Eigenpairs, SIAM Journal on Matrix
%     Analysis and Applications 35(4):1563-1582, December 2014,
%     http://dx.doi.org/0.1137/140951758   
%
%   See also EIG_GEAP, EIG_SSHOPMC, TENSOR, SYMMETRIZE, ISSYMMETRIC.
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
P = ndims(A);
N = size(A,1);

if ~issymmetric(A)
    error('Tensor must be symmetric.')
end

%% Check inputs
p = inputParser;
p.addParamValue('Shift', 'adaptive');
p.addParamValue('MaxIts', 1000, @(x) isscalar(x) && (x > 0));
p.addParamValue('Start', [], @(x) isequal(size(x),[N 1]));
p.addParamValue('Tol', 1.0e-15, @(x) isscalar(x) && (x > 0));
p.addParamValue('Display', -1, @isscalar);
p.addParamValue('Concave', false, @islogical);
p.addParamValue('Margin', 1e-6, @(x) isscalar(x) && (x > 0));
p.parse(varargin{:});

%% Copy inputs
maxits = p.Results.MaxIts;
x0 = p.Results.Start;
shift = p.Results.Shift;
tol = p.Results.Tol;
display = p.Results.Display;
concave = p.Results.Concave;
margin = p.Results.Margin;

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
if shift ~= 0
    concave = (shift < 0);
end        

%% Execute power method
if (display >= 0)
    fprintf('TENSOR SHIFTED POWER METHOD: ');
    if concave
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
lambda = x'*ttsv(A,x,-1); 
if adaptive
    shift = adapt_shift(A,x,margin,concave);
end

for its = 1:maxits
    
    newx = ttsv(A,x,-1) + shift * x;
    
    if (concave)
        newx = -newx;
    end
    
    nx = norm(newx);
    if nx < eps, 
        flag = -1; 
        break; 
    end
    newx = newx / nx;    
    
    newlambda = newx'* ttsv(A,newx,-1);    

    if adaptive
        newshift = adapt_shift(A,newx,margin,concave);        
    else
        newshift = shift;
    end
    
    if norm(abs(newlambda-lambda)) < tol
        flag = 0;
    end
       
    if (display > 0) && ((flag == 0) || (mod(its,display) == 0))
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
    lambda = newlambda;
    shift = newshift;
    
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


%% ----------------------------------------------------

function alpha = adapt_shift(A,x,tau,concave)

m = ndims(A);
Y = ttsv(A,x,-2);
e = eig(Y);

if concave
    if max(e) <= -tau/(m^2-m)
        alpha = 0;
    else
        alpha = -(tau/m) - ((m-1)*max(e));
    end
else
    if min(e) >= tau/(m^2-m)
        alpha = 0;
    else
        alpha = (tau/m) - ((m-1)*min(e));
    end
end

