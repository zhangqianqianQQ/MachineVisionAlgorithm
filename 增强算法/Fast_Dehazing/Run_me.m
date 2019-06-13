%% 鲁棒性测试——实时去雾算法
clc;
clear;
tic
for image_number=1:8
    imageName=strcat(num2str(image_number),'.jpg');
    
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 第一步 读取图像并简单处理
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    I = imread(imageName);
    figure;
    imshow(I);
    title(['第',num2str(image_number),'幅图像的原图']);

    % 归一化到[0,1]
    I = double(I)/255.0;  

    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
    % 第二步: 求取I的三个通道的最小值矩阵M
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    M = min(I,[],3);  

    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 第三步: 对M进行均值滤波，得到Mave(x)  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    [height,width] = size(I);  
    mask = ceil(max(height, width) / 50);  
    if mod(mask, 2) == 0  
        mask = mask + 1;  
    end  
    f = fspecial('average', mask);  
    M_average = imfilter(M, f, 'symmetric');     

    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 第四步: 求取M(x)中所有元素的均值Mav 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    [height, width] = size(M_average);  
    M_average_value = sum(sum(M_average)) / (height * width);  

    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 第五步: 利用M_average求出环境光度 L 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    % delta值越大，去雾后的图像越暗，去雾效果越好
    % delta值越小，去雾后的图像越白，去雾效果越差  
    delta = 2.0;    
    L = min ( min( delta*M_average_value,0.9)*M_average, M);  

    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 第六步: 利用M_average和I，求出全局大气光 A
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    Matrix = [1;...
              1;...
              1];
    A = 0.5 * ( max( max( max(I, [], 3) ) ) + max( max(M_average) ) )*Matrix;  


    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 第七步: 利用A、L和I求出去雾图
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [height, width, dimention] = size(I);  
    I_defog = zeros(height,width,dimention);  
    for i = 1:dimention  
        I_defog(:,:,i) = (I(:,:,i) - L) ./ (1 - L./A(i));  
    end  
    toc 
    figure;
    imshow(I_defog);
    title(['第',num2str(image_number),'幅图像的去雾图像']);
    clc;
    clear;
end
    

