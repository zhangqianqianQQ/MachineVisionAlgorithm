% clear all;
% close all;
% %%%pavia University
% input_files.data_file='./data/PaviaU.mat';
% input_files.gt_file='./data/PaviaU_gt.mat';
% output_file_name='./results/Pavia_U_pca.mat';
% pca_dim=10;
% prepare_data_gt(input_files, output_file_name, pca_dim);

addpath('./pca_ica/');

clear all;
close all;
%%%pavia University
input_files.data_file='./data/Indian_pines_corrected.mat';
input_files.gt_file='./data/indian_pines_gt.mat';
output_file_name='./results/Indian_pines_pca.mat';
pca_dim=30;
prepare_data_gt(input_files, output_file_name, pca_dim);


% clear all;
% close all;
% 
% input_files.data_file='./data/Salinas_corrected.mat';
% input_files.gt_file='./data/Salinas_gt.mat';
% output_file_name='./results/Salinas_pca.mat';
% pca_dim=10;
% prepare_data_gt(input_files, output_file_name, pca_dim);