%%%%%%%%%%%%%等效视数
%%原始图像
%均值计算
function ENL=enl(noise_sar,denoise_sar)
noise_sar=double(noise_sar);
ybar=mean(mean(noise_sar));
ystad=std2(noise_sar);
original_ENL=(ybar/ystad)^2
mean_original=ybar;
ystad^2

fro=double(denoise_sar);
ybar=mean(mean(denoise_sar));
ystad=std2(denoise_sar);
ENL=(ybar/ystad)^2
PM=ybar/mean_original
ystad^2

