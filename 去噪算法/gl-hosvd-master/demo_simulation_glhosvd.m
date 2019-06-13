clear all;clc;close all
addpath('./tensor_fit/');
addpath('./RiceOptVST/');
addpath('./GL-HOSVD/');
addpath('./HOSVD/');
addpath('./data/simulation/');

load 'TestData_Rician_SingleShellb2000.mat'; %%% This dataset can be downloaded from the homepage of Fan Lam
load Mask_simu_b2000.mat
[N1,N2,numDWI] = size(dwi);

for level=1:1:10
    
% im_r is the simulated noisy data with varying noise level
randn('seed',0);
im_r=sqrt((dwi+level*randn(size(dwi))/100).^2+(level*randn(size(dwi))/100).^2);

% noise estimation
idata  = im_r.^2;
tdata  = idata(1:40,1:40,:); % extract the background region, which may be different based on dataset
for i  = 1:numDWI
   tbg = tdata(:,:,i);
   sigmas(i) = sqrt(mean(tbg(:))/2);
end
sigmah = mean(sigmas(2:end)); % estimate of sigma
frame  = 6; % The frame to be display and tested for PSNR

%  start image denoising
tic
rimavst = riceVST(im_r,sigmah,'A');  
ims_denoised =glhosvd(rimavst,1,0.4,1);
ims_denoised = riceVST_EUI(ims_denoised ,sigmah,'A');
t_time(level)=toc

%  PSNR calculation
tmp=Mask;tmp=repmat(tmp,[1 1 numDWI]);ind=find(tmp>0);
PSNR_noisy(level)= PSNR(dwi(ind),im_r(ind));
PSNR_denoised(level) = PSNR(dwi(ind),ims_denoised(ind));

%  FA estimation and FA-RMSE calculation
bacq      = 2000;
display   = 0;ind=find(Mask>0);
[FA_noisefree, RGB_noisefree, tensors_noisefree, MD_noisefree] = tensor_est(dwi,gradientDirections,bVal,bacq,display,Mask);
[FA_noisy, RGB_noisy, tensors_noisy, MD_noisy] = tensor_est(im_r,gradientDirections,bVal,bacq,display,Mask);
[FA_denoised, RGB_denoised, tensors_denoised, MD_denoised] = tensor_est(ims_denoised,gradientDirections,bVal,bacq,display,Mask);
error_FA_noisy(level)=RMSE(FA_noisefree(ind),FA_noisy(ind))
error_FA_denoised(level)=RMSE(FA_noisefree(ind),FA_denoised(ind))
end

outputfname = ['GLHOSVD_rician.mat'];
save(outputfname, 'PSNR_noisy', 'PSNR_denoised','error_FA_noisy', 'error_FA_denoised');
