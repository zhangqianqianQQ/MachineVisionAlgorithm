clear
clc
close all
addpath('./tensor_fit/');
addpath('./RiceOptVST/');
addpath('./GL-HOSVD/');
addpath('./HOSVD/');
addpath('./data/in_vivo_data/');

load '6dir_b1000_NSA10.mat';
load 'bvalue.mat'
load 'gradient.mat'
load 'mask_slice_4th.mat'
[N1,N2,numDWI] = size(im_r); 
 
 % ---- noise estimation ---- %
idata  = im_r.^2; % assumption of the rician distribution
tdata  = idata(1:30,1:30,2:end);
for i  = 1:numDWI-1
    tbg = tdata(:,:,i);
    sigmas(i) = sqrt(mean(tbg(:))/2);
end
sigmah = mean(sigmas(2:end)); % estimate of sigma

 % ---- Setting up parameters ---- %
kglobal=0.4;
klocal=0.5; %the denoising effect can be improved by adjusting the parameter klocal 
 
% ---- start image denoising---- %
rimavst = riceVST(im_r,sigmah,'A');
ims_denoised =glhosvd(rimavst,1,kglobal,klocal);
ims_denoised = riceVST_EUI(ims_denoised ,sigmah,'A');

% ---- FA estimation---- %
display   = 0; bVal=bvalue';   bacq      = bvalue(2);
[FA_denoised, RGB_denoised, tensors_denoised, MD_denoised] = tensor_est(ims_denoised,gradientDirections,bVal,bacq,display,mask);
[FA_noisy, RGB_noisy, tensors_noisy,MD_noisy] = tensor_est(im_r,gradientDirections,bVal,bacq,display,mask);      
[FA_reference, RGB_reference, tensors_reference,MD_reference] = tensor_est(im_ref,gradientDirections,bVal,bacq,display,mask);      

% ---- Display results---- %
figure,imshow(FA_noisy,[0 1]);figure,imshow(FA_denoised,[0 1]);figure,imshow(FA_reference,[0 1])
figure,imshow(RGB_noisy,[]);figure,imshow(RGB_denoised,[]);figure,imshow(RGB_reference,[])
figure,imshow(im_r(:,:,5),[]);figure,imshow(ims_denoised(:,:,5),[]);figure,imshow(im_ref(:,:,5),[])
