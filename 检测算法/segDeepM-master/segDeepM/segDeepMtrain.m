function [rcnn_model] = segDeepMtrain(imdb, config, varargin)
% [rcnn_model, rcnn_k_fold_model] = rcnn_train(imdb, varargin)
%   Trains an R-CNN detector for all classes in the imdb.
%
%   Keys that can be passed in:
%
%   svm_C             SVM regularization parameter
%   bias_mult         Bias feature value (for liblinear)
%   pos_loss_weight   Cost factor on hinge loss for positives
%   layer             Feature layer to use (either 5, 6 or 7)
%   k_folds           Train on folds of the imdb
%   checkpoint        Save the rcnn_model every checkpoint images
%   crop_mode         Crop mode (either 'warp' or 'square')
%   crop_padding      Amount of padding in crop
%   net_file          Path to the Caffe CNN to use
%   cache_name        Path to the precomputed feature cache

% AUTORIGHTS
% ---------------------------------------------------------
% Copyright (c) 2014, Ross Girshick
%
% This file is part of the R-CNN code and is available
% under the terms of the Simplified BSD License provided in
% LICENSE. Please retain this notice and LICENSE if you use
% this file (or any portion of it) in your project.
% ---------------------------------------------------------

ip = inputParser;
ip.addRequired('imdb', @isstruct);
ip.addRequired('config', @isstruct);
ip.addParamValue('svm_C',           10^-3,  @isscalar);
ip.addParamValue('bias_mult',       10,     @isscalar);
ip.addParamValue('pos_loss_weight', 2,      @isscalar);
ip.addParamValue('layer',           15,      @isscalar);
ip.addParamValue('k_folds',         2,      @isscalar);
ip.addParamValue('checkpoint',      0,      @isscalar);
ip.addParamValue('crop_mode',       'warp', @isstr);
ip.addParamValue('crop_padding',    16,     @isscalar);
ip.addParamValue('net_file', ...
    './data/caffe_nets/finetune_voc_2007_trainval_iter_70k', ...
    @isstr);
ip.addParamValue('cache_name', ...
    'v1_finetune_voc_2007_trainval_iter_70000', @isstr);
ip.addParamValue('id', 'comp4', @isstr);

ip.parse(imdb, config, varargin{:});
opts = ip.Results;

opts.net_def_file = './model-defs/VGG_ILSVRC_16_layers_batch32_output_fc7.prototxt';
conf = rcnn_config('sub_dir', imdb.name);

% Record a log of the training and test procedure
timestamp = datestr(datevec(now()), 'dd.mmm.yyyy:HH.MM.SS');
diary_file = [conf.cache_dir 'rcnn_train_' timestamp '.txt'];
diary(diary_file);
fprintf('Logging output in %s\n', diary_file);

fprintf('\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n');
fprintf('Training options:\n');
disp(opts);
fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n');

% ------------------------------------------------------------------------
% Create a new rcnn model
try
    load(config.cnn_load,'rcnn_model');
catch
    rcnn_model = rcnn_create_model(opts.net_def_file, opts.net_file, opts.cache_name);
    rcnn_model = rcnn_load_model(rcnn_model, 1);
    save(config.cnn_load,'rcnn_model');
end

if config.ctx.use
    try
        load(config.ctx.cnn_load,'rcnn_model_ctx');
    catch
        rcnn_model_ctx = rcnn_create_model(opts.net_def_file, config.ctx.net_file, config.ctx.cache_name);
        rcnn_model_ctx = rcnn_load_model(rcnn_model_ctx, 1);
        save(config.ctx.cnn_load,'rcnn_model_ctx');
    end
end

rcnn_model.detectors.crop_mode = opts.crop_mode;
rcnn_model.detectors.crop_padding = opts.crop_padding;
rcnn_model.classes = imdb.classes;
% ------------------------------------------------------------------------

% ------------------------------------------------------------------------
% Get the average norm of the features
opts.feat_norm_mean = rcnn_feature_stats(imdb, opts.layer, rcnn_model);
fprintf('average norm = %.3f\n', opts.feat_norm_mean);

