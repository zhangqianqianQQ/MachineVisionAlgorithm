function Z = myMultiGaussian(MU,SIGMA,n)
%--------------------------------------------------------------------------
% Syntax:       Z = myMultiGaussian(MU,SIGMA);
%               Z = myMultiGaussian(MU,SIGMA,n);
%               
% Inputs:       MU is the desired (d x 1) mean vector
%               
%               SIGMA is the desired (d x d) covariance matrix
%               
%               [OPTIONAL] n is the desired number of samples. The default
%               value is n = 1
%               
% Outputs:      Z is a (d x n) matrix containing n multivariate Gaussian 
%               samples
%               
% Description:  This function generates samples from a d-dimensional
%               multivariate Gaussian random variable with mean vector MU
%               and covariance matrix SIGMA
%               
%               NOTE: mean(Z,2) ~ MU
%                     cov(Z') ~ SIGMA
%               
% Author:       Brian Moore
%               brimoor@umich.edu
%               
% Date:         April 26, 2015
%--------------------------------------------------------------------------

% Parse inputs
[d d2] = size(SIGMA);
if (d ~= d2) || (d ~= length(MU))
    % Syntax error
    error('Syntax error... Type "help myMultiGaussian" for more info');
end
if nargin < 3
    % Default # samples
    n = 1;
end

% Generate samples
L = chol(SIGMA,'lower');
Z = repmat(MU,1,n) + L * randn(d,n);
