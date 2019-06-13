function script_extract_sem_seg_aware_features(image_set, voc_year, varargin)
% image_set: string with imaget set name, e.g. 'test','trainval',...
% voc_year: string with the year of the imaget set, e.g. '2007','2012',...
% 
% This file is part of the code that implements the following ICCV2015 accepted paper:
% title: "Object detection via a multi-region & semantic segmentation-aware CNN model"
% authors: Spyros Gidaris, Nikos Komodakis
% institutation: Universite Paris Est, Ecole des Ponts ParisTech
% Technical report: http://arxiv.org/abs/1505.01749
% code: https://github.com/gidariss/mrcnn-object-detection
% 
% AUTORIGHTS
% --------------------------------------------------------
% Copyright (c) 2015 Spyros Gidaris
% 
% "Object detection via a multi-region & semantic segmentation-aware CNN model"
% Technical report: http://arxiv.org/abs/1505.01749
% Licensed under The MIT License [see LICENSE for details]
% ---------------------------------------------------------

ip = inputParser;
ip.addOptional('start',      1,   @isscalar); 
ip.addOptional('end',        0,   @isscalar);
ip.addOptional('scales',   [576 874 1200], @ismatrix);
ip.addOptional('gpu_id',     0,  @isnumeric); 
ip.addOptional('feat_cache_name','Semantic_Segmentation_Aware_Feats', @ischar);
ip.addOptional('feat_cache_name_input','VGG_ILSVRC_16_layers', @ischar);
ip.addOptional('use_flips', false, @islogical);

ip.parse(varargin{:});
opts = ip.Results;

net_files_dir    = fullfile(pwd,'data',   'vgg_pretrained_models');
net_def_file     = fullfile(net_files_dir,'Semantic_Segmentation_Features_CNN.prototxt');
net_weights_file = fullfile(net_files_dir,'Semantic_Segmentation_Features_CNN.caffemodel');
assert(exist(net_files_dir,     'dir')>0);
assert(exist(net_def_file,     'file')>0);
assert(exist(net_weights_file, 'file')>0);

image_db  = load_image_dataset('image_set',image_set,...
    'voc_year',voc_year,'use_flips',opts.use_flips, ...
    'feat_cache_names',opts.feat_cache_name_input);

feat_cache_dir_parent    = fullfile(pwd, 'feat_cache');
feat_cache_dir_child     = fullfile(feat_cache_dir_parent, opts.feat_cache_name);
feat_cache_dir_image_set = fullfile(feat_cache_dir_child, image_db.image_set_name);

mkdir_if_missing(feat_cache_dir_parent);
mkdir_if_missing(feat_cache_dir_child);
mkdir_if_missing(feat_cache_dir_image_set);

caffe_set_device( opts.gpu_id );
caffe.reset_all();
net = caffe_load_model( net_def_file, {net_weights_file});

extract_semantic_features_all_images(net, image_db.feature_paths, ...
    feat_cache_dir_image_set,'start',opts.start,'end',opts.end,...
    'scales',opts.scales,'do_interleave', true, 'interleave_num_steps', 2);

caffe.reset_all();

end

