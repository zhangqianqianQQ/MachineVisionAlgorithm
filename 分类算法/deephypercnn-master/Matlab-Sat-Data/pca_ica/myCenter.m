function [Zc mu] = myCenter(Z)
%--------------------------------------------------------------------------
% Syntax:       Zc = myCenter(Z);
%               [Zc mu] = myCenter(Z);
%               
% Inputs:       Z is an (d x n) matrix containing n samples of a
%               d-dimensional random vector
%               
% Outputs:      Zc is the centered version of Z
%               
%               mu is the (d x 1) sample mean of Z
%               
% Description:  This function returns the centered (i.e., zero mean)
%               version of the input samples
%               
%               NOTE: Z = Zc + repmat(mu,1,n);
%               
% Author:       Brian Moore
%               brimoor@umich.edu
%               
% Date:         April 26, 2015
%--------------------------------------------------------------------------

% Compute sample mean
mu = mean(Z,2);

% Subtract mean
Zc = bsxfun(@minus,Z,mu);