if config.ctx.use
    opts.feat_norm_mean_ctx = rcnn_feature_stats(imdb, opts.layer, rcnn_model_ctx );
    fprintf('average norm = %.3f\n', opts.feat_norm_mean_ctx);
    rcnn_model.ctx = rcnn_model_ctx;
end

rcnn_model.training_opts = opts;

% ------------------------------------------------------------------------

% ------------------------------------------------------------------------
% Get all positive examples
% We cache only the pool5 features and convert them on-the-fly to
% fc6 or fc7 as required
if config.seg.use
    mkdir_if_missing(config.seg.segSaveDir);
end

try
    load(config.pos_save_file);
    fprintf('Loaded saved positives from ground truth boxes\n');
catch
    [X_pos, keys_pos, roidb] = get_positive_pool5_features(imdb, opts);
    [X_pos_e, keys_pos_e] = get_positive_pool5_features_ctx(imdb,config);
    
    save(config.pos_save_file, 'X_pos', 'keys_pos','X_pos_e', 'keys_pos_e', 'roidb', '-v7.3');
end

% Init training caches
caches = {};
for i = imdb.class_ids
    fprintf('%14s has %6d positive instances\n', ...
        imdb.classes{i}, size(X_pos{i},1));
    X_pos{i} = rcnn_pool5_to_fcX(X_pos{i}, opts.layer, rcnn_model);
    X_pos{i} = rcnn_scale_features(X_pos{i}, opts.feat_norm_mean);
    
    if config.ctx.use
        X_pos_e{i} = rcnn_pool5_to_fcX(X_pos_e{i}, opts.layer, rcnn_model_ctx);
        X_pos_e{i} = rcnn_scale_features(X_pos_e{i}, opts.feat_norm_mean_ctx);
        X_pos{i} = cat(2,X_pos{i}, X_pos_e{i});
    end
    
    if config.seg.use
        % Add segmentation features
        fprintf('Extracting segmentation feature for positives...\n');
        ids = keys_pos{i}(:,1);
        fs = [];
        for k=unique(ids)'
            sel = keys_pos{i}(ids==k,2);
            detwin = roidb.rois(k).boxes;
            
            pFeats = segCachePyramidFeat(imdb.image_ids{k},detwin,config);
            [~,feat]=segGetScore([],i,pFeats,detwin,config);
            
            if isempty(fs)
                fs = zeros(size(X_pos{i},1),size(feat,2));
            end
            fs(ids==k,:)= feat(sel,:);
        end
        X_pos{i}=cat(2,X_pos{i},fs);
    end
    caches{i} = init_cache(X_pos{i}, keys_pos{i});
end
% ------------------------------------------------------------------------

% ------------------------------------------------------------------------
% Train with hard negative mining
first_time = true;
% one pass over the data is enough
max_hard_epochs = 1;

