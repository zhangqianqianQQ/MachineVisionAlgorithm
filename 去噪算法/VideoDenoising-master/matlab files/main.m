% close all
% clear all
% clc
num=64;
% load('for128');     %load frame sequence
% load('train150.mat');
load('hall300.mat');
% load('ma108.mat');
% load('Football128.mat');
% load('gait.mat');
% load('cam.mat');
% load('FlowerGarden114.mat');
x2=double(x(:,:,1:num));      %calculating for N frames: here N=8
z=zeros(size(x2));
noisy=uint8(zeros(size(x2)));
[a b]=size(x(:,:,1));
%%
% hall:           20dB - 26.2700, 25dB - 14.6600, 30dB - 8.2200
% miss america:   20dB - 25.8200, 25dB - 14.3600, 30dB - 8.0800
% train:          20dB - 26.9800, 25dB - 14.7200, 30dB - 8.1900
% foreman:        20dB - 26.1900, 25dB - 14.4200, 30dB - 8.0700    

%% DWT
[ld hd lr hr]=wfilters('db2');  %using debauchies length 4 wavelet
for i=1:num
    noisy(:,:,i)=uint8(x2(:,:,i)+(26.2700*randn(a,b)));     %0.0998,0.0562,0.03165 %25.48,14.34,8.07
    noisy1=double(noisy(:,:,i));
    z(:,:,i)=(multistep(noisy1,3,ld));        %performing N level wavelet decomposition: here N=3
end
[n m o]=size(z);


%% WHT

Wh=walsh_hadamard(o);        %calculating the walsh hadamard transfor matrix
z1=zeros(size(z));
for i=1:n
    for j=1:m
        a=zeros(1,o);
        a(1:o)=z(i,j,:);
        b=Wh*a';            %taking the wht in the temporal direction
        z1(i,j,:) =b';
    end
end


%% THRESHOLDING

sigmasq=zeros(1,o);
for i=1:o
    sigmasq(i)=noise_sigma_sq(z1(:,:,i));   %estimating the noise variance from the finest level subband HH1
end
sigmasq;
thresholded=zeros(size(z1));
thresholded1=zeros(size(z1));
for i=1:o
%     thresholded(:,:,i)=bayesian_th(z1(:,:,i),sigmasq(i),3);
      thresholded1(:,:,i)=map9(z1(:,:,i),sigmasq(i),3);
      thresholded(:,:,i)=mmse7(z1(:,:,i),thresholded1(:,:,i),sigmasq(i),3);
%      thresholded(:,:,i)=exp_max_try(z1(:,:,i),sigmasq(i),3);
end

% thresholded=z1;
%% IWHT

z2=zeros(size(thresholded));
for i=1:n
    for j=1:m
        a=zeros(1,o);
        a(1:o)=thresholded(i,j,:);
        b=(1/o)*Wh*a';            %taking the inverse wht in the temporal direction
        z2(i,j,:) =b';
    end
end


%% IDWT

z3=zeros(size(z2));
for i=1:num
    z3(:,:,i)=inverse_multistep(3,z2(:,:,i),ld);        %performing N level inverse wavelet tranform (reconstruction): here N=3
end
denoised=uint8(z3);
% denoised=zeros(size(z3));
% for i=1:num
%     denoised(:,:,i)=im2double(im2uint8(z3(:,:,i)));
% %     denoised(:,:,i)=mat2gray(z3(:,:,i));
% end

%% Temporal Filtering

T=24;
alpha=0.7;
for i=2:num
denoised(:,:,i)= temporal(denoised(:,:,i), denoised(:,:,i-1), alpha, T);
i;
end

%% PSNR

sigmasq;
for i=1:60
    psnr_n(i)=psnr(x2(:,:,i),double(noisy(:,:,i)));
    psnr_d(i)=psnr(x2(:,:,i),double(denoised(:,:,i)));
end
psnr_noisy=(1/60)*sum(psnr_n(:))
psnr_denoised=(1/60)*sum(psnr_d(:))
% x:original sequence
% noisy:noisy image
% z:wavelet decomposed sequence
% z1:WH transformed sequence
% thresholded
% denoised:denoised sequence