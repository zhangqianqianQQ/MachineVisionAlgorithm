function script_train_net_bbox_rec_pascal(model_dir_name, varargin)
% script_train_net_bbox_rec_pascal(model_dir_name, ...): it trains a single 
% region adaptation module on top of the activation maps produced from the
% last convolutional layer of the VGG16 network (see sections 3 and 6 of  
% the technical report). 
% 
% The current function creates the directory "./models-exps/{model_dir_name"
% where the trained model will be saved.
%
% For training the PASCAL dataset is used. By default the current scripts 
% trains the region adaptation module on the union of the PASCAL VOC2007 
% train+val and VOC2012 train+val datasets using both the selective search 
% and the edge box proposals and flipped version of the images.
%
% Before start training you have to pre-cache the activation maps 
% (convolutional feature maps) of the PASCAL images that are going to be
% used from the training and validation sets.
% 
%
% INPUTS:
% 1) model_dir_name: string with the name of the directory where the
% trained region adaptation module willl be saved. The directory will be
% created on the location ./models-exps/{model_dir_name}
% The rest input arguments are given in the form of Name,Value pair 
% arguments and are:
% ************************* REGION PARAMETERS *****************************
% 'scale_inner': scalar value with the scaling factor of the inner rectangle 
% of the region. In case this value is 0 then actually no inner rectangle 
% is being used
% 'scale_outer': scalar value with the scaling factor of the outer rectangle 
% of the region. 
% 'half_bbox': intiger value in the range [1,2,3,4]. If this parameter is set
% to 1, 2, 3, or 4 then each bounding box will be reshaped to its left, 
% right, top, or bottom half part correspondingly. This action is performed
% prior to scaling the box according to the scale_inner and scale_outer 
% params. If this parameter is missing or if it is empty then the action of 
% taking the half part of bounding box is NOT performed.
% ************************** TRAINING SET *********************************
% 'train_set': a Ts x 1 or 1 x Ts cell array with the PASCAL VOC image set
% names that are going to be used for training the region adaption module,
% Default value: {'trainval','trainval'}
% 'voc_year_train': a Ts x 1 or 1 x Ts cell array with the PASCAL VOC 
% challenge years (in form of strings) to which the to which the region 
% adaptation module will be trained. Examples:
%   a) train_set = {'trainval'}; voc_year_train = {'2007'};
%   the region adaptation module will be trained on VOC2007 train+val
%   dataset
%   b) train_set = {'trainval'}; voc_year_train = {'2012'};
%   the region adaptation module will be trained on VOC2012 train+val
%   dataset
%   c) train_set = {'trainval','trainval'}; voc_year_train = {'2007','2012'};
%   the region adaptation module will be trained on the union of VOC2007 
%   train+val plus VOC2012 train+val datasets.
% 'proposals_method_train': a Tp x  1 or 1 x Tp cell array with object
% proposals that will be used for training the region adaptation module,
% e.g. {'edge_boxes'}, {'selective_search'}, or {'selective_search','edge_boxes'}.
% Default value: {'selective_search','edge_boxes'}
% 'train_use_flips': a boolean value that if set to true then flipped
% versions of the images are being used during training. Default value: true
% 
% Briefly, by default the current script trains the region adaptation 
% module on the union of the PASCAL VOC2007 train+val and VOC2012 train+val
% datasets using both the selective search and edge box proposals and 
% flipped version of the images.
% *************************************************************************
% ************************** VALIDATION SET *******************************
% 'val_set': similar to 'train_set'
% 'voc_year_val': similar to 'voc_year_train'
% 'proposals_method_val': similar to 'proposals_method_train'
% 'val_use_flips': similar to 'train_use_flips'
% 
% Briefly, by default the current script uses as validation set the PASCAL 
% VOC2007 test dataset using both the selective search proposals and NO 
% flipped version of the images.
% *************************************************************************
% OTHER:
% 'solverstate': string with the caffe solverstate filename in order to resume
% training from there. For example by setting the parameter 'solverstate'
% to 'model_iter_30000' the caffe solver will resume to training from the
% 30000-th iteration; the solverstate file is assumed to exist on the
% location: "./models-exps/{model_dir_name}/model_iter_30000.solverstate".
% 'gpu_id': scalar value with gpu id (one-based index) that will be used for 
% running the experiments. If a non positive value is given then the CPU
% will be used instead. Default value: 0
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


