% =========================================================================
% Spatial-Aware Collaborative Representation for Hyperspectral Remote Sensing Image Classification
% Example code
%
% Reference
% [1] J. Jiang, C. Chen, Y. Yu, X. Jiang, and J. Ma, ¡°Spatial-Aware CollaborativeRepresentation 
%     for Hyperspectral Remote Sensing Image Classification,¡± IEEE Geoscience and Remote Sensing Letters,
%     vol. 14, no. 3, pp. 404-408, 2017. 
%
% For any questions, email me by junjun0595@163.com
%=========================================================================

clc;clear all; 
close all;

addpath('utilities');
addpath('.\data');

load Indian_pines_corrected;load Indian_pines_gt;load Indian_pines_randp 
data = indian_pines_corrected;
gth  = indian_pines_gt;

% smoothing
for i=1:size(data,3);
    data(:,:,i) = imfilter(data(:,:,i),fspecial('average',7));
end

% parameter settings
c      = 4;
lambda = 0.01;
gamma  = 1;

for iter = 1:10        
    randpp=randp{iter};  
    % randomly divide the dataset to training and test samples
    ratio = 0.1;
    [DataTest DataTrain CTest CTrain] = samplesdivide(data,gth,ratio,randpp);
    
    % SaCR Classification
    class = JSaCR_Classification(DataTrain, CTrain, DataTest, lambda, c, gamma);
    [confusion, accur_NRS, TPR, FPR] = confusion_matrix_wei(class, CTest);
    fprintf('\n The OA of the %dth iteration is %f\n', iter, accur_NRS);
end