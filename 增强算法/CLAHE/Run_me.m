%% 鲁棒性测试——基于局部对比度增强的CLAHE算法
tic

%% 清空工作区与变量
clc;
clear;
for image_number=1:8
    imageName=strcat(num2str(image_number),'.jpg');
    img = imread(imageName);
    figure;
    imshow(img);
    title(['第',num2str(image_number),'幅图像的原图']);

    %% 在LAB空间进行去雾

    % RGB转LAB
    transform = makecform('srgb2lab');  
    LAB = applycform(img,transform);  

    % 提取亮度分量 L
    L = LAB(:,:,1); 

    % 对L进行CLAHE
    LAB(:,:,1) = My_adapthisteq(L);
    % 减小一定的亮度
    LAB(:,:,1) = LAB(:,:,1)-50;

    %% 转回到RGB空间
    cform2srgb = makecform('lab2srgb');  
    J = applycform(LAB, cform2srgb);

    %% 输出图像
    figure;
    J = 1.35.*J;
    imshow(J);  
    title(['第',num2str(image_number),'幅图像的去雾图像']);
    clc;
    clear;
end
    toc