%************************** OPTIONS ***************************************
ip = inputParser;

% training set
ip.addParamValue('train_set',              {'trainval','trainval'})
ip.addParamValue('voc_year_train',         {'2007','2012'})
ip.addParamValue('proposals_method_train', {'selective_search','edge_boxes'});
ip.addParamValue('train_use_flips',         true, @islogical);

% validation set
ip.addParamValue('val_set',              {'test'})
ip.addParamValue('voc_year_val',         {'2007'})
ip.addParamValue('proposals_method_val', {'selective_search'});
ip.addParamValue('val_use_flips',         false, @islogical);

% Region parameters 
ip.addParamValue('scale_inner',   0.0,   @isnumeric);
ip.addParamValue('scale_outer',   1.0,   @isnumeric);
ip.addParamValue('half_bbox',      [],   @isnumeric);

ip.addParamValue('solverstate',  '', @ischar)
ip.addParamValue('gpu_id', 0,        @isscalar);
ip.addParamValue('finetuned_modelname', '', @ischar);

ip.parse(varargin{:});
opts = ip.Results;

clc;

% configuration file with the region pooling parameters
opts.vgg_pool_params_def    = fullfile(pwd,'data/vgg_pretrained_models/vgg_region_config.m');
% the network weights file that will be used for initialization
opts.net_file               = fullfile(pwd,'data/vgg_pretrained_models/VGG_ILSVRC_16_Fully_Connected_Layers.caffemodel'); 
% the solver definition file that will be used for training
opts.finetune_net_def_file  = 'VGG16_Region_Adaptation_Module_train_test_solver.prototxt';
opts.finetune_net_def_file  = fullfile(pwd, 'model-defs', opts.finetune_net_def_file);
% location of the model directory where the results of training the region
% adaptation module will be placed
opts.finetune_rst_dir       = fullfile(pwd, 'models-exps', model_dir_name);
mkdir_if_missing(opts.finetune_rst_dir);

% code-name of the VGG16 convolutional feature maps (otherwise called activation maps)
% on top of which the region adaptation moduel will be trained
opts.feat_cache_names       = {'VGG_ILSVRC_16_layers'};     
opts.finetune_cache_name    = opts.feat_cache_names{1};

opts.save_mat_model_only = false;
if ~isempty(opts.finetuned_modelname)
    % if the parameter finetuned_modelname is non-empty then no training is
    % performed and the current script only creates a .mat file that contains
    % the region adaptation module model that uses as weights/parameters
    % those of the file opts.finetuned_modelname
    opts.save_mat_model_only = true;
end

disp(opts)
if ~opts.save_mat_model_only
    % load training set
    image_db_train = load_image_dataset(...
        'image_set', opts.train_set, ...
        'voc_year', opts.voc_year_train, ...
        'proposals_method', opts.proposals_method_train,...
        'feat_cache_names', opts.feat_cache_names, ...
        'use_flips', opts.train_use_flips);
    
    % load validation set
    image_db_val = load_image_dataset(...
        'image_set', opts.val_set, ...
        'voc_year', opts.voc_year_val, ...
        'proposals_method', opts.proposals_method_val,...
        'feat_cache_names', opts.feat_cache_names, ...
        'use_flips', opts.val_use_flips); 
end

% parse the solver file
[solver_file, ~, test_net_file, opts.max_iter, opts.snapshot_prefix] = ...
    parse_copy_finetune_prototxt(...
    opts.finetune_net_def_file, opts.finetune_rst_dir);

opts.finetune_net_def_file = fullfile(opts.finetune_rst_dir, solver_file);
assert(exist(opts.finetune_net_def_file,'file')>0)

voc_path      = [pwd, '/datasets/VOC%s/'];
voc_path_year = sprintf(voc_path, '2007');
VOCopts       = initVOCOpts(voc_path_year,'2007');
classes       = VOCopts.classes; % cell array with the category names of PASCAL