for hard_epoch = 1:max_hard_epochs
    for i = 1:length(imdb.image_ids)
        fprintf('%s: hard neg epoch: %d/%d image: %d/%d\n', ...
            procid(), hard_epoch, max_hard_epochs, i, length(imdb.image_ids));
        
        % Get hard negatives for all classes at once (avoids loading feature cache
        % more than once)
        [X, keys] = sample_negative_features(first_time, rcnn_model, caches, ...
            imdb, roidb, i);
        
        % Add sampled negatives to each classes training cache, removing
        % duplicates
        for j = imdb.class_ids
            if ~isempty(keys{j})
                if ~isempty(caches{j}.keys_neg)
                    [~, ~, dups] = intersect(caches{j}.keys_neg, keys{j}, 'rows');
                    assert(isempty(dups));
                end
                caches{j}.X_neg = cat(1, caches{j}.X_neg, X{j});
                caches{j}.keys_neg = cat(1, caches{j}.keys_neg, keys{j});
                caches{j}.num_added = caches{j}.num_added + size(keys{j},1);
            end
            
            % Update model if
            %  - first time seeing negatives
            %  - more than retrain_limit negatives have been added
            %  - its the final image of the final epoch
            is_last_time = (hard_epoch == max_hard_epochs && i == length(imdb.image_ids));
            hit_retrain_limit = (caches{j}.num_added > caches{j}.retrain_limit);
            if (first_time || hit_retrain_limit || is_last_time) && ...
                    ~isempty(caches{j}.X_neg)
                fprintf('>>> Updating %s detector <<<\n', imdb.classes{j});
                fprintf('Cache holds %d pos examples %d neg examples\n', ...
                    size(caches{j}.X_pos,1), size(caches{j}.X_neg,1));
                [new_w, new_b] = update_model(caches{j}, opts);
                rcnn_model.detectors.W(:, j) = new_w;
                rcnn_model.detectors.B(j) = new_b;
                caches{j}.num_added = 0;
                
                z_pos = caches{j}.X_pos * new_w + new_b;
                z_neg = caches{j}.X_neg * new_w + new_b;
                
                caches{j}.pos_loss(end+1) = opts.svm_C * opts.pos_loss_weight * ...
                    sum(max(0, 1 - z_pos));
                caches{j}.neg_loss(end+1) = opts.svm_C * sum(max(0, 1 + z_neg));
                caches{j}.reg_loss(end+1) = 0.5 * new_w' * new_w + ...
                    0.5 * (new_b / opts.bias_mult)^2;
                caches{j}.tot_loss(end+1) = caches{j}.pos_loss(end) + ...
                    caches{j}.neg_loss(end) + ...
                    caches{j}.reg_loss(end);
                
                for t = 1:length(caches{j}.tot_loss)
                    fprintf('    %2d: obj val: %.3f = %.3f (pos) + %.3f (neg) + %.3f (reg)\n', ...
                        t, caches{j}.tot_loss(t), caches{j}.pos_loss(t), ...
                        caches{j}.neg_loss(t), caches{j}.reg_loss(t));
                end
                
                % store negative support vectors for visualizing later
                SVs_neg = find(z_neg > -1 - eps);
                rcnn_model.SVs.keys_neg{j} = caches{j}.keys_neg(SVs_neg, :);
                rcnn_model.SVs.scores_neg{j} = z_neg(SVs_neg);
                
                % evict easy examples
                easy = find(z_neg < caches{j}.evict_thresh);
                caches{j}.X_neg(easy,:) = [];
                caches{j}.keys_neg(easy,:) = [];
                fprintf('  Pruning easy negatives\n');
                fprintf('  Cache holds %d pos examples %d neg examples\n', ...
                    size(caches{j}.X_pos,1), size(caches{j}.X_neg,1));
                fprintf('  %d pos support vectors\n', numel(find(z_pos <  1 + eps)));
                fprintf('  %d neg support vectors\n', numel(find(z_neg > -1 - eps)));
                
                % We found a E-M based optimization does almost as well as
                % latentSVM, and is much faster
                
                % E-step, do this only for positive instances
                % Jump the first a few iterations to further speed up
                % training
                if config.seg.use  && i>0.2*length(imdb.image_ids)
                    fprintf('  E-step: update positives for class %s...\n', imdb.classes{j});
                    ids = caches{j}.keys_pos(:,1);
                    for k=unique(ids)'
                        sel = caches{j}.keys_pos(ids==k,2);
                        detwin = roidb.rois(k).boxes;
                        
                        feats = segCachePyramidFeat(imdb.image_ids{k},detwin,config);
                        sp = config.seg.segFeatPivot+1;
                        
                        [~,feat]=segGetScore(rcnn_model.detectors.W(sp:end,j),j,feats,detwin,config);
                        caches{j}.X_pos(ids==k,sp:end)=feat(sel,:);
                    end
                end                
            end
        end
        first_time = false;
        
        if opts.checkpoint > 0 && mod(i, opts.checkpoint) == 0
            save([conf.cache_dir 'rcnn_model'], 'rcnn_model');
        end
    end
