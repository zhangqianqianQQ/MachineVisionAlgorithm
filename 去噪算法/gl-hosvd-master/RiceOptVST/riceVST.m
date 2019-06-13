function fz_data=riceVST(z_data,sigma_data,VST_ABC)
% Applies (forward) variance-stabilizing transformation f to Rician-distributed data
% --------------------------------------------------------------------------------------------
%
% SYNTAX
% ------
% fz_data = riceVST ( z_data , sigma_data , VST_ABC )
%
%
% OUTPUT
% ------
% fz_data     :  variance-stabilized data f(z_data)
%
%
% INPUTS
% ------
% z_data      :  Rician-distributed data, following the model
%                z_data ~ Rice(nu,sigma_data), nu being some unknown noise-free signal
%                (z_data can be n-dimensional, with n arbitrary)
% sigma_data  :  standard-deviation parameter (see above)
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

%% load variance-stabilizing transformation from file
load(Rice_VST_matFile,'z','f')   

%% scale data before applying variance-stabilizing transformation
z=z*sigma_data;  % sigma_data_scaling=sigma_data (see riceVST_EUI.m)
%% apply variance-stabilizing transformation
fz_data=interp1(z,f,z_data,'linear','extrap');
%% apply asymptotical variance-stabilizing transformation (used only for large values)
maxz=max(z);
fz_data(z_data>maxz)=sqrt(z_data(z_data>maxz).^2./sigma_data^2-1/2)-sqrt(maxz^2./sigma_data^2-1/2)+f(end);

