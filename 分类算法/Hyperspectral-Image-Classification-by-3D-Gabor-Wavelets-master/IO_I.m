% 此脚本将Indian Pine Site数据读入，并且做Gabor变换后存储到一个矩阵中
% 在Indian Pine最外层脚本的开始处调用
clc;
clear all;
disp('importing...');

load Indian_pines_corrected.mat;  %校正后200波段矩阵
load Indian_pines_gt.mat;    %标签矩阵

global indian_pines_gt;
global indian_pines_corrected;

disp('import complete!')
