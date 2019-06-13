function model = proposal_train2(conf, dataset, model, opts)
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
    % shared layer 부분만 복사한다(conv1 ~ conv5 까지)
    % 내부적으로 prototxt내에서 같은 이름을 갖는 layer만 복사
    % C:\Program Files\caffe-master\src\caffe\caffe\net.cpp 참조
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
    
    opts.empty_image_sample_step = 1;
    opts.fg_image_ratio = 0.5;
%% making tran/val data
    fprintf('Preparing training data...');
    % 각각의 이미지에서 anchor들을 생성하고, ground truth와의 IoU를 계산하여,
    % 각 anchor들이 positive sample인지 negative sample인지 둘다에 속하지 않는지를 저장한다.
    
    % proposal_prepare_image_roidb 에서는 anchor-->ground truth 의 target을 구하는 반면,
    % fast_rcnn_prepare_image_roidb 에서는 proposal_test 에서 생성된 proposal을 이용해
    % proposal-->ground truth의 target을 구한다.
    
    % bbox_means,stds 를 이용한 normalized target을 이용해 training 한다.
    % weight를 저장할때에는 bbox_means,stds를 이용해 원래 target이 나오도록, weight를 저장함으로써
    % (snapshot 함수) test시에 복원된 weight를 사용할수 있도록함
    [image_roidb_train, bbox_means, bbox_stds] = proposal_prepare_image_roidb(conf, dataset.imdb_train, dataset.roidb_train, opts.empty_image_sample_step);
    fprintf('Done.\n');
    
    if opts.do_val
        fprintf('Preparing validation data...');
        [image_roidb_val] = proposal_prepare_image_roidb(conf, dataset.imdb_test, dataset.roidb_test, opts.empty_image_sample_step, bbox_means, bbox_stds);
        fprintf('Done.\n');
    end
   
    
%%  try to train/val with images which have maximum size potentially, to validate whether the gpu memory is enough  
    check_gpu_memory(conf, caffe_solver, opts.do_val);
     
%% -------------------- Training -------------------- 

    proposal_generate_minibatch_fun = @proposal_generate_minibatch2;
    visual_debug_fun                = @proposal_visual_debug;

    % training
    shuffled_inds = [];
    train_results = [];
    val_results = [];
    iter_ = caffe_solver.iter();
    max_iter = caffe_solver.max_iter();
    
    top_val.lowest_error=1;
    top_val.corresponding_iter=0;
    while (iter_ < max_iter)
        caffe_solver.net.set_phase('train');

        % shuffled_inds에서 하나씩 뽑아 sub_db_inds에 저장한다.(sampling image)
        [shuffled_inds, sub_db_inds] = generate_random_minibatch(shuffled_inds, image_roidb_train, conf.ims_per_batch, opts.fg_image_ratio);        
        % sampling 된 image에서 mini-batch size개의 anchor를 뽑는다.
        % 실제로는 net_inputs{3}의 값이 1인 경우가 mini-batch sample인것으로 간주
        % positive sample은 net_inputs{2}의 값이 1인 경우이다.
        % negative sample은 net_inputs{3}의 값이 1인 경우에서 net_inputs{2}의 값이 1인
        % 경우를 제외한 index
        [net_inputs, scale_inds] = proposal_generate_minibatch_fun(conf, image_roidb_train(sub_db_inds));
        
        caffe_solver.net.reshape_as_input(net_inputs);
        % 현재 mini-batch 이미지의 사이즈에 맞게 caffe.net을 reshape
        % one iter SGD update
        caffe_solver.net.set_input_data(net_inputs);% net_inputs의 데이터를 caffe.net.input layer(maybe gpu memory)로 복사
        caffe_solver.step(1);% forward, backward, update를 한다.
        rst = caffe_solver.net.get_output();% accuracy,loss 값이 나옴
        rst = check_error(rst, caffe_solver);
        train_results = parse_rst(train_results, rst);
        % check_loss(rst, caffe_solver, net_inputs);

        % do valdiation per val_interval iterations
        if ~mod(iter_, opts.rpn_val_interval) 
            if opts.do_val
                val_results = do_validation(conf, caffe_solver, proposal_generate_minibatch_fun, image_roidb_val);
            end
            %err = 1-mean(val_results.accuracy_bg.data);
            err = mean(val_results.loss_cls.data);
            if(top_val.lowest_error>err)
                top_val.lowest_error=err;
                top_val.corresponding_iter=iter_;
            end
            show_state(iter_, train_results, val_results);% opts.val_interval(2000)마다 val,train의 accuracy 평균을 출력
            train_results = [];
            diary; diary; % flush diary
            snapshot(conf, caffe_solver, bbox_means, bbox_stds, cache_dir, sprintf('iter_%d', iter_));
        end
        
        iter_ = caffe_solver.iter();% iter_ = iter_ + 1
    end
    % final validation
    if opts.do_val
        val_results=do_validation(conf, caffe_solver, proposal_generate_minibatch_fun, image_roidb_val);
    end
    err = mean(val_results.loss_cls.data);
    if(top_val.lowest_error>err)
        top_val.lowest_error=err;
        top_val.corresponding_iter=iter_;
    end
    show_state(iter_, train_results, val_results);% opts.val_interval(2000)마다 val,train의 accuracy 평균을 출력
    diary; diary; % flush diary
    snapshot(conf, caffe_solver, bbox_means, bbox_stds, cache_dir, sprintf('iter_%d', iter_));
    %snapshot(conf, caffe_solver, bbox_means, bbox_stds, cache_dir, 'final');
    
    movefile(fullfile(cache_dir,sprintf('iter_%d', top_val.corresponding_iter)),fullfile(cache_dir,'final'));
    model.output_model_file=fullfile(cache_dir,'final');
    fprintf(sprintf('iter_%d is selected', top_val.corresponding_iter));
    
    diary off;
    caffe.reset_all(); 
    rng(prev_rng);
 
