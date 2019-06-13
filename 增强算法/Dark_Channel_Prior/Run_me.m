%% 鲁棒性测试——基于容差的暗通道先验去雾算法

tic
%% 第一步 读取图像，获得尺寸的基本信息
%清空
clear;     
clc;       
for image_number=1:8
    imageName=strcat(num2str(image_number),'.jpg');
    I = imread(imageName);
    figure;
    imshow(I,[]);
    title(['第',num2str(image_number),'幅图像的原图']);

    % 获取图像大小和维度
    [height,width,dimention] = size(I);

    %% 第二步 获取暗通道图像

    % 最小值滤波窗口大小为 15 = 7*2+1
    window_size = 7;
    % 调用My_darkchannel函数
    dark_channel =  My_darkchannel(I,window_size);
    dark_channel = dark_channel./255;

    %% 第三步 计算大气光成分A
    % A为1*1*3的矩阵，即提取出了RGB三个光照成分
    I = im2double(I);
    % 调用My_estimateA函数
    A = My_estimateA(I,dark_channel);

    %% 计算透射率矩阵t(x)
    % 去雾完全系数，w = 1完全去雾
    w = 0.95;

    % 用暗通道估计透射率  
    t = 1-w*dark_channel/mean(A(1,1,:));

    % 获取灰度图片
    I_gray = rgb2gray(I);

    % 用导向滤波对t进行优化
    % 调用My_guidedfilter函数软抠图优化透射率矩阵
    t1 = My_guidedfilter(I_gray, t, 135, 0.0002);

    % 用导向滤波对投射率矩阵
    % 进行保边缘模糊
    t2 = My_guidedfilter(t1,t1,7,0.03);

    % 透射图阈值，防止投射图很小的时候图像像素值过大
    t_treshold = 0.1;
    % 取t0=0.1防止整体向白场过度，小于0.1的值取0.1

    t = max(t2,t_treshold);


    %% 第四步 恢复无雾图像

    % 引进容差
    K = 0.2;
    % 初始化去雾图像
    defog_image = zeros(size(I));

    % 用改进公式分三个通道进行去雾
    defog_image(:,:,1) = ((I(:,:,1)-A(1,1,1))...
                            ./min(1,t.*max( K./abs(I(:,:,1)-A(1,1,1)),1) ...
                            )) +A(1,1,1);
    defog_image(:,:,2) = ((I(:,:,2)-A(1,1,2))...
                            ./min(1,t.*max( K./abs(I(:,:,2)-A(1,1,2)),1) ...
                            )) +A(1,1,2);

    defog_image(:,:,3) = ((I(:,:,3)-A(1,1,3))...
                            ./min(1, t.*max( K./abs(I(:,:,3)-A(1,1,3)),1) ...
                            )) +A(1,1,3);


    % dark channel prior方法会使图片变暗
    % 乘系数使得图片亮
    defog_image = defog_image*1.3;

    %% 第五步 输出无雾图像
    figure;
    imshow(defog_image);
    title(['第',num2str(image_number),'幅图像的去雾图像']);
    clear;     
    clc;     
end
    toc