data_param = struct;
data_param.img_num_per_iter = 128; % mini-batch size; it should be the same with the prototxt file
data_param.random_scale     = 1; % project the region to random image scales during training
data_param.iter_per_batch   = 125; % for efficiency load iter_per_batch mini-batches before continue training the network with them
data_param.fg_fraction      = 0.25; % ratio of foreground boxes on each mini-batch
data_param.fg_threshold     = 0.5; % minimum IoU threshold for considering a candidate bounding box to be on the foreground/positve
data_param.bg_threshold     = [0.1 0.5]; % minimum and maximum IoU threshols for considering a candidate bounding box to be on the background
data_param.test_iter        = 4  * data_param.iter_per_batch; % test the network on test_iter minibatches of the validation set
data_param.test_interval    = 16 * data_param.iter_per_batch; % test the network after each test_interval iteration of the training procedure

data_param.feat_dim         = 512 * 7 * 7; % size of features on the output of the region adaptive max pooling layer
data_param.num_classes      = length(classes); % number of categories of pascal dataset
data_param.nTimesMoreData   = 3;

data_param.num_threads      = 6; % size of matlab threads used during training (for creating the mini-batched)
opts.data_param             = data_param;

% create struct pooler contains the pooling parameters and the region type
% of the region adaptation module. 
pooler = load_pooling_params(opts.vgg_pool_params_def, ...
    'scale_inner',   opts.scale_inner, ...
    'scale_outer',   opts.scale_outer, ...
    'half_bbox',     opts.half_bbox, ...
    'feat_id',       1);


if ~isempty(opts.solverstate)
    % set the full solverstate file path
    opts.solver_state_file = fullfile(opts.finetune_rst_dir, [opts.solverstate, '.solverstate']);
    assert(exist(opts.solver_state_file,'file')>0);
end

if opts.save_mat_model_only
    finetuned_model_path = fullfile(opts.finetune_rst_dir, [opts.finetuned_modelname,'.caffemodel']);
else
    % start training the region adaptation module
    caffe.reset_all();
    caffe_set_device( opts.gpu_id );
    finetuned_model_path = train_net_bbox_rec(...
        image_db_train, image_db_val, pooler, opts);
    diary off;
    caffe.reset_all();    
end

assert(exist(finetuned_model_path,'file')>0);
[~,filename,ext]   = fileparts(finetuned_model_path);
finetuned_model_path = ['.',filesep,filename,ext];


feat_blob_name         = {'fc7'};

% prepare / save model that uses the softmax layer for scoring the bounding
% box proposals

deploy_def_file_src  = fullfile(pwd, 'model-defs', 'VGG16_Region_Adaptation_deploy_softmax.prototxt');
deploy_def_file_dst  = fullfile(opts.finetune_rst_dir, 'deploy_softmax.prototxt');
copyfile(deploy_def_file_src,deploy_def_file_dst);

model                  = struct;
model.net_def_file     = './deploy_softmax.prototxt';
model.net_weights_file = {finetuned_model_path};
model.pooler           = pooler;
model.feat_blob_name   = feat_blob_name;
model.feat_cache       = opts.feat_cache_names;
model.classes          = classes;
model.score_out_blob   = 'pascal_softmax';
model_filename         = fullfile(opts.finetune_rst_dir, 'detection_model_softmax.mat');
save(model_filename, 'model');


% prepare / save model that uses class-specific linear svms for scoring the
% bounding box proposals

deploy_def_file_src  = fullfile(pwd, 'model-defs', 'VGG16_Region_Adaptation_deploy_svm.prototxt');
deploy_def_file_dst  = fullfile(opts.finetune_rst_dir, 'deploy_svm.prototxt');
copyfile(deploy_def_file_src,deploy_def_file_dst);

model                  = struct;
model.net_def_file     = './deploy_svm.prototxt';
model.net_weights_file = {finetuned_model_path};
model.pooler           = pooler;
model.feat_blob_name   = feat_blob_name;
model.feat_cache       = opts.feat_cache_names;
model.classes          = classes;
model.score_out_blob   = 'pascal_svm';
model.svm_layer_name   = 'pascal_svm';
model_filename         = fullfile(opts.finetune_rst_dir, 'detection_model_svm.mat');
save(model_filename, 'model');
end