end

function val_results = do_validation(conf, caffe_solver, proposal_generate_minibatch_fun, image_roidb_val)
    val_results = [];

    caffe_solver.net.set_phase('test');
    for i = 1:length(image_roidb_val)
        [net_inputs, ~] = proposal_generate_minibatch_fun(conf, image_roidb_val(i));
        
        % Reshape net's input blobs
        caffe_solver.net.reshape_as_input(net_inputs);

        caffe_solver.net.forward(net_inputs);
        rst = caffe_solver.net.get_output();
        rst = check_error(rst, caffe_solver);  
        val_results = parse_rst(val_results, rst);
    end
end

function [shuffled_inds, sub_inds] = generate_random_minibatch(shuffled_inds, image_roidb, ims_per_batch, fg_image_ratio)

    % shuffle training data per batch
    if isempty(shuffled_inds)
        
        if ims_per_batch == 1
            % image_roidb 첫번째의 bbox가 sparse matrix면 에러가 나서 image_roidb(1)만
            % full로 바꿔주면 됨 kjh
            if(issparse( image_roidb(1).bbox_targets{1} ))
                image_roidb(1).bbox_targets{1}=full(image_roidb(1).bbox_targets{1});
            end
            empty_image_inds = arrayfun(@(x) sum(x.bbox_targets{1}(:, 1)==1) == 0, image_roidb, 'UniformOutput', true);
            nonempty_image_inds = ~empty_image_inds;
            empty_image_inds = find(empty_image_inds);
            nonempty_image_inds = find(nonempty_image_inds);
            
            if fg_image_ratio == 1 % 모든 training image는 human을 하나 이상 포함하도록
                shuffled_inds = nonempty_image_inds;
            else
                if length(nonempty_image_inds) > length(empty_image_inds)
                    empty_image_inds = repmat(empty_image_inds, ceil(length(nonempty_image_inds) / length(empty_image_inds)), 1);
                    empty_image_inds = empty_image_inds(1:length(nonempty_image_inds));
                else
                    % 만약 non-empty image가 부족하면 자신을 복제해서 empty image 개수만큼 맞춘다.
                    nonempty_image_inds = repmat(nonempty_image_inds, ceil(length(empty_image_inds) / length(nonempty_image_inds)), 1);
                    nonempty_image_inds = nonempty_image_inds(1:length(empty_image_inds));
                end
                % empty image중 (1-fg_image_ratio) 만큼만 random으로 가져오고,
                % non-empty image중 (fg_image_ratio)만큼 가져온다.
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

