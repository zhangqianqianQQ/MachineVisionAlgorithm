
%% Parameters

%%% Network model parameters
ODCNN_params.caffe_path = '/usr/local/caffe-dev/matlab/caffe';
ODCNN_params.use_gpu = true;
ODCNN_params.model_def_file = '/media/lifelogging/HDD_2TB/Object-Detection-CNN/trained_CNN/train_val_finetunning_test.prototxt';
%%% Obj > 0.6 NoObj < 0.3
% ODCNN_params.trained_net_file = '/media/lifelogging/HDD_2TB/Object-Detection-CNN/trained_CNN/objDetectCNN_finetunning_v2_iter_18000.caffemodel';
%%% Obj > 0.7 NoObj < 0.2
ODCNN_params.trained_net_file = '/media/lifelogging/HDD_2TB/Object-Detection-CNN/trained_CNN/objDetectCNN_finetunning_strict_v1_iter_70000.caffemodel';

%%% Batch preparation parameters
ODCNN_params.batch_size = 50;
ODCNN_params.parallel = true; % use parallel computation or not

%%% Windows Merge parameters
% 'IoU': intersection over union, 'NMS': non-maximal suppression, 'MS': match score
ODCNN_params.mergeType = 'MS';
ODCNN_params.minObjVal = 0.75; % minimum objectness value threshold to consider a positive window as an object
ODCNN_params.mergeScales = true; % (DEPRECATED, always TRUE) merge windows from different scales or not?
ODCNN_params.mergeThreshold = 0.45; % threshold used for any of the merging methods

%%% Sliding window parameters
ODCNN_params.stride = 24; % pixel separation between each processed patch
ODCNN_params.input_patch = 256; % size of the input patch needed for the net
ODCNN_params.patch_size = [100 100]; % size of the crops on the image
ODCNN_params.patch_props_sw = [[1 1]; [0.75 1]; [0.5 1]; [1 0.75]; [1 0.5]];
ODCNN_params.scales_sw_ratio = 1.35;
ODCNN_params.scales_stride_ratio = 0.9;
ODCNN_params.nScales = 6;

% Automatically calculated
ODCNN_params.scales_sw = 0:ODCNN_params.nScales-1;
ODCNN_params.scales_sw = ODCNN_params.scales_sw_ratio.^ODCNN_params.scales_sw;

ODCNN_params.scales_stride = 0:ODCNN_params.nScales-1;
ODCNN_params.scales_stride = ODCNN_params.scales_stride_ratio.^ODCNN_params.scales_stride;
% ODCNN_params.scales = [1 0.85 0.71 0.51 0.36 0.21]; % old ratios

%% Paths to images
path_maps = 'Maps';

path_images = '/media/lifelogging/Shared SSD/Object Discovery Data/Video Summarization Project Data Sets/MSRC/JPEGImages';
% path_images = '/Volumes/SHARED HD/Video Summarization Project Data Sets/MSRC/JPEGImages';
% path_images = '/Volumes/SHARED HD/Video Summarization Project Data Sets/PASCAL_12/VOCdevkit/VOC2012/JPEGImages';

format = '.JPG';

%% Parameters for runODCNN
train_val_split = 'Data_Preparation/train_val_split.mat';

% path_objects = '/Volumes/SHARED HD/Video Summarization Objects/Features';
% path_objects = '/media/lifelogging/HDD_2TB/Video Summarization Objects/Features';
path_objects = '/home/cvc/mbolanos/Objects_Structures';

% list_paths_images = {'/Volumes/SHARED HD/Video Summarization Project Data Sets/MSRC/JPEGImages', ...
%     '/Volumes/SHARED HD/Video Summarization Project Data Sets/PASCAL_12/VOCdevkit/VOC2012/JPEGImages'};
list_paths_images = {'/media/lifelogging/Shared SSD/Object Discovery Data/Video Summarization Project Data Sets/MSRC/JPEGImages', ...
    '/media/lifelogging/Shared SSD/Object Discovery Data/Video Summarization Project Data Sets/PASCAL_12/VOCdevkit/VOC2012/JPEGImages'};

% MSRC 1.25, PASCAL 1
prop_res = {1.25, 1};

objects_folders = {'Data MSRC Ferrari', 'Data PASCAL_12 Ferrari'};


    
addpath('Utils;Windows_Merging;Windows_Merging/NMS;Main_Run;Results_Evaluation');
