% --------------------------------------------------------------------------------------------
%
%     Demo software for Rician noise removal via variance stabilization
%               Release ver. 1.0  (18 July 2011)
%
% --------------------------------------------------------------------------------------------
%
% The software implements the algorithm and methods published in the paper:
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
% Copyright (c) 2010-2011 Tampere University of Technology.
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

%%
clear all

%% main options in this demo

percentNoise=11;   %% percent noise (sigma expressed as percentage value with respect to the maximum value of the original noise-free signal)

estimate_noise=1;  %% estimate noise level from data using recursive algorithm with VST+Gaussian MAD

% denoising algorithm to be used for filtering the variance-stabilized data
denMethod='bm4d';      %% BM4D (Maggioni & Foi)
% denMethod='onlm3d';    %% OB-NLM-3D-WM (Manjon & Coup?

%% --------------------------------------------------------------------------------------------

%% load BrainWeb T1 phantom
name ='t1_icbm_normal_1mm_pn0_rf0.rawb';
fid = fopen(name,'r');
nu = reshape(fread(fid,inf,'uchar'),[181,217,181]);
nu=nu(101:150,101:150,101:150);
fclose(fid);


%% uncomment some of the following lines to test on small subvolume
% nu=nu(:,:,91-25:91+25);
% nu=nu(91-25:91+25,120:217,26-25:26+25);
% nu=nu(1:2:end,1:2:end,1:2:end);
% nu=nu(1:end/2,1:end/2,1:end/2);
% nu=nu(50:150,50:150,91-25:91+25);



%% create noisy data (spatially homogeneus Rician noise)
sigma=percentNoise*max(nu(:))/100;    % get sigma from percentNoise
randn('seed',0);  rand('seed',0);     % fixes pseudo-random noise
z=sqrt((nu+sigma*randn(size(nu))).^2 + (sigma*randn(size(nu))).^2);   % raw magnitude MR data


%%
disp(' ');disp(' ');disp( '---------------------------------------------------------------');
disp(['Size of data is ', num2str(size(z,1)),'x',num2str(size(z,2)),'x',num2str(size(z,3)),'  (total ',num2str(numel(z)),' voxel)']);
%% compute PSNR of observations
if exist('nu','var')
    if exist('sigma','var')&&exist('percentNoise','var')
        disp(['input nu range = [',num2str(min(nu(:))),' ',num2str(max(nu(:))),'],  noise sigma = ',num2str(sigma),' (',num2str(percentNoise),'%)']);
    else
        disp(['input nu range = [',num2str(min(nu(:))),' ',num2str(max(nu(:))),']']);
    end
    
    if 1
        ind=find(nu>10);   %% compute PSNR over foreground only
    else
        ind=1:numel(nu);   %% compute PSNR over every voxel in the volume
    end
    
    range_for_PSNR=255;
    psnr_z=10*log10(range_for_PSNR^2/(mean((z(ind)-nu(ind)).^2)));
    disp(['PSNR of noisy input z is ',num2str(psnr_z),' dB'])
end

%% noise-level estimation
if estimate_noise||~exist('sigma','var')
    disp( '---------------------------------------------------------------');
    disp(' * Estimating noise level sigma   [ model  z ~ Rice(nu,sigma) ]');
    estimate_noise_printout=1;   %% print-out estimate at each iteration.
    
    sigma_hat=riceVST_sigmaEst(z,estimate_noise_printout);
    disp( ' --------------------------------------------------------------');
    
    
    if ~exist('sigma','var')
        disp([' sigma_hat = ',num2str(sigma_hat)]);
    else
        disp([' sigma_hat = ',num2str(sigma_hat), '  (true sigma = ',num2str(sigma),')']);
        disp([' Relative estimation accuracy (1-sigma_hat/sigma) = ',num2str(1-sigma_hat/sigma)]);
    end
    disp( '---------------------------------------------------------------');
else
    sigma_hat=sigma;
end

%% denoising
VST_ABC_denoising='A';  %% VST pair to be used before and after denoising (for forward and inverse transformations)

tic;

if 1
    disp(' * Applying variance-stabilizing transformation')
    fz = riceVST(z,sigma_hat,VST_ABC_denoising);   %%  apply variance-stabilizing transformation
    sigmafz = 1;                                   %%  standard deviation of noise in f(z)
    if strcmp(denMethod,'bmXd')||strcmp(denMethod,'bm3d')||strcmp(denMethod,'bm4d')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% BM4D (Maggioni 2011)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Available soon from http://www.cs.tut.fi/~foi/GCF-BM3D
        disp(' * Denoising with Gaussian BM4D ...  (may take a while)')
        % apply affine transformation to scale the data to a range well within [0,1]
        maxfz=max(fz(:));   %% first put data into [0,1] ...
        minfz=min(fz(:));
        fz=(fz-minfz)/(maxfz-minfz);
        sigmafz=sigmafz/(maxfz-minfz); % (scale standard-deviation accordingly)
        scale_range=0.7;  %% ... then set data range in [0.15,0.85], to avoid clipping of extreme values
        scale_shift=(1-scale_range)/2;
        fz=fz*scale_range+scale_shift;
        sigmafz=sigmafz*scale_range; % (scale standard-deviation accordingly)
        if size(fz,3)>1
            addpath ./bm4d
            [dummy D]=bm4d(1,fz,sigmafz,1,1,1,0);  % bm4d(y, z, sigma, alpha, do_wiener, use_mod_profile, print_to_screen)
        else
            addpath ./bm3d
            [dummy D]=bm3d(1,fz,sigmafz*255,'vn');
        end
        
        % return filter output to the initial range, applying the inverse affine transformation
        D=(D-scale_shift)/scale_range;
        D=D*(maxfz-minfz)+minfz;
    elseif strcmp(denMethod,'onlm3d')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Wavelet Mixing Filter (Coupe 2008)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Available from http://personales.upv.es/jmanjon/denoising/naonlm3d.zip
        disp(' * Denoising with Gaussian OB-NLM-3D-WM ...  (may take a while)')
        addpath ./naonlm3d
        addpath ./naonlm3d/Wave3D
        h=sigmafz;  % noise std .dev.
        v=3;        % radius of search area
        radiusSmall=1;    % radius of similarity patch (small)
        radiusLarge=2;    % radius of similarity patch (large)
        r=0;     % Rician tag: Rician(1), Gaussian(0)
        minii=-9+3;%*0-min(fz(:));
        fz=fz-minii;
        fimau=MBONLM3D(fz,v,radiusSmall,h,r);
        fimao=MBONLM3D(fz,v,radiusLarge,h,r);
        % Mixing of the coefficient LLL of fimau and the high subbands of fimao
        D=mixingsubband(fimau,fimao);
        D=D+minii;
        clear fimao fimau
    else
        disp('unknown denoising method')
    end
    disp(' * Applying exact unbiased inverse for the estimation of nu')
    nu_hat = riceVST_EUI(D,sigma_hat,VST_ABC_denoising);   %% apply exact unbiased inverse for estimating nu
end


%%
if 0   %% this is a filter designed for Rician observations (which works without VST), here for comparison
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Wavelet Mixing Filter (Coupe 2008)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Available from http://personales.upv.es/jmanjon/denoising/naonlm3d.zip
    disp(' * Denoising with Rician OB-NLM-3D-WM ...  (may take a while)')
    addpath ./naonlm3d
    addpath ./naonlm3d/Wave3D

    h=sigma_hat; % noise std .dev.
    v=3;         % radius of search area
    radiusSmall=1;    % radius of similarity patch (small)
    radiusLarge=2;    % radius of similarity patch (large)
    r=1;     % Rician tag: Rician(1), Gaussian(0)
    fimau=MBONLM3D(z,v,radiusSmall,h,r);
    fimao=MBONLM3D(z,v,radiusLarge,h,r);
    %Mixing of the coefficient LLL of fimau and the high subbands of fimao
    nu_hat = mixingsubband(fimau,fimao);
    clear fimao fimau
end
%%

disp(['   completed in ',num2str(toc),' seconds']);
disp( '---------------------------------------------------------------');


if exist('nu','var')
    psnr_nu_hat=10*log10(range_for_PSNR^2/(mean((nu_hat(ind)-nu(ind)).^2)));
    disp(['PSNR of estimate nu_hat is ',num2str(psnr_nu_hat),' dB'])
end
disp( '---------------------------------------------------------------');  disp(' ');

