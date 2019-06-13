%% Initialization step       %%
%% Written by Ning Zhang     %%

% Add caffe matlab wrapper path.
% Change to your path
config.CAFFE_MATLAB_PATH = '/u/vis/nzhang/projects/caffe/matlab/caffe/';
addpath(config.CAFFE_MATLAB_PATH)

% Add liblinear package path
% Change to your path
addpath(genpath('/u/vis/nzhang/projects/birdmix/kdes_2.0/liblinear-1.5-dense-float'));

% Define pretrained model definition files and pretrained model paths.
model_def = 'caches/cub_finetune_deploy_fc7.prototxt';
cnn_models{1} = 'caches/CUB_bbox_finetune.caffemodel';
cnn_models{2} = 'caches/CUB_head_finetune.caffemodel';
cnn_models{3} = 'caches/CUB_body_finetune.caffemodel';
 
