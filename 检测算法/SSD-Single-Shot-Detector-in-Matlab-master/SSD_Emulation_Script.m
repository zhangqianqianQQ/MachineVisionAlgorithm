%% 
%-----------SSD_Emulation_Script--------
%作  者：杨帆
%公  司：BJTU
%功  能：SSD模拟程序(for pic)。
%输  入：
%       Img_Path    -----> 输入图像路径。
%       Description -----> Prior Box 参数结构体。
%输  出：
%       
%备  注：Matlab 2016a。
%----------------------------------------

%%
% 清空工作空间

clear all;
clc
addpath './Layers';

%%
% 初始参数设定

Img_Path = 'pedestrian2.jpg';

Description.aspect_ratio(1).r = [2, 1/2];
Description.aspect_ratio(2).r = [2, 1/2, 3, 1/3];
Description.aspect_ratio(3).r = [2, 1/2, 3, 1/3];
Description.aspect_ratio(4).r = [2, 1/2, 3, 1/3];
Description.aspect_ratio(5).r = [2, 1/2];
Description.aspect_ratio(6).r = [2, 1/2];

Description.feature_size = [38, 38; 19, 19; 10, 10; 5, 5; 3, 3; 1, 1];
Description.scale = [0.15, 0.2, 0.37, 0.54, 0.71, 0.88];

%%
% 图像读取。

img = imread(Img_Path);

%%
% 网络声明（开启代码探查）

% profile on;
net = Load_Net();
roi_table = SSD_Net(net, img, 21, Description);
% profile off;
% profile viewer;

%%
% 非极大值抑制

img = imread(Img_Path);
img = im2double(img);
[height, width, channel] = size(img);
roi_table(:, 3) = round(width * roi_table(:, 3)) + 1;
roi_table(:, 4) = round(height * roi_table(:, 4)) + 1;
roi_table(:, 5) = round(width * roi_table(:, 5));
roi_table(:, 6) = round(height * roi_table(:, 6));

pick = NMS(roi_table, 0.45, 'NULL');
result_img = img;

for i = 1: length(pick)
    roi = roi_table(pick(i),:);
    left_x = roi(3);
    left_y = roi(4);
    right_x = roi(5);
    right_y = roi(6);

    result_img = drawRect( result_img, [left_x, left_y], ...
        [right_x - left_x, right_y - left_y], 3, [0, 255, 0]);
    imshow(result_img);
end

%%
% 特征图可视化

% feature_map = conv4_3_norm;
% 
% for i = 1: size(feature_map, 3)
%     imagesc((feature_map(:,:,i) - min(min(feature_map(:,:,i)))) ...
%         / (max(max(feature_map(:,:,i)))));
%     title(int2str(i));
%     pause(2);
% end

%%
% 卷积核可视化

% kernel = net.conv1_1_w;
% for i = 1: size(kernel, 4)
%     k_map = kernel(:,:,:,i);
%     k_min = min(min(min(k_map)));
%     k_max = max(max(max(k_map)));
%     subplot(8, 8, i);
%     imshow(imresize((k_map - k_min) / (k_max - k_min), [50, 50]));
%     title(int2str(i));
% end
