function demo_MRCNN_with_Iterative_Localization
% object detection demo using the Multi-Region CNN recognition model 
% (sections 3 of the technical report) and the iterative localization 
% scheme (section 5 of technical report). 
% 
% This file is part of the code that implements the following ICCV2015 accepted paper:
% title: "Object detection via a multi-region & semantic segmentation-aware CNN model"
% authors: Spyros Gidaris, Nikos Komodakis
% institution: Universite Paris Est, Ecole des Ponts ParisTech
% Technical report: http://arxiv.org/abs/1505.01749
% code: https://github.com/gidariss/mrcnn-object-detection
% 
% 
% AUTORIGHTS
% --------------------------------------------------------
% Copyright (c) 2015 Spyros Gidaris
% 
% "Object detection via a multi-region & semantic segmentation-aware CNN model"
% Technical report: http://arxiv.org/abs/1505.01749
% Licensed under The MIT License [see LICENSE for details]
% ---------------------------------------------------------

gpu_id = 1; % gpu_id is a one-based index; if a non positive value is given
% then the CPU will be used instead.  

caffe_set_device( gpu_id );
caffe.reset_all();

%***************************** LOAD MODELS ********************************
fprintf('Loading detection models... '); th = tic;

% set the path of the bounding box recognition model for object detection
model_rec_dir_name  = 'MRCNN_VOC2007_2012'; % model's directory name 

full_model_rec_dir  = fullfile(pwd, 'models-exps', model_rec_dir_name); % full path to the model's directory
use_detection_svms  = true;
model_rec_mat_name  = 'detection_model_svm.mat'; % model's matlab filename
full_model_rec_path = fullfile(full_model_rec_dir, model_rec_mat_name); % full path to the model's matlab file
assert(exist(full_model_rec_dir,'dir')>0);
assert(exist(full_model_rec_path,'file')>0);

% set the path of the bounding box regression model 
model_loc_dir_name  = 'vgg_bbox_regression_R0013_voc2012_2007'; % model's directory name 
full_model_loc_dir  = fullfile(pwd, 'models-exps', model_loc_dir_name);
model_loc_mat_name  = 'localization_model.mat'; % model's matlab filename
full_model_loc_path = fullfile(full_model_loc_dir, model_loc_mat_name);  % full path to the model's matlab file
assert(exist(full_model_loc_dir,'dir')>0);
assert(exist(full_model_loc_path,'file')>0);


% Load the bounding box recognition moddel for object detection
ld = load(full_model_rec_path, 'model');
model_obj_rec = ld.model; 
model_phase_rec = 'test';
clear ld; 

model_obj_rec = load_object_recognition_model_on_caffe(...
    model_obj_rec, use_detection_svms, model_phase_rec, full_model_rec_dir);

% Load the bounding box regression model for object detection
ld = load(full_model_loc_path, 'model');
model_obj_loc = ld.model; 
clear ld;
model_obj_loc = load_bbox_loc_model_on_caffe(model_obj_loc, full_model_loc_dir);

% Load the activation maps module that is responsible for producing the
% convolutional features (called activation maps) of an image. For the
% activation maps module we use the convolutional layers (till conv5_3)
% of the VGG16 model

% set the path to the directory that contain the caffe defintion and 
% weights files of the  activation maps module
net_files_dir = fullfile(pwd,'data','vgg_pretrained_models'); 
% path to the defintion file of the activation maps module
model_obj_rec.act_net_def_file     = fullfile( net_files_dir,'vgg16_conv5_deploy.prototxt');
% path to the weights file of the activation maps module
model_obj_rec.act_net_weights_file = {fullfile(net_files_dir,'VGG_ILSVRC_16_Convolutional_Layers.caffemodel')};
assert(exist(net_files_dir,'dir')>0);
assert(exist(model_obj_rec.act_net_def_file ,'file')>0);
assert(exist(model_obj_rec.act_net_weights_file{1},'file')>0);
% image scales that are being used for extracting the activation maps 
model_obj_rec.scales   = [480 576 688 874 1200]; 
% mean pixel value per color channel for image pre-processing before 
% feeding it to the VGG16 convolutional layers.
model_obj_rec.mean_pix = [103.939, 116.779, 123.68]; 
% load the activation maps module on caffe
model_obj_rec.act_maps_net = caffe_load_model( model_obj_rec.act_net_def_file, model_obj_rec.act_net_weights_file);
fprintf(' %.3f sec\n', toc(th));
%**************************************************************************

img  = imread('./code/examples/images/000084.jpg'); % load image
category_names = model_obj_rec.classes; % a C x 1 cell array with the name 
% of the categories that the detection system looks for. C is the numbe of
% categories.
num_categories = length(category_names);


conf = struct;
% the threholds that are being used for removing easy negatives before the
% non-max-suppression step
conf.thresh = -3 * ones(num_categories,1); % It contains the 
% threshold per category that will be used for removing scored boxes with 
% low confidence prior to applying the non-max-suppression step.
conf.nms_iou_thrs = 0.3; % IoU threshold for the non-max-suppression step
conf.box_method = 'edge_boxes'; % string with the box proposals algorithm that
% will be used in order to generate the set of candidate boxes. Currently 
% it supports the 'edge_boxes' or the 'selective_search' types only.

conf.nms_iou_thrs_init  =  0.95;
conf.thresh_init        = -2.5 * ones(num_categories,1);
conf.num_iterations     =  2;

% detect object in the image
[ bbox_detections ] = demo_object_detection_with_iterative_loc( ...
    img, model_obj_rec, model_obj_loc, conf );


% visualize the bounding box detections.
score_thresh = 0 * ones(num_categories, 1); % score threshold per 
% category for keeping or discarding a detection. For the purposes of this
% demo we set the score thresholds to 0 value. However, this is not the
% optimal value. Someone should tune those thresholds in order to achieve
% the desired trade-off between precision and recall.
display_bbox_detections( img, bbox_detections, score_thresh, category_names );


caffe.reset_all(); % free the memory occupied by the caffe models


end