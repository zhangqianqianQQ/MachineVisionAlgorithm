function script_train_linear_svms_of_model(model_dir_name, varargin)
%************************** OPTIONS *************************************
ip = inputParser;
ip.addParamValue('gpu_id', 0, @isscalar);

ip.addParamValue('voc_year_train',         {'2007','2012'}, @iscell);
ip.addParamValue('image_set_train',        {'trainval', 'trainval'}, @iscell);
ip.addParamValue('proposals_method_train', {'selective_search', 'edge_boxes'}, @iscell);

ip.addParamValue('model_mat_name',    'detection_model_svm.mat', @ischar);
ip.addParamValue('svm_layer_name',    'pascal_svm', @ischar);
ip.addParamValue('svm_C',              10^-3,  @isnumeric);

ip.parse(varargin{:});
opts = ip.Results;

gpu_id                 = opts.gpu_id;

full_model_dir         = fullfile('./', 'models-exps', model_dir_name);
full_model_path        = fullfile(full_model_dir, opts.model_mat_name);
assert(exist(full_model_dir,'dir')>0);
assert(exist(full_model_path, 'file')>0);

model_obj_rec = load_model(full_model_path); % object recognition model

feat_cache_names       = model_obj_rec.feat_cache;
voc_year_train         = opts.voc_year_train;
image_set_train        = opts.image_set_train;
proposals_method_train = opts.proposals_method_train; 

svm_C                  = opts.svm_C;
%**************************************************************************

%*************************** LOAD DATASET *********************************
image_db_train = load_image_dataset(...
    'image_set', image_set_train, ...
    'voc_year', voc_year_train, ...
    'proposals_method', proposals_method_train, ...
    'feat_cache_names', feat_cache_names);

image_paths_train      = image_db_train.image_paths;
feature_paths_train    = image_db_train.feature_paths;
all_regions_train      = image_db_train.all_regions;
all_bbox_gt_train      = image_db_train.all_bbox_gt;
proposals_suffix_train = image_db_train.proposals_suffix;
image_set_name_train   = image_db_train.image_set_name;

experiment_name        = sprintf('exp_train_svm_%s', proposals_suffix_train);

cache_directory    = fullfile('./', 'cache_dir');
experiment_dir     = fullfile(cache_directory, [image_set_name_train, sprintf('/%s/',experiment_name)]);
model_obj_rec.cache_dir  = experiment_dir;
%**************************************************************************

%***************************** LOAD MODEL *********************************
caffe_set_device( gpu_id );
caffe.reset_all();
curr_dir = pwd;
cd(full_model_dir)
model_obj_rec.net = caffe_load_model( model_obj_rec.net_def_file,  model_obj_rec.net_weights_file);
%**************************************************************************
%*****************************  TRAIN SVMS ********************************
mkdir_if_missing(cache_directory);
mkdir_if_missing(experiment_dir);

svm_weights_file = train_detection_svm_with_hard_mining( ...
   model_obj_rec, image_paths_train, feature_paths_train, all_bbox_gt_train, ...
   all_regions_train, 'exp_dir', experiment_dir, 'train_classes', ...
   model_obj_rec.classes, 'svm_C', svm_C);
caffe.reset_all();
cd(curr_dir);
model_obj_rec = rmfield(model_obj_rec,'net');
update_model_with_svm_weights(full_model_path, model_obj_rec, svm_weights_file, opts.svm_layer_name, svm_C);
%**************************************************************************
end

function model = load_model(filename)
ld = load(filename, 'model');
model = ld.model; 
end

function update_model_with_svm_weights(filename, model, svm_weights_file, svm_layer_name, svm_C)
model.svm_weights_file = svm_weights_file;

if ~isfield(model,'svm_layer_name'), model.svm_layer_name = svm_layer_name; end

model.svm_train_opts   = struct;
model.svm_train_opts.svm_C = svm_C;
model.svm_cache_dir    = fileparts(svm_weights_file);
save(filename, 'model');
end
