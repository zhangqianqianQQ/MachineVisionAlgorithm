function cnnCacheFeatures(chunk, pid, mode)
% Extracting CNN features

% AUTORIGHTS
% ---------------------------------------------------------
% Copyright (c) 2014, Ross Girshick
%
% This file is part of the R-CNN code and is available
% under the terms of the Simplified BSD License provided in
% LICENSE. Please retain this notice and LICENSE if you use
% this file (or any portion of it) in your project.
% ---------------------------------------------------------

% mode could be either 'cnn' or 'ctx'
if nargin<3
    mode = 'cnn';
end

if nargin<2
    nParallel = 1;
    pid = 1;
else
    nParallel = 6;
end

% -------------------- CONFIG --------------------
switch mode
    case 'cnn'
        net_file     = './data/caffe_nets/VGG_voc_2010_train_i100k' ;
        cache_name   = 'v1_VGG_voc_2010_train_i100k';
    case 'ctx'
        net_file     = './data/caffe_nets/VGG_voc_2010_train_i100k_ctx' ;
        cache_name   = 'v1_VGG_voc_2010_train_i100k_ctx';
    otherwise
        disp('Unspecified mode!');
        keyboard;
end


crop_mode    = 'warp';
crop_padding = 16;

year = '2010';

% change to point to your VOCdevkit install
VOCdevkit = sprintf('./datasets/VOCdevkit%s',year);
% ------------------------------------------------

imdb = imdb_from_voc(VOCdevkit, chunk, year);


start_at = ceil((pid-1)*length(imdb.image_ids)/nParallel)+1;
end_at = ceil(pid*length(imdb.image_ids)/nParallel);
cnnCachePool5Feat(imdb, ...
    'start', start_at, 'end', end_at, ...
    'crop_mode', crop_mode, ...
    'crop_padding', crop_padding, ...
    'net_file', net_file, ...
    'mode', mode, ...
    'cache_name', cache_name);

if ~strcmp(chunk,'test')
    imdb_trainval = imdb_from_voc(VOCdevkit, 'trainval', year);
    link_up_trainval(cache_name, imdb, imdb_trainval);
end

% ------------------------------------------------------------------------
function link_up_trainval(cache_name, imdb_split, imdb_trainval)
% ------------------------------------------------------------------------
cmd = {['mkdir -p ./feat_cache/' cache_name '/' imdb_trainval.name '; '], ...
    ['cd ./feat_cache/' cache_name '/' imdb_trainval.name '/; '], ...
    ['for i in `ls -1 ../' imdb_split.name '`; '], ...
    ['do ln -s ../' imdb_split.name '/$i $i; '], ...
    ['done;']};
cmd = [cmd{:}];
fprintf('running:\n%s\n', cmd);
system(cmd);
fprintf('done\n');

% ------------------------------------------------------------------------
function cnnCachePool5Feat(imdb, varargin)
% ------------------------------------------------------------------------

ip = inputParser;
ip.addRequired('imdb', @isstruct);
ip.addOptional('start', 1, @isscalar);
ip.addOptional('end', 0, @isscalar);
ip.addOptional('crop_mode', 'warp', @isstr);
ip.addOptional('mode', 'cnn', @isstr);
ip.addOptional('crop_padding', 16, @isscalar);
ip.addOptional('net_file', ...
    './data/caffe_nets/finetune_voc_2007_trainval_iter_70k', ...
    @isstr);
ip.addOptional('cache_name', ...
    'v1_finetune_voc_2007_trainval_iter_70000', @isstr);

ip.parse(imdb, varargin{:});
opts = ip.Results;
image_ids = imdb.image_ids;

opts.net_def_file = './model-defs/VGG_ILSVRC_16_layers_batch32_output_pool5.prototxt';

opts.output_dir = ['./feat_cache/' opts.cache_name '/' imdb.name '/'];
mkdir_if_missing(opts.output_dir);

timestamp = datestr(datevec(now()), 'dd.mmm.yyyy:HH.MM.SS');
diary_file = [opts.output_dir 'rcnn_cache_pool5_features_' timestamp '.txt'];
diary(diary_file);
fprintf('Logging output in %s\n', diary_file);

fprintf('\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n');
fprintf('Feature caching options:\n');
disp(opts);
fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n');

roidb = roidb_from_voc(imdb);

rcnn_model = rcnn_create_model(opts.net_def_file, opts.net_file);
rcnn_model = rcnn_load_model(rcnn_model);

rcnn_model.detectors.crop_mode = opts.crop_mode;
rcnn_model.detectors.crop_padding = opts.crop_padding;

total_time = 0;
count = 0;

for i = opts.start:opts.end
    fprintf('%s: cache features: %d/%d\n', procid(), i, opts.end);
    
    save_file = [opts.output_dir image_ids{i} '.mat'];
    if exist(save_file, 'file') ~= 0
        fprintf(' [already exists]\n');
        try
            var = load(save_file);
            continue;
        catch
            fprintf(' [file corrupted...]\n');
        end
    end
    count = count + 1;
    
    tot_th = tic;
    
    d = roidb.rois(i);
    im = imread(imdb.image_at(i));
    
    switch opts.mode
        case 'cnn'
            box = d.boxes;
        case 'ctx'
            box = d.ctx;
        otherwise
            disp('Unspecified mode!');
            keyboard;
    end
    
    th = tic;
    d.feat = rcnn_features(im, box, rcnn_model);
    fprintf(' [features: %.3fs]\n', toc(th));
    
    th = tic;
    save(save_file, '-struct', 'd');
    fprintf(' [saving:   %.3fs]\n', toc(th));
    
    total_time = total_time + toc(tot_th);
    fprintf(' [avg time: %.3fs (total: %.3fs)]\n', ...
        total_time/count, total_time);
end
