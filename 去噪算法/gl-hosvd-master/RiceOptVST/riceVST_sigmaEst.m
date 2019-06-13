function sigma_hat = riceVST_sigmaEst(z,printOut,est_type,VST_ABC,maxIter,r_tolerance)
% Robust estimatation of noise level from Rician-distributed data
% --------------------------------------------------------------------------------------------
%
% SYNTAX
% ------
% sigma_hat = riceVST_sigmaEst ( z , printOut , est_type , VST_ABC , maxIter , r_tolerance )
%
%
% OUTPUT
% ------
% sigma_hat    : estimate of \sigma parameter of the Rice distribution, where z ~ R(\nu,\sigma)
%
%
% INPUTS
% ------
% z            : input Rician-distributed image or volume
%
% printOut     : print out to screen the results of all iterations (default=0)
% est_type     : estimator type (default=1, i.e. median)
% VST_ABC      : name or filename of variance-stabilizing transform to be used (default='B')
% maxIter      : maximum number of iterations (default=40)
% r_tolerance  : tolerance for stopping rule (default=0.0001)
%
%
% --------------------------------------------------------------------------------------------
%
% The software implements the algorith and methods published in the paper:
%
%  A. Foi, "Noise Estimation and Removal in MR Imaging: the Variance-Stabilization Approach",
%  in Proc. 2011 IEEE Int. Sym. Biomedical Imaging, ISBI 2011, Chicago (IL), USA, April 2011.
%  doi:10.1109/ISBI.2011.5872758
%
% --------------------------------------------------------------------------------------------
%
% author:                Alessandro Foi
%
% web page:              http://www.cs.tut.fi/~foi/RiceOptVST
%
% contact:               firstname.lastname@tut.fi
%
% --------------------------------------------------------------------------------------------
% Copyright (c) 2010-2012 Tampere University of Technology.
% All rights reserved.
% This work should be used for nonprofit purposes only.
% --------------------------------------------------------------------------------------------
%
% Disclaimer
% ----------
%
% Any unauthorized use of these routines for industrial or profit-oriented activities is
% expressively prohibited. By downloading and/or using any of these files, you implicitly
% agree to all the terms of the TUT limited license (included in the file Legal_Notice.txt).
% --------------------------------------------------------------------------------------------
%


%% DEFAULTS
if nargin<2
    printOut=0;
end
if isempty(printOut)
    printOut=0;
end

if nargin<3
    est_type=1;
end
if isempty(est_type)
    est_type=1;
end

if nargin<4
    VST_ABC='B';
end
if isempty(VST_ABC)
    VST_ABC='B';
end

if ischar(VST_ABC)
    if numel(VST_ABC)==1
        Rice_VST_matFile=['Rice_VST_',VST_ABC];
    else
        Rice_VST_matFile=VST_ABC;
    end
end

if ~exist('maxIter','var')
    maxIter=40;
end

if ~exist('r_tolerance','var')
    r_tolerance=0.0001;
end

kernel_type=4;   %% selects convolution kernel to be used for computing detail coefficients in MAD estimator


%% iteration starts
jjjjj=0;
converged=0;
sigma_hat_old=0;
while (jjjjj<maxIter)&&(converged==0)
    jjjjj=jjjjj+1;
    if exist('sigma_hat','var')  %% the variable exists after the first iteration
        sigma_hat_old=sigma_hat;
        sigma_hat=sigma_hat*function_stdEst(riceVST(z,sigma_hat,VST_ABC),kernel_type,est_type);
    else  %% used at iteration 1
        sigma_hat=function_stdEst(z,kernel_type,est_type);
    end
    rel_delta=abs(sigma_hat_old-sigma_hat)/sigma_hat;
    if rel_delta<r_tolerance;
        converged=1;
    end
    if printOut==1
        disp([' Iter. k = ',num2str(jjjjj),'  sigma_hat_k = ',num2str(sigma_hat),'   rel_delta = ',num2str(rel_delta)]);
    end
end

