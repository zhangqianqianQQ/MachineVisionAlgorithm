function EUI_data=riceVST_EUI(Efz_data,sigma_data,VST_ABC)
% Applies exact unbiased inverse of the variance-stabilizing transformation f
% --------------------------------------------------------------------------------------------
%
% SYNTAX
% ------
% EUI_data = riceVST_EUI ( Efz_data , sigma_data , VST_ABC )
%
%
% OUTPUT
% ------
% EUI_data    :  exact unbiased inverse of the input Efz_data
%
%
% INPUTS
% ------
% Efz_data    :  Filtered variance-stabilized data (e.g, output of the denoising filter)
% sigma_data  :  standard-deviation parameter of the Rice distribution;  the method assumes
%                that the data z_data before stabilization is distributed according to
%                z_data ~ Rice(nu,sigma_data), nu being some unknown noise-free signal.
%                EUI_data should coincide with nu if the denoising of fz_data is perfect.
% VST_ABC     :  file-selector for the variance-stabilizing transformation  (default = 'A')
%
%
% --------------------------------------------------------------------------------------------
%
% The software implements the method published in the paper:
%
%  A. Foi, "Noise Estimation and Removal in MR Imaging: the Variance-Stabilization Approach",
%  in Proc. 2011 IEEE Int. Sym. Biomedical Imaging, ISBI 2011, Chicago (IL), USA, April 2011.
%  doi:10.1109/ISBI.2011.5872758
%
% --------------------------------------------------------------------------------------------
%
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



%% Defaults
if nargin<2
    sigma_data=1;
end
if isempty(sigma_data)
    sigma_data=1;
end

if nargin<3
    VST_ABC='A';
end
if isempty(VST_ABC)
    VST_ABC='A';
end

if ischar(VST_ABC)
    if numel(VST_ABC)==1
        Rice_VST_matFile=['Rice_VST_',VST_ABC];
    else
        Rice_VST_matFile=VST_ABC;
    end
end


%% load variance-stabilizing transformation and its exact unbiased inverse from file
load(Rice_VST_matFile,'Efz','nu','z','f')

%% scale data before applying exact unbiased inverse of the variance-stabilizing transformation (see riceVST.m)
sigma_data_scaling=sigma_data;
a=f(end)-sqrt(sigma_data_scaling^2*max(z)^2/sigma_data^2-1/2);
nu=nu*sigma_data_scaling;
%% apply exact unbiased inverse of the variance-stabilizing transformation
EUI_data=interp1(Efz,nu,Efz_data,'linear','extrap');
%% small values (see Equation 11 in the ISBI2011 paper)
EUI_data(Efz_data<=min(Efz))=min(nu);
%% apply asymptotical exact unbiased inverse of the variance-stabilizing transformation (used only for large values)
maxEfz=max(Efz);
if 0
    EUI_data(Efz_data>maxEfz)=sigma_data*sqrt((Efz_data(Efz_data>maxEfz)-a).^2+0.5);  %% this is the asymptotic inversion to Ez (identical to the above theta_or_Ez==1 case)
    EUI_data(Efz_data>maxEfz)=EUI_data(Efz_data>maxEfz).*(1-0.5*(sigma_data./EUI_data(Efz_data>maxEfz)).^2);  %% this is the asymptotic correction between nu and Ez
else
    EUI_data(Efz_data>maxEfz)=sigma_data*((Efz_data(Efz_data>maxEfz)-a).^2)./sqrt((Efz_data(Efz_data>maxEfz)-a).^2+0.5);   %% this is the result of the two lines above
end