end
% Save rcnn_model
save([conf.cache_dir 'rcnn_model'], 'rcnn_model');

% Remove cache file
if config.seg.use
    system(['rm -rf ' config.seg.segSaveDir]);
end
% ------------------------------------------------------------------------


% ------------------------------------------------------------------------
function [X_neg, keys] = sample_negative_features(first_time, rcnn_model, ...
    caches, imdb, roidb, ind)
% ------------------------------------------------------------------------
opts = rcnn_model.training_opts;
config = opts.config;

d = rcnn_load_cached_pool5_features(opts.cache_name, ...
    imdb.name, imdb.image_ids{ind});

if config.ctx.use
    dc = rcnn_load_cached_pool5_features(config.ctx.cache_name, ...
        imdb.name, imdb.image_ids{ind});
end

class_ids = imdb.class_ids;

if isempty(d.feat)
    X_neg = cell(max(class_ids), 1);
    keys = cell(max(class_ids), 1);
    return;
end

d.feat = rcnn_pool5_to_fcX(d.feat, opts.layer, rcnn_model);
d.feat = rcnn_scale_features(d.feat, opts.feat_norm_mean);

if config.ctx.use
    dc.feat = rcnn_pool5_to_fcX(dc.feat, opts.layer, rcnn_model.ctx);
    dc.feat = rcnn_scale_features(dc.feat, opts.feat_norm_mean_ctx);
    d.feat = cat(2,d.feat,dc.feat);
end

detwin = roidb.rois(ind).boxes;
neg_ovr_thresh = 0.3;

if config.seg.use
    pFeat = segCachePyramidFeat(imdb.image_ids{ind},detwin, config);
end

if first_time
    for cls_id = class_ids
        I = find(d.overlap(:, cls_id) < neg_ovr_thresh);
        X_neg{cls_id} = d.feat(I,:);
        
        if config.seg.use
            [~,feat]=segGetScore([],cls_id,pFeat,detwin,config);
            X_neg{cls_id} = cat(2,X_neg{cls_id},feat(I,:));
        end
        
        keys{cls_id} = [ind*ones(length(I),1) I];
    end
else
    W = rcnn_model.detectors.W(1:config.seg.segFeatPivot,:);
    zs = bsxfun(@plus, d.feat*W, rcnn_model.detectors.B);
    
    for cls_id = class_ids
        z = zs(:, cls_id);
        
        if config.seg.use
            sp = config.seg.segFeatPivot+1;
            [sz,feat]=segGetScore(rcnn_model.detectors.W(sp:end,cls_id),cls_id,pFeat,detwin,config);
            z = z + sz;
        end
        
        I = find((z > caches{cls_id}.hard_thresh) & ...
            (d.overlap(:, cls_id) < neg_ovr_thresh));
        
        % Avoid adding duplicate features
        keys_ = [ind*ones(length(I),1) I];
        if ~isempty(caches{cls_id}.keys_neg) && ~isempty(keys_)
            [~, ~, dups] = intersect(caches{cls_id}.keys_neg, keys_, 'rows');
            keep = setdiff(1:size(keys_,1), dups);
            I = I(keep);
        end
        
        % Unique hard negatives
        if config.seg.use
            X_neg{cls_id} = cat( 2, d.feat(I,:), feat(I,:) );
        else
            X_neg{cls_id} = d.feat(I,:);
        end
        
        keys{cls_id} = [ind*ones(length(I),1) I];
    end
end


% ------------------------------------------------------------------------
function [w, b] = update_model(cache, opts, pos_inds, neg_inds)
% ------------------------------------------------------------------------
solver = 'liblinear';
liblinear_type = 3;  % l2 regularized l1 hinge loss
%liblinear_type = 5; % l1 regularized l2 hinge loss

if ~exist('pos_inds', 'var') || isempty(pos_inds)
    num_pos = size(cache.X_pos, 1);
    pos_inds = 1:num_pos;
