function [Zw T] = myWhiten(Z)
%--------------------------------------------------------------------------
% Syntax:       Zw = myWhiten(Z);
%               [Zw T] = myWhiten(Z);
%               
% Inputs:       Z is an (d x n) matrix containing n samples of a
%               d-dimensional random vector
%               
% Outputs:      Zw is the whitened version of Z
%               
%               T is the (d x d) whitening transformation of Z
%               
% Description:  This function returns the whitened (identity covariance)
%               version of the input samples
%               
%               NOTE: Must have n >= d to fully whiten Z
%               
%               NOTE: Z = T \ Zcw;
%               
% Author:       Brian Moore
%               brimoor@umich.edu
%               
% Date:         April 26, 2015
%--------------------------------------------------------------------------

% Compute sample covariance
R = cov(Z');

% Whiten data
[U,S,~] = svd(R,'econ');
T = U * diag(1 ./ sqrt(diag(S))) * U';
Zw = T * Z;
