function save_model_path = fast_rcnn_train(conf, imdb_train, roidb_train, varargin)
% save_model_path = fast_rcnn_train(conf, imdb_train, roidb_train, varargin)
% --------------------------------------------------------
% Fast R-CNN
% Reimplementation based on Python Fast R-CNN (https://github.com/rbgirshick/fast-rcnn)
% Copyright (c) 2015, Shaoqing Ren
% Licensed under The MIT License [see LICENSE for details]
% --------------------------------------------------------

%% inputs
    ip = inputParser;
    ip.addRequired('conf',                              @isstruct);
    ip.addRequired('imdb_train',                        @iscell);
    ip.addRequired('roidb_train',                       @iscell);
    ip.addParamValue('do_val',          false,          @isscalar);
    ip.addParamValue('imdb_val',        struct(),       @isstruct);
    ip.addParamValue('roidb_val',       struct(),       @isstruct);
    ip.addParamValue('val_iters',       360,            @isscalar); 
    ip.addParamValue('val_interval',    2000,           @isscalar); 
    ip.addParamValue('snapshot_interval',...
                                        10000,          @isscalar);
    ip.addParamValue('solver_def_file', fullfile(pwd, 'models', 'Zeiler_conv5', 'solver.prototxt'), ...
                                                        @isstr);
    ip.addParamValue('net_file',        fullfile(pwd, 'models', 'Zeiler_conv5', 'Zeiler_conv5'), ...
                                                        @isstr);
    ip.addParamValue('cache_name',      'Zeiler_conv5', @isstr);
    ip.addParamValue('stage',            1,             @isscalar);
    ip.parse(conf, imdb_train, roidb_train, varargin{:});
    opts = ip.Results;
    
%% try to find trained model
    imdbs_name = cell2mat(cellfun(@(x) x.name, imdb_train, 'UniformOutput', false));
    cache_dir = fullfile(pwd, 'output', 'fast_rcnn_cachedir', opts.cache_name, imdbs_name);
    save_model_path = fullfile(cache_dir, 'final');
    if exist(save_model_path, 'file')
        return;
    end
    
%% init
    % init caffe solver
    mkdir_if_missing(cache_dir);
    caffe_log_file_base = fullfile(cache_dir, 'caffe_log');
    caffe.init_log(caffe_log_file_base);
    caffe_solver = caffe.Solver(opts.solver_def_file);
%     if opts.stage == 1
%         opts.net_file = 'output/fast_rcnn_cachedir/Caltech_VGG16_stage1/voc_caltech_trainval3/final';
%         warning('pretrained file from: %s.', opts.net_file);
%     end
    caffe_solver.net.copy_from(opts.net_file);
    
    % init log
    timestamp = datestr(datevec(now()), 'yyyymmdd_HHMMSS');
    mkdir_if_missing(fullfile(cache_dir, 'log'));
    log_file = fullfile(cache_dir, 'log', ['train_', timestamp, '.txt']);
    diary(log_file);
    
    % set random seed
    prev_rng = seed_rand(conf.rng_seed);
    caffe.set_random_seed(conf.rng_seed);
    
    % set gpu/cpu
    if conf.use_gpu
        caffe.set_mode_gpu();
    else
        caffe.set_mode_cpu();
    end
    
    disp('conf:');
    disp(conf);
    disp('opts:');
    disp(opts);
    
%% making tran/val data
    fprintf('Preparing training data...');
    [image_roidb_train, bbox_means, bbox_stds]...
                            = fast_rcnn_prepare_image_roidb(conf, opts.imdb_train, opts.roidb_train);
    fprintf('Done.\n');
    
    if opts.do_val
        fprintf('Preparing validation data...');
        [image_roidb_val]...
                                = fast_rcnn_prepare_image_roidb(conf, opts.imdb_val, opts.roidb_val, bbox_means, bbox_stds);
        fprintf('Done.\n');

        % fix validation data
        shuffled_inds_val = generate_random_minibatch([], image_roidb_val, conf.ims_per_batch);
        shuffled_inds_val = shuffled_inds_val(randperm(length(shuffled_inds_val), opts.val_iters));
    end
    
%%  try to train/val with images which have maximum size potentially, to validate whether the gpu memory is enough  
    num_classes = size(image_roidb_train(1).overlap, 2);
%    check_gpu_memory(conf, caffe_solver, num_classes, opts.do_val);
    
%% training
    shuffled_inds = [];
    train_results = [];  
    val_results = [];  
    iter_ = caffe_solver.iter();
    max_iter = caffe_solver.max_iter();
    %load hard sample
    hard_path = 'output/fast_rcnn_cachedir/Caltech_VGG16_ori-bg-lo.0-bs80-s800/voc_caltech_trainval3/pedestrian_boxes_hard.mat';
    if exist(hard_path, 'file')
        ld = load(hard_path);
        hard_sample = ld.hard_sample;
        clear ld;
    end
    while (iter_ < max_iter)
        caffe_solver.net.set_phase('train');

        % generate minibatch training data
        [shuffled_inds, sub_db_inds] = generate_random_minibatch(shuffled_inds, image_roidb_train, conf.ims_per_batch);
        % added hard_sample process
        %select_hard = hard_sample(sub_db_inds);
        select_hard = cell(1,length(sub_db_inds));
        use_lstm = (opts.stage==3);
        net_inputs = fast_rcnn_get_minibatch(conf, image_roidb_train(sub_db_inds), select_hard, use_lstm);
        caffe_solver.net.reshape_as_input(net_inputs);

        % one iter SGD update
        caffe_solver.net.set_input_data(net_inputs);
        caffe_solver.step(1);
        
        rst = caffe_solver.net.get_output();
        train_results = parse_rst(train_results, rst);
%         check_loss(rst, caffe_solver, net_inputs);   
        
        % do valdiation per val_interval iterations
        if ~mod(iter_, opts.val_interval) 
            if opts.do_val
                caffe_solver.net.set_phase('test');                
                for i = 1:length(shuffled_inds_val)
                    sub_db_inds = shuffled_inds_val{i};              
                    % Reshape net's input blobs
                    select_hard = cell(1,length(sub_db_inds));
                    net_inputs = fast_rcnn_get_minibatch(conf, image_roidb_val(sub_db_inds),select_hard);
                    caffe_solver.net.reshape_as_input(net_inputs);
                    
                    caffe_solver.net.forward(net_inputs);
                    
                    rst = caffe_solver.net.get_output();
                    val_results = parse_rst(val_results, rst);
                end
            end
            
            show_state(iter_, train_results, val_results);
            train_results = [];
            val_results = [];
            diary; diary; % flush diary
        end
        
        % snapshot
        if ~mod(iter_, opts.snapshot_interval)
            snapshot(caffe_solver, bbox_means, bbox_stds, cache_dir, sprintf('iter_%d', iter_),opts.stage);
        end
        
        iter_ = caffe_solver.iter();
    end
    
    % final snapshot
    snapshot(caffe_solver, bbox_means, bbox_stds, cache_dir, sprintf('iter_%d', iter_),opts.stage);
    save_model_path = snapshot(caffe_solver, bbox_means, bbox_stds, cache_dir, 'final',opts.stage);

    diary off;
    caffe.reset_all(); 
    rng(prev_rng);
end

function [shuffled_inds, sub_inds] = generate_random_minibatch(shuffled_inds, image_roidb_train, ims_per_batch)

    % shuffle training data per batch
    if isempty(shuffled_inds)
        % make sure each minibatch, only has horizontal images or vertical
        % images, to save gpu memory
        
        hori_image_inds = arrayfun(@(x) x.im_size(2) >= x.im_size(1), image_roidb_train, 'UniformOutput', true);
        vert_image_inds = ~hori_image_inds;
        hori_image_inds = find(hori_image_inds);
        vert_image_inds = find(vert_image_inds);
        
        % random perm
        lim = floor(length(hori_image_inds) / ims_per_batch) * ims_per_batch;
        hori_image_inds = hori_image_inds(randperm(length(hori_image_inds), lim));
        lim = floor(length(vert_image_inds) / ims_per_batch) * ims_per_batch;
        vert_image_inds = vert_image_inds(randperm(length(vert_image_inds), lim));
        
        % combine sample for each ims_per_batch 
        hori_image_inds = reshape(hori_image_inds, ims_per_batch, []);
        vert_image_inds = reshape(vert_image_inds, ims_per_batch, []);
        
        shuffled_inds = [hori_image_inds, vert_image_inds];
        shuffled_inds = shuffled_inds(:, randperm(size(shuffled_inds, 2)));
        
        shuffled_inds = num2cell(shuffled_inds, 1);
    end
    
    if nargout > 1
        % generate minibatch training data
        sub_inds = shuffled_inds{1};
        assert(length(sub_inds) == ims_per_batch);
        shuffled_inds(1) = [];
    end
end


function check_gpu_memory(conf, caffe_solver, num_classes, do_val)
%%  try to train/val with images which have maximum size potentially, to validate whether the gpu memory is enough  

    % generate pseudo training data with max size
    im_blob = single(zeros(max(conf.scales), conf.max_size, 3, conf.ims_per_batch));
    rois_blob = single(repmat([0; 0; 0; max(conf.scales)-1; conf.max_size-1], 1, conf.batch_size));
    rois_blob = permute(rois_blob, [3, 4, 1, 2]);
    labels_blob = single(ones(conf.batch_size, 1));
    labels_blob = permute(labels_blob, [3, 4, 2, 1]);
    bbox_targets_blob = zeros(4 * (num_classes+1), conf.batch_size, 'single');
    bbox_targets_blob = single(permute(bbox_targets_blob, [3, 4, 1, 2])); 
    bbox_loss_weights_blob = bbox_targets_blob;
    
    net_inputs = {im_blob, rois_blob, labels_blob, bbox_targets_blob, bbox_loss_weights_blob};
    
    % Reshape net's input blobs
    caffe_solver.net.reshape_as_input(net_inputs);

    % one iter SGD update
    caffe_solver.net.set_input_data(net_inputs);
    caffe_solver.step(1);

    if do_val
        % use the same net with train to save memory
        caffe_solver.net.set_phase('test');
        caffe_solver.net.forward(net_inputs);
        caffe_solver.net.set_phase('train');
    end
end

function model_path = snapshot(caffe_solver, bbox_means, bbox_stds, cache_dir, file_name, stage)
if stage==1
    bbox_stds_flatten = reshape(bbox_stds', [], 1);
    bbox_means_flatten = reshape(bbox_means', [], 1);
%%%%%%%%%%%middle Model%%%%%%%%%%%%%%%%%%%%%%%    
    % merge bbox_means, bbox_stds into the model
    bbox_pred_middle_layer_name = 'bbox_pred_middle';
    weights_middle = caffe_solver.net.params(bbox_pred_middle_layer_name, 1).get_data();
    biase_middle = caffe_solver.net.params(bbox_pred_middle_layer_name, 2).get_data();
    weights_back_middle = weights_middle;
    biase_back_middle = biase_middle;
    
    weights_middle = ...
        bsxfun(@times, weights_middle, bbox_stds_flatten'); % weights = weights * stds; 
    biase_middle = ...
        biase_middle .* bbox_stds_flatten + bbox_means_flatten; % bias = bias * stds + means;
    
    caffe_solver.net.set_params_data(bbox_pred_middle_layer_name, 1, weights_middle);
    caffe_solver.net.set_params_data(bbox_pred_middle_layer_name, 2, biase_middle);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%Large Model%%%%%%%%%%%%%%%%%%%%%%%    
    % merge bbox_means, bbox_stds into the model
    bbox_pred_large_layer_name = 'bbox_pred_large';
    weights_large = caffe_solver.net.params(bbox_pred_large_layer_name, 1).get_data();
    biase_large = caffe_solver.net.params(bbox_pred_large_layer_name, 2).get_data();
    weights_back_large = weights_large;
    biase_back_large = biase_large;
    
    weights_large = ...
        bsxfun(@times, weights_large, bbox_stds_flatten'); % weights = weights * stds; 
    biase_large = ...
        biase_large .* bbox_stds_flatten + bbox_means_flatten; % bias = bias * stds + means;
    
    caffe_solver.net.set_params_data(bbox_pred_large_layer_name, 1, weights_large);
    caffe_solver.net.set_params_data(bbox_pred_large_layer_name, 2, biase_large);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf('Save with bbox_mean and bbox_stds\n');
else
    fprintf('Save without bbox_mean and bbox_stds\n');
end
    model_path = fullfile(cache_dir, file_name);
    caffe_solver.net.save(model_path);
    fprintf('Saved as %s\n', model_path);
if stage==1    
    % restore net to original state    
    caffe_solver.net.set_params_data(bbox_pred_middle_layer_name, 1, weights_back_middle);
    caffe_solver.net.set_params_data(bbox_pred_middle_layer_name, 2, biase_back_middle);
    
    caffe_solver.net.set_params_data(bbox_pred_large_layer_name, 1, weights_back_large);
    caffe_solver.net.set_params_data(bbox_pred_large_layer_name, 2, biase_back_large);
end
end

function show_state(iter, train_results, val_results)
    fprintf('\n------------------------- Iteration %d -------------------------\n', iter);
    fprintf('Training : error %.3g, loss (cls %.3g, reg %.3g)\n', ...
        1 - mean(train_results.accuarcy.data), ...
        mean(train_results.loss_cls.data), ...
        mean(train_results.loss_bbox.data));
    if exist('val_results', 'var') && ~isempty(val_results)
        fprintf('Testing  : error %.3g, loss (cls %.3g, reg %.3g)\n', ...
            1 - mean(val_results.accuarcy.data), ...
            mean(val_results.loss_cls.data), ...
            mean(val_results.loss_bbox.data));
    end
end

function check_loss(rst, caffe_solver, input_blobs)
    im_blob = input_blobs{1};
    rois_blob = input_blobs{2};
    labels_blob = input_blobs{3};
    %label_weights_blob = input_blobs{3};
    bbox_targets_blob = input_blobs{4};
    bbox_loss_weights_blob = input_blobs{5};
    
    regression_output = caffe_solver.net.blobs('bbox_pred').get_data();
    % smooth l1 loss
    regression_delta = abs(regression_output(:) - bbox_targets_blob(:));
    regression_delta_l2 = regression_delta < 1;
    regression_delta = 0.5 * regression_delta .* regression_delta .* regression_delta_l2 + (regression_delta - 0.5) .* ~regression_delta_l2;
    regression_loss = sum(regression_delta.* bbox_loss_weights_blob(:)) / size(regression_output, 1) / size(regression_output, 2);
    
    confidence = caffe_solver.net.blobs('cls_score').get_data();
    labels = reshape(labels_blob, size(labels_blob, 1), []);
%     label_weights = reshape(label_weights_blob, size(label_weights_blob, 1), []);
    
    confidence_softmax = bsxfun(@rdivide, exp(confidence), sum(exp(confidence), 3));
    confidence_softmax = reshape(confidence_softmax, [], 2);
    confidence_loss = confidence_softmax(sub2ind(size(confidence_softmax), 1:size(confidence_softmax, 1), labels(:)' + 1));
    confidence_loss = -log(confidence_loss);
    confidence_loss = sum(confidence_loss' .* label_weights(:)) / sum(label_weights(:));
    
    results = parse_rst([], rst);
    fprintf('C++   : conf %f, reg %f\n', results.loss_cls.data, results.loss_bbox.data);
    fprintf('Matlab: conf %f, reg %f\n', confidence_loss, regression_loss);
end