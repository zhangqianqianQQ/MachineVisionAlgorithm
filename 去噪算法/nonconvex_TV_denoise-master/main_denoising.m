%% This file demonstrates Forward-Backward Splitting (FBS) algorithms for Non-convex Total Variation denoising
%
% 
%   FBS_ATV.m  FBS algorithms for Non-convex Anisotropic Total Variation denoising
%   FBS_ITV.m  FBS algorithms for Non-convex Isotropic Total Variation denoising
%   SB_ATV.m  Split Bregman Anisotropic Total Variation Denoising
%   SB_ITV.m  Split Bregman Isotropic Total Variation Denoising
%   SB_ATV.m and SB_ITV.m are written by Benjamin Tr¨¦moulh¨¦ac, University
%   College London, which can be downloaded from 
%   https://www.mathworks.com/matlabcentral/fileexchange/36278-split-bregman-method-for-total-variation-denoising

% Refs:
%  *Jian Zou, Total Variation Denoising with Non-convex Regularizations
%   
%
% Jian Zou
% School of Information and Mathematics
% Yangtze University 
% zoujian@yangtzeu.edu.cn
clc; clear all;
close all;

N = 512; n = N^2;

f = zeros(N,N);
f(N/4:3*N/4,N/4:3*N/4)=255;
f(5*N/8:7*N/8,5*N/8:7*N/8)=128;
g = f+ randn(size(f))*25;



SB_mu = 20;

g_denoise_atv = SB_ATV(g,SB_mu);
g_denoise_natv = FBS_ATV(g,SB_mu );
g_denoise_itv = SB_ITV(g,SB_mu);
g_denoise_nitv = FBS_ITV(g,SB_mu);


fprintf('ATV Rel.Err = %g\n',norm(g_denoise_atv(:) - f(:)) / norm(f(:)));
fprintf('NATV Rel.Err = %g\n',norm(g_denoise_natv(:) - f(:)) / norm(f(:)));
fprintf('ITV Rel.Err = %g\n',norm(g_denoise_itv(:) - f(:)) / norm(f(:)));
fprintf('NITV Rel.Err = %g\n',norm(g_denoise_nitv(:) - f(:)) / norm(f(:)));



figure; 
colormap gray;
subplot(231); imagesc(f); axis image; title('Original');
subplot(232); imagesc(reshape(g,N,N)); axis image; title('Noisy');
subplot(233); imagesc(reshape(g_denoise_natv,N,N)); axis image; 
title('Anisotropic TV denoising');
subplot(234); imagesc(reshape(g_denoise_atv,N,N)); axis image; 
title('Nonconvex Anisotropic TV denoising');
subplot(235); imagesc(reshape(g_denoise_itv,N,N)); axis image; 
title('Isotropic TV denoising');
subplot(236); imagesc(reshape(g_denoise_nitv,N,N)); axis image; 
title('Nonconvex isotropic TV denoising');


