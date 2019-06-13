% mex function for computing large displacement optical flow
%
% Usage:
%
% flow = mex_LDOF(image1,image2);
% flow = mex_LDOF(image1,image2,sigma,alpha,beta,gamma);
%
% Arguments "image1" and "image2" are color images (3-dimensional arrays). 
% They are required to have the same dimension and they must be doubles. 
%
% The other arguments are tuning parameters 
% (the number in parentheses is the default value)
%
%       sigma:        (0.8) presmoothing of the input images
%       alpha:        (30)  smoothness of the flow field
%       beta:         (300) influence of the descriptor matching
%       gamma:        (5)   influence of the gradient constancy assumption
%
% Thomas Brox
% U.C. Berkeley
% Apr, 2010
% All rights reserved