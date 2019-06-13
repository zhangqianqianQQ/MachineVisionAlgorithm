%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script is used to generate the training and test samples which 
% are saved as hdf5 format for the caffe input
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all;
clear all;
clc;

addpath('drtoolbox');
addpath('drtoolbox/gui');
addpath('drtoolbox/techniques');
addpath('caffe-master/matlab/hdf5creation');

%%%%%%%%%%%%%%%%%  Load dataset and groundtruth %%%%%%%%%%%%%%%%%%
%% for Indian Pines, the size of input is 25*25*3 %%%%%%%%%%%%%%%%
% load datasets/Indian_pines_gt.mat;
% load datasets/Indian_pines_corrected.mat;
% dir='caffe-master/data/indian_pines/';
% savepath_train = strcat(dir,'/train.h5');
% savepath_test  = strcat(dir,'/');
% 
% pad_size=12;
% num_bands=3;
% input_size=2*pad_size+1;
% no_classes=16;   
% 
% img=indian_pines_corrected;
% [I_row,I_line,I_high] = size(img);
% img=reshape(img,I_row*I_line,I_high);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% for University of Pavia, the size of input is 23*23*5  %%%%%
load datasets/PaviaU.mat;
load datasets/PaviaU_gt.mat;
dir='caffe-master/data/paviau/';
savepath_train = strcat(dir,'/train.h5');
savepath_test  = strcat(dir,'/');

count_batch_test=5;
pad_size=11;
num_bands=5;
input_size=2*pad_size+1;
no_classes=9;   

img=paviaU;
[I_row,I_line,I_high] = size(img);
img=reshape(img,I_row*I_line,I_high);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% for Salinas, the size of input is 27*27*10  %%%%%
% load datasets/Salinas_corrected.mat;
% load datasets/Salinas_gt.mat;
% dir='caffe-master/data/salinas/';
% savepath_train = strcat(dir,'/train.h5');
% savepath_test  = strcat(dir,'/');
% 
% count_batch_test=5;
% pad_size=13;
% num_bands=10;
% input_size=2*pad_size+1;
% no_classes=16;   
% 
% img=salinas_corrected;
% [I_row,I_line,I_high] = size(img);
% img=reshape(img,I_row*I_line,I_high);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%  Dimension-reducing by PCA  %%%%%%%%%%%%%%%%%%%%%%%
im=img;
im=compute_mapping(im,'PCA',num_bands);
im = mat2gray(im);
im =reshape(im,[I_row,I_line,num_bands]);
[I_row,I_line,I_high] = size(im);


%%%%%  scale the image from -1 to 1
im=reshape(im,I_row*I_line,I_high);
[im ] = scale_func(im);
im =reshape(im,[I_row,I_line,I_high]);
%%%%%% extending the image %%%%%%%%
im_extend=padarray(im,[pad_size,pad_size],'symmetric');

[r,l,b]=size(im_extend);
im_extend=reshape(im_extend,[r*l,b]);
im_extend=im_extend-repmat(mean(im_extend),r*l,1);
im_extend=reshape(im_extend,[r,l,b]);



% [train_label,test_label,unlabeled_label,train_index,test_index,unlabeled_index] ...
%        = generating_index('indian_pines',indian_pines_gt,no_classes);
    
[train_label,test_label,unlabeled_label,train_index,test_index,unlabeled_index] ...
       = generating_index('paviau',paviaU_gt,no_classes);

% [train_label,test_label,unlabeled_label,train_index,test_index,unlabeled_index] ...
%        = generating_index('salinas',salinas_gt,no_classes);   

[TRAIN_DATA, TRAIN_LABEL, TRAIN_INDEX] = write_save_h5('train', input_size,pad_size, ...
                     I_row, I_high,train_label,train_index, savepath_train, im_extend) ;

[TEST_DATA, TEST_LABEL, TEST_INDEX] = write_save_h5('test', input_size,pad_size, ...
                     I_row, I_high,test_label,test_index, savepath_test, im_extend) ;                  


save auxiliary_data/indian_pines/data.mat TRAIN_INDEX TEST_INDEX TEST_LABEL TRAIN_LABEL 
%save auxiliary_data/paviau/data.mat TRAIN_INDEX TEST_INDEX TEST_LABEL TRAIN_LABEL     
%save auxiliary_data/salinas/data.mat TRAIN_INDEX TEST_INDEX TEST_LABEL TRAIN_LABEL
