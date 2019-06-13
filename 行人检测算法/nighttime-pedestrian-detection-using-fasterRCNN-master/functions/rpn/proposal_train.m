function model = proposal_train(conf, dataset, model, opts)
%% try to find trained model
    cache_dir = fullfile(model.cache_name, 'train');
    save_model_path = fullfile(cache_dir, 'final');
    if exist(save_model_path, 'file')
        model.output_model_file = save_model_path;
        return;
    end
%% init  

    mkdir_if_missing(cache_dir);
    caffe_log_file_base = fullfile(cache_dir, 'caffe_log');
    caffe.init_log(caffe_log_file_base);
    caffe_solver = caffe.Solver(model.solver_def_file);
    caffe_solver.net.copy_from(model.init_net_file);
    
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
    

%% making tran/val data
    fprintf('Preparing training data...');
    % create 9 anchors per images and calculate IoU between ground truth
    % proposal_prepare_image_roidb: targets from anchor to ground truth
    % fast_rcnn_prepare_image_roidb: targets from RPN proposal to ground truth
    % training with normalized targets using bbox_means,stds
    [image_roidb_train, bbox_means, bbox_stds] = proposal_prepare_image_roidb(conf, dataset.imdb_train, dataset.roidb_train);
    fprintf('Done.\n');
    
%% -------------------- Training -------------------- 

    % training
    shuffled_inds = [];
    train_results = [];  
    iter_ = caffe_solver.iter();
    max_iter = caffe_solver.max_iter();
    
    while (iter_ <= max_iter)
        caffe_solver.net.set_phase('train');
        % image sampling
        [shuffled_inds, sub_db_inds] = generate_random_minibatch(shuffled_inds, image_roidb_train, conf.ims_per_batch, opts.fg_image_ratio);    
        % randomly select anchors from the sampled image.
        [net_inputs, ~] = proposal_generate_minibatch(conf, image_roidb_train(sub_db_inds), true, model.multi_frame);
        caffe_solver.net.reshape_as_input(net_inputs);
        % one iter SGD update
        caffe_solver.net.set_input_data(net_inputs);
        caffe_solver.step(1);% forward, backward, update
        
        rst = caffe_solver.net.get_output();
        rst = check_error(rst, caffe_solver);
        train_results = parse_rst(train_results, rst);

        % do valdiation per val_interval iterations
        if ~mod(iter_, (max_iter/opts.val_interval)) && iter_~=0
            show_state(iter_, train_results);
            train_results = [];
            diary; diary; % flush diary
            if(iter_~=max_iter), name=sprintf('iter_%d', iter_);
            else, name='final'; end 
            snapshot(conf, caffe_solver, bbox_means, bbox_stds, cache_dir, name);
        end
        
        iter_ = caffe_solver.iter();% iter_ = iter_ + 1
    end
    model.output_model_file=fullfile(cache_dir,'final');
    diary off;
    caffe.reset_all(); 
    rng(prev_rng);
    
%     select_final_model(conf,dataset.imdb_val,dataset.roidb_val,model,true,max_iter,opts.val_interval);%false mean rpn
end

function [shuffled_inds, sub_inds] = generate_random_minibatch(shuffled_inds, image_roidb, ims_per_batch, fg_image_ratio)

    % shuffle training data per batch
    if isempty(shuffled_inds)
        
        if ims_per_batch == 1
            if(issparse( image_roidb(1).bbox_targets{1} ))
                image_roidb(1).bbox_targets{1}=full(image_roidb(1).bbox_targets{1});
            end
            empty_image_inds = arrayfun(@(x) sum(x.bbox_targets{1}(:, 1)==1) == 0, image_roidb, 'UniformOutput', true);
            nonempty_image_inds = ~empty_image_inds;
            empty_image_inds = find(empty_image_inds);
            nonempty_image_inds = find(nonempty_image_inds);
            
            if fg_image_ratio == 1 % use training image that contain at least one pedestrian
                shuffled_inds = nonempty_image_inds;
            else
                if length(nonempty_image_inds) > length(empty_image_inds)
                    empty_image_inds = repmat(empty_image_inds, ceil(length(nonempty_image_inds) / length(empty_image_inds)), 1);
                    empty_image_inds = empty_image_inds(1:length(nonempty_image_inds));
                else
                    nonempty_image_inds = repmat(nonempty_image_inds, ceil(length(empty_image_inds) / length(nonempty_image_inds)), 1);
                    nonempty_image_inds = nonempty_image_inds(1:length(empty_image_inds));
                end
                empty_image_inds = empty_image_inds(randperm(length(empty_image_inds), round(length(empty_image_inds) * (1 - fg_image_ratio))));
                nonempty_image_inds = nonempty_image_inds(randperm(length(nonempty_image_inds), round(length(nonempty_image_inds) * fg_image_ratio)));
                
                shuffled_inds = [nonempty_image_inds; empty_image_inds];
            end
            
            shuffled_inds = shuffled_inds(randperm(size(shuffled_inds, 1)));
            shuffled_inds = num2cell(shuffled_inds, 2);
            
        else
            
            % make sure each minibatch, contain half (or half+1) gt-nonempty
            % image, and half gt-empty image
            empty_image_inds = arrayfun(@(x) sum(x.bbox_targets{1}(:, 1)==1) == 0, image_roidb, 'UniformOutput', true);
            nonempty_image_inds = ~empty_image_inds;
            empty_image_inds = find(empty_image_inds);
            nonempty_image_inds = find(nonempty_image_inds);
            
            empty_image_per_batch = floor(ims_per_batch / 2);
            nonempty_image_per_batch = ceil(ims_per_batch / 2);
            
            % random perm
            lim = floor(length(nonempty_image_inds) / nonempty_image_per_batch) * nonempty_image_per_batch;
            nonempty_image_inds = nonempty_image_inds(randperm(length(nonempty_image_inds), lim));
            nonempty_image_inds = reshape(nonempty_image_inds, nonempty_image_per_batch, []);
            if numel(empty_image_inds) >= lim
                empty_image_inds = empty_image_inds(randperm(length(nonempty_image_inds), empty_image_per_batch*lim/nonempty_image_per_batch));
            else
                empty_image_inds = empty_image_inds(mod(randperm(lim, empty_image_per_batch*lim/nonempty_image_per_batch), length(empty_image_inds))+1);
            end
            empty_image_inds = reshape(empty_image_inds, empty_image_per_batch, []);
            
            % combine sample for each ims_per_batch
            empty_image_inds = reshape(empty_image_inds, empty_image_per_batch, []);
            nonempty_image_inds = reshape(nonempty_image_inds, nonempty_image_per_batch, []);
            
            shuffled_inds = [nonempty_image_inds; empty_image_inds];
            shuffled_inds = shuffled_inds(:, randperm(size(shuffled_inds, 2)));
            
            shuffled_inds = num2cell(shuffled_inds, 1);
        end
    end
    
    if nargout > 1
        % generate minibatch training data
        sub_inds = shuffled_inds{1};
        assert(length(sub_inds) == ims_per_batch);
        shuffled_inds(1) = [];
    end
