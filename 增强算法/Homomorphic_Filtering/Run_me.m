%% 鲁棒性测试——基于同态滤波的去雾算法

tic
%% 清空工作区与变量
clc;
clear;
for image_number=1:8
    imageName=strcat(num2str(image_number),'.jpg');
    I = imread(imageName);
    figure;
    imshow(I);
    title(['第',num2str(image_number),'幅图像的原图']);

    %% 进行同态滤波
    % 取三个通道的平均灰度作为参照
    I_mean = mean(I,3);
    % 去double方便对数运算
    I_mean = im2double(I_mean);

    % 调用同态滤波函数
    I_gray_defog = My_homofilter(I_mean);

    % 归一化到[0,1]
    max_pixel = max(max(I_gray_defog));
    I_gray_defog = mat2gray(I_gray_defog,[0,max_pixel]);

    %% 利用同态滤波后的平均灰度来映射
    % 分三个通道
    I_defog = zeros(size(I));
    for i = 1:3
        % 用去雾的平均灰度来映射
        I_defog(:,:,i) = (double(I(:,:,i)).*I_gray_defog)./I_mean ;
    end

    % 归一化到[0,1]
    max_pixel = max( max( max(I_defog) ) );
    min_pixel = min( min( min(I_defog) ) );
    I_defog = mat2gray(I_defog,[min_pixel,max_pixel]);
    % 提升亮度
    I_defog = 1.35.*I_defog;

    %% 输出图像
    figure;
    imshow(I_defog,[]);
    title(['第',num2str(image_number),'幅图像的去雾图像']);
    clc;
    clear;
end
toc