else
    num_pos = length(pos_inds);
    fprintf('[subset mode] using %d out of %d total positives\n', ...
        num_pos, size(cache.X_pos,1));
end
if ~exist('neg_inds', 'var') || isempty(neg_inds)
    num_neg = size(cache.X_neg, 1);
    neg_inds = 1:num_neg;
else
    num_neg = length(neg_inds);
    fprintf('[subset mode] using %d out of %d total negatives\n', ...
        num_neg, size(cache.X_neg,1));
end

switch solver
    case 'liblinear'
        ll_opts = sprintf('-w1 %.5f -c %.5f -s %d -B %.5f', ...
            opts.pos_loss_weight, opts.svm_C, ...
            liblinear_type, opts.bias_mult);
        fprintf('liblinear opts: %s\n', ll_opts);
        X = sparse(size(cache.X_pos,2), num_pos+num_neg);
        X(:,1:num_pos) = cache.X_pos(pos_inds,:)';
        X(:,num_pos+1:end) = cache.X_neg(neg_inds,:)';
        y = cat(1, ones(num_pos,1), -ones(num_neg,1));
        llm = liblinear_train(y, X, ll_opts, 'col');
        w = single(llm.w(1:end-1)');
        b = single(llm.w(end)*opts.bias_mult);
        
    otherwise
        error('unknown solver: %s', solver);
end

% ------------------------------------------------------------------------
function [X_pos, keys, roidb] = get_positive_pool5_features(imdb, opts)
% ------------------------------------------------------------------------
X_pos = cell(max(imdb.class_ids), 1);
keys = cell(max(imdb.class_ids), 1);

roidb.rois = struct();
roidb.rois(numel(imdb.image_ids)).boxes = [];

for i = 1:length(imdb.image_ids)
    tic_toc_print('%s: pos features %d/%d\n', ...
        procid(), i, length(imdb.image_ids));
    
    d = rcnn_load_cached_pool5_features(opts.cache_name, ...
        imdb.name, imdb.image_ids{i});
    
    roidb.rois(i).boxes = d.boxes;
    
    for j = imdb.class_ids
        if isempty(X_pos{j})
            X_pos{j} = single([]);
            keys{j} = [];
        end
        sel = find(d.class == j);
        if ~isempty(sel)
            X_pos{j} = cat(1, X_pos{j}, d.feat(sel,:));
            keys{j} = cat(1, keys{j}, [i*ones(length(sel),1) sel]);
        end
    end
end


% ------------------------------------------------------------------------
function [X_pos, keys] = get_positive_pool5_features_ctx(imdb, config)
% ------------------------------------------------------------------------
X_pos = cell(max(imdb.class_ids), 1);
keys = cell(max(imdb.class_ids), 1);

if ~config.ctx.use
    return
end

for i = 1:length(imdb.image_ids)
    tic_toc_print('%s: pos features (context) %d/%d\n', ...
        procid(), i, length(imdb.image_ids));
    d = rcnn_load_cached_pool5_features(config.ctx.cache_name, ...
        imdb.name, imdb.image_ids{i});
    
    for j = imdb.class_ids
        if isempty(X_pos{j})
            X_pos{j} = single([]);
            keys{j} = [];
        end
        
        sel = find(d.class == j);
        if ~isempty(sel)
            X_pos{j} = cat(1, X_pos{j}, d.feat(sel,:));
            keys{j} = cat(1, keys{j}, [i*ones(length(sel),1) sel]);
        end
    end
    
end


% ------------------------------------------------------------------------
function cache = init_cache(X_pos, keys_pos)
% ------------------------------------------------------------------------
cache.X_pos = X_pos;
cache.X_neg = single([]);
cache.keys_neg = [];
cache.keys_pos = keys_pos;
cache.num_added = 0;
cache.retrain_limit = 2000;
cache.evict_thresh = -1.2;
cache.hard_thresh = -1.0001;
cache.pos_loss = [];
cache.neg_loss = [];
cache.reg_loss = [];
cache.tot_loss = [];


