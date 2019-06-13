%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   My_homofilter：同态滤波算法
%   输入：灰度图I_mean
%   输出：同态滤波后的灰度图output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [output] = My_homofilter(I_mean)
    %% 第一步 取对数并进行傅里叶变换
    I_log = log(I_mean+1);
    % 傅里叶变换
    I_fft = fft2(I_log);
    I_fft = fftshift(I_fft);

    %% 第二步 频域高斯高通滤波
    
    % 高斯滤波器的参数
    L = 0.3;
    H = 1.8;
    C = 2;
    % 截止频率D0
    D0 = 1;

    % 生成mask
    [height,width] = size(I_mean);
    mask = zeros(height,width);
    for i=1:height
        for j=1:width
            % 根据距离中心的距离来
            D = sqrt(((i-height/2)^2+(j-width/2)^2));
            mask(i,j) = (H-L)*(1-exp(C*(-D/(D0))))+L; %高斯同态滤波
        end
    end
%     % 显示mask的图像
%     figure;
%     imshow(mask,[]);   
%     title('mask的图像');

    % 用mask进行点乘
    I_fft_gauss = mask.*I_fft;
    
    %% 第三步 傅里叶逆变换并取指数
    I_fft_gauss = ifftshift(I_fft_gauss);
    
    I_ifft = ifft2(I_fft_gauss);
    % 取指数，恢复原图
    I_gray_defog = real(exp(I_ifft)+1);
    
    output = I_gray_defog;
end