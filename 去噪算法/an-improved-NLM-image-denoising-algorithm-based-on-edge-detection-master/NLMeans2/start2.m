I=imread('barbara256.bmp'); %原始图
[m,n] = size(I);         %图的大小
I=double(I);

%加噪声
std_n=40; % 高斯噪声标准差
In = randn(size(I))*std_n; % 高斯随机噪声
IO = I + In;  % IO为含噪声图像

%参数 
h=0.8*std_n; %滤波参数
t=5;   %相似窗半径
f=3;   %搜索窗半径

IO1=NLmeans(IO,t,f,h);% I01为NL-Means去噪后的图像

tic;
fs=fspecial('gaussian');
IO_=imfilter(IO,fs,'symmetric');

edge=sobel8_grad(IO_);

IO2=NLmeans2(IO,t,f,h,edge);% I02为本方法去噪后的图像
toc;
t=toc;
% 显示原始图像、噪声图像、NL-Means去噪图像、NL-Means噪声残留、本方法去噪图像、本方法去噪残留
figure(1); imshow(uint8(I));
figure(2); imshow(uint8(IO));
figure(3); imshow(uint8(IO1));
figure(4); imshow(uint8(IO-IO1));
figure(5); imshow(uint8(IO2));
figure(6); imshow(uint8(IO-IO2));

imwrite(uint8(I),'result1.bmp');
imwrite(uint8(IO),'result2.bmp');
imwrite(uint8(IO1),'result3.bmp');
imwrite(uint8(IO-IO1),'result4.bmp');
imwrite(uint8(IO2),'result5.bmp');
imwrite(uint8(IO-IO2),'result6.bmp');

psnr1=PSNR(I,IO1);
mse1=MSE(I,IO1);
fprintf('PSNR1=%f\n',psnr1);
fprintf('MSE1=%f\n',mse1);
psnr2=PSNR(I,IO2);
mse2=MSE(I,IO2);
fprintf('PSNR2=%f\n',psnr2);
fprintf('MSE2=%f\n',mse2);
[mssim1 ssim_map1]=ssim_index(IO, IO1);
fprintf('SSIM1=%f\n',mssim1);
[mssim2 ssim_map2]=ssim_index(IO, IO2);
fprintf('SSIM2=%f\n',mssim2);
fprintf('time=%f\n',t);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
