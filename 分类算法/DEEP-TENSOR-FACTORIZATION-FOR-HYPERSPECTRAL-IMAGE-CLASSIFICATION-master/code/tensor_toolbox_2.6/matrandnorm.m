function X = matrandnorm(varargin)
%MATRANDNORM Normalizes columns of X so that each is unit 2-norm.
%
%   X = MATRANDNORM(M,N) creates a random M x N matrix with randomly using
%   normally distributed enries and then rescales the columsn so that each
%   has a unit 2-norm.
%
%   X = MATRANDNORM(X) rescales the columns of X so that each
%   column has a unit 2-norm. 
%
%   Examples
%      X = MATRANDNORM(rand(5,5));
%      X = MATRANDNORM(3,2);
%      X = MATRANDNORM(ones(4));
% 
%   See also MATRANDORTH, MATRANDNORM, CREATE_PROBLEM, CREATE_GUESS.
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

if nargin == 2
    X = randn(varargin{1}, varargin{2});
else
    X = varargin{1};
end

norms = sqrt(sum(X.^2,1));
X = bsxfun(@rdivide,X,norms);

