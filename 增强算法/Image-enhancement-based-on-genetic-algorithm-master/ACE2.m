clc;
clear;
%% 读入图像
img = imread('1.jpg');
[m,n,index] = size(img);
C = 2;
%% 低通滤波处理 
% GS = fspecial('gaussian', [5 5], 2);
% img2 = imfilter(img,GS,'same');

%% 低频成分
I_H = cg(img,50);
img3 =I_H + C * (double(img) - I_H);
img3 = uint8(img3);
%% 遗传算法
% f = @(C) psnr(double(img) + cg(I_H,50)+C*(I_H-cg(I_H,50)),double(img));
% C = ga(f,1,[],[],[],[],1.1,2);
%% 图像增强
% ME = cg(I_H,50);
% I_HE =ME + C*(I_H-ME); %I_HE = cg(I_H,50)+C*(I_H-ME)
% img_f = double(img) + I_HE; %img_f = double(img) + cg(I_H,50)+C*(I_H-ME)
% img_r = uint8(img_f);
PS = psnr(img3,img)
%% 输出图像
figure(100)
imshow([img img3]);
title(['原始图像','增强图像']);
% imshow(img_r)

%原始图像
figure(200)
subplot(231)
imshow(img(:,:,1))
title('原始R')
subplot(234)
imhist(img(:,:,1))
title('原始R')

subplot(232)
imshow(img(:,:,2))
title('原始G')
subplot(235)
imhist(img(:,:,2))
title('原始G')

subplot(233)
imshow(img(:,:,3))
title('原始B')
subplot(236)
imhist(img(:,:,3))
title('原始B')

%增强图像
figure(300)
subplot(231)
imshow(img3(:,:,1))
title('增强R')
subplot(234)
imhist(img3(:,:,1))
title('增强R')

subplot(232)
imshow(img3(:,:,2))
title('增强G')
subplot(235)
imhist(img3(:,:,2))
title('增强G')

subplot(233)
imshow(img3(:,:,3))
title('增强B')
subplot(236)
imhist(img3(:,:,3))
title('增强B')