function check_gpu_memory(conf, caffe_solver, do_val)
%%  try to train/val with images which have maximum size potentially, to validate whether the gpu memory is enough  

    % generate pseudo training data with max size
    im_blob = single(zeros(max(conf.scales), conf.max_size, 3, 3));% conf.ims_per_batch -->3 (0628)
    
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

function model_path = snapshot(conf, caffe_solver, bbox_means, bbox_stds, cache_dir, file_name)
% proposal_bbox_pred layer의 weight들을 mean과 std를 더하고 곱하여 하드디스크에 save한다.(이전에 빼주고 나눠준
% 값으로 학습했기 떄문에) 그리고 원래 weight값(weight_back)을 사용해 원래대로 만든다.
% conv1~relu5~proposal_bbox_pred 까지의 weight를 저장
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
    % (sw)x+sb+m = y , y는 normalize 되기전의 target
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

function show_state(iter, train_results, val_results)
    fprintf('\n------------------------- Iteration %d -------------------------\n', iter);
    fprintf('Training : err_fg %.3g, err_bg %.3g, loss (cls %.3g + reg %.3g)\n', ...
        1 - mean(train_results.accuracy_fg.data), 1 - mean(train_results.accuracy_bg.data), ...
        mean(train_results.loss_cls.data), ...
        mean(train_results.loss_bbox.data));
    if exist('val_results', 'var') && ~isempty(val_results)
        fprintf('Testing  : err_fg %.3g, err_bg %.3g, loss (cls %.3g + reg %.3g)\n', ...
            1 - mean(val_results.accuracy_fg.data), 1 - mean(val_results.accuracy_bg.data), ...
            mean(val_results.loss_cls.data), ...
            mean(val_results.loss_bbox.data));
    end
end

function check_loss(rst, caffe_solver, input_blobs)
    im_blob = input_blobs{1};
    labels_blob = input_blobs{2};
    label_weights_blob = input_blobs{3};
    bbox_targets_blob = input_blobs{4};
    bbox_loss_weights_blob = input_blobs{5};
    
    regression_output = caffe_solver.net.blobs('proposal_bbox_pred').get_data();
    % smooth l1 loss
    regression_delta = abs(regression_output(:) - bbox_targets_blob(:));
    regression_delta_l2 = regression_delta < 1;
    regression_delta = 0.5 * regression_delta .* regression_delta .* regression_delta_l2 + (regression_delta - 0.5) .* ~regression_delta_l2;
    regression_loss = sum(regression_delta.* bbox_loss_weights_blob(:)) / size(regression_output, 1) / size(regression_output, 2);
    
    confidence = caffe_solver.net.blobs('proposal_cls_score_reshape').get_data();
    labels = reshape(labels_blob, size(labels_blob, 1), []);
    label_weights = reshape(label_weights_blob, size(label_weights_blob, 1), []);
    
    confidence_softmax = bsxfun(@rdivide, exp(confidence), sum(exp(confidence), 3));
    confidence_softmax = reshape(confidence_softmax, [], 2);
    confidence_loss = confidence_softmax(sub2ind(size(confidence_softmax), 1:size(confidence_softmax, 1), labels(:)' + 1));
    confidence_loss = -log(confidence_loss);
    confidence_loss = sum(confidence_loss' .* label_weights(:)) / sum(label_weights(:));
    
    results = parse_rst([], rst);
    fprintf('C++   : conf %f, reg %f\n', results.loss_cls.data, results.loss_bbox.data);
    fprintf('Matlab: conf %f, reg %f\n', confidence_loss, regression_loss);
end