end

function rst = check_error(rst, caffe_solver)
    cls_score = caffe_solver.net.blobs('proposal_cls_score_reshape').get_data();
    labels = caffe_solver.net.blobs('labels_reshape').get_data();
    labels_weights = caffe_solver.net.blobs('labels_weights_reshape').get_data();
    
    accurate_fg = (cls_score(:, :, 2) > cls_score(:, :, 1)) & (labels == 1);
    accurate_bg = (cls_score(:, :, 2) <= cls_score(:, :, 1)) & (labels == 0);
    accurate = accurate_fg | accurate_bg;
    accuracy_fg = sum(accurate_fg(:) .* labels_weights(:)) / (sum(labels_weights(labels == 1)) + eps);
    accuracy_bg = sum(accurate_bg(:) .* labels_weights(:)) / (sum(labels_weights(labels == 0)) + eps);

    rst(end+1) = struct('blob_name', 'accuracy_fg', 'data', accuracy_fg);
    rst(end+1) = struct('blob_name', 'accuracy_bg', 'data', accuracy_bg);
end

function check_gpu_memory(conf, caffe_solver, do_val, multi_frame)
%%  try to train/val with images which have maximum size potentially, to validate whether the gpu memory is enough  

    % generate pseudo training data with max size
    im_blob = single(zeros(max(conf.scales), conf.max_size, 3, conf.ims_per_batch));
    
    anchor_num = size(conf.anchors, 1);
    output_width = conf.output_width_map.values({size(im_blob, 1)});
    output_width = output_width{1};
    output_height = conf.output_width_map.values({size(im_blob, 2)});
    output_height = output_height{1};
    labels_blob = single(zeros(output_width, output_height, anchor_num, conf.ims_per_batch));
    labels_weights = labels_blob;
    bbox_targets_blob = single(zeros(output_width, output_height, anchor_num*4, conf.ims_per_batch));
    bbox_loss_weights_blob = bbox_targets_blob;

    net_inputs = {im_blob, labels_blob, labels_weights, bbox_targets_blob, bbox_loss_weights_blob};
    
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

% save the weights of proposal_bbox_pred layer in hard-disk
% after adding mean vector and multiplying std vector
function model_path = snapshot(conf, caffe_solver, bbox_means, bbox_stds, cache_dir, file_name)
    anchor_size = size(conf.anchors, 1);
    bbox_stds_flatten = repmat(reshape(bbox_stds', [], 1), anchor_size, 1);
    bbox_means_flatten = repmat(reshape(bbox_means', [], 1), anchor_size, 1);
    
    % merge bbox_means, bbox_stds into the model
    bbox_pred_layer_name = 'proposal_bbox_pred';
    weights = caffe_solver.net.params(bbox_pred_layer_name, 1).get_data();
    biase = caffe_solver.net.params(bbox_pred_layer_name, 2).get_data();
    weights_back = weights;
    biase_back = biase;
    
    % wx+b = (y-m)/s , where w:weight x:input b:bias y:output m:mean s:sigma
    % (sw)x+sb+m = y , y is target before normalized
    weights = bsxfun(@times, weights, permute(bbox_stds_flatten, [2, 3, 4, 1])); % weights = weights * stds; 
    biase = biase .* bbox_stds_flatten + bbox_means_flatten; % bias = bias * stds + means;
    
    caffe_solver.net.set_params_data(bbox_pred_layer_name, 1, weights);
    caffe_solver.net.set_params_data(bbox_pred_layer_name, 2, biase);
    
    model_path = fullfile(cache_dir, file_name);
    caffe_solver.net.save(model_path);
    fprintf('Saved as %s\n', model_path);
    
    
    % restore net to original state
    caffe_solver.net.set_params_data(bbox_pred_layer_name, 1, weights_back);
    caffe_solver.net.set_params_data(bbox_pred_layer_name, 2, biase_back);
end

function show_state(iter, train_results)
    fprintf('\n------------------------- Iteration %d -------------------------\n', iter);
    fprintf('Training : err_fg %.3g, err_bg %.3g, loss (cls %.3g + reg %.3g)\n', ...
        1 - mean(train_results.accuracy_fg.data), 1 - mean(train_results.accuracy_bg.data), ...
        mean(train_results.loss_cls.data), ...
        mean(train_results.loss_bbox.data));
end
