function model = fast_rcnn_train2(conf, dataset, model, opts)
% save_model_path = fast_rcnn_train(conf, imdb_train, roidb_train, varargin)
% --------------------------------------------------------
% Fast R-CNN
% Reimplementation based on Python Fast R-CNN (https://github.com/rbgirshick/fast-rcnn)
% Copyright (c) 2015, Shaoqing Ren
% Licensed under The MIT License [see LICENSE for details]
% -------------------------------------------------------
%% try to find trained model
    cache_dir = fullfile(model.cache_name, 'train');
    save_model_path = fullfile(cache_dir, 'final');
    if exist(save_model_path, 'file')
        model.output_model_file = save_model_path;
        return;
    end
    
%% init
    % init caffe solver
    mkdir_if_missing(cache_dir);
    caffe_log_file_base = fullfile(cache_dir, 'caffe_log');
    caffe.init_log(caffe_log_file_base);
    % train_val.prototxt를 원하는 class 만큼의 개수로 변경해줘야함
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
    % proposal_prepare_image_roidb 에서는 anchor-->ground truth 의 target을 구하는 반면,
    % fast_rcnn_prepare_image_roidb 에서는 proposal_test 에서 생성된 proposal을 이용해
    % proposal-->ground truth의 target을 구한다.
    
    % bbox_means,stds 를 이용한 normalized target을 이용해 training 한다.
    % weight를 저장할때에는 bbox_means,stds를 이용해 원래 target이 나오도록, weight를 저장함으로써
    % (snapshot 함수) test시에 복원된 weight를 사용할수 있도록함
    [image_roidb_train, bbox_means, bbox_stds] = fast_rcnn_prepare_image_roidb(conf, dataset.imdb_train, dataset.roidb_train);
    fprintf('Done.\n');
    
    if opts.do_val
        fprintf('Preparing validation data...');
        [image_roidb_val] = fast_rcnn_prepare_image_roidb(conf, dataset.imdb_test, dataset.roidb_test, bbox_means, bbox_stds);
        fprintf('Done.\n');
    end
    
%%  try to train/val with images which have maximum size potentially, to validate whether the gpu memory is enough  
    check_gpu_memory(conf, caffe_solver, 1, opts.do_val);
    
%% training
    shuffled_inds = [];
    train_results = [];  
    val_results = [];  
    iter_ = caffe_solver.iter();
    max_iter = caffe_solver.max_iter();
    
    top_val.lowest_error=1;
    top_val.corresponding_iter=0;
    fg_ratio=zeros(1,max_iter);
    avg_feat_act=[];
    while (iter_ < max_iter)
        caffe_solver.net.set_phase('train');

        % generate minibatch training data
        [shuffled_inds, sub_db_inds] = generate_random_minibatch(shuffled_inds, image_roidb_train, conf.ims_per_batch2);
        [im_blob, rois_blob, labels_blob, bbox_targets_blob, bbox_loss_weights_blob] = ...
            fast_rcnn_get_minibatch2(conf, image_roidb_train(sub_db_inds),true);
        % im_blob : 2개의 이미지
        % rois_blob : size=(1,1,5,128) 5는 두 이미지중 어떤 이미지에서 나온 roi인지에 대한 정보 1개 와 coordinate 4개로
        % 이루어짐 128은 mini-batch size
        % labels_blob : (1,1,1,128) 각 roi의 class label
        % bbox_targets_blob : (1,1,84,128) 각 roi가 자신이 속한 ground truth의
        % class로 매핑되기 위한 target값 4개를 저장한다. 총 21개의 class 이므로 21*4=84개의 값을
        % 갖지만 실제로 값이 들어가는것은 자신이 속한 class부분의 4개값이다. negative roi의 경우 소속한
        % ground truth가 없기 떄문에 모두 0이다.
        % bbox_loss_weights_blob : (1,1,84,128) bbox_targets_blob에서 값이 존재하는
        % 부분만 1의 값을 갖고 나머지는 0으로 채워져있다. 즉, loss를 계산할때, 자신이 속한 class가 아닌 다른
        % 부분에서의 regression loss는 고려하지 않도록 하기위함 인듯. 예를 들어, negative roi의 경우는 자신이 속한
        % class가 없기떄문에 regression loss는 없다.
        net_inputs = {im_blob, rois_blob, labels_blob, bbox_targets_blob, bbox_loss_weights_blob};
        caffe_solver.net.reshape_as_input(net_inputs);
        tmp=squeeze(bbox_loss_weights_blob);
        fg_ratio(iter_)=sum(tmp(1,:)==1)/conf.batch_size2;%positive samples in mini-batch
        
        % one iter SGD update
        caffe_solver.net.set_input_data(net_inputs);
        caffe_solver.step(1);
        
        rst = caffe_solver.net.get_output();
        train_results = parse_rst(train_results, rst);
            
        % do valdiation per val_interval iterations
        if ~mod(iter_, opts.rcnn_val_interval) 
            if opts.do_val
                [val_results,act_mean]=do_validation(conf,caffe_solver,image_roidb_val);
                avg_feat_act=cat(3,avg_feat_act,act_mean);
            end
            
            error = 1 - mean(val_results.accuarcy.data);
            if(top_val.lowest_error>error)
                top_val.lowest_error=error;
                top_val.corresponding_iter=iter_;
            end
            
            show_state(iter_, train_results, val_results);
            train_results = [];
            val_results = [];
            diary; diary; % flush diary
            snapshot(caffe_solver, bbox_means, bbox_stds, cache_dir, sprintf('iter_%d', iter_));
        end
        
        iter_ = caffe_solver.iter();
    end
    
    if opts.do_val
        [val_results,act_mean]=do_validation(conf,caffe_solver,image_roidb_val);
        avg_feat_act=cat(3,avg_feat_act,act_mean);
    end
    error = 1 - mean(val_results.accuarcy.data);
    if(top_val.lowest_error>error)
        top_val.lowest_error=error;
        top_val.corresponding_iter=iter_;
    end
    show_state(iter_, train_results, val_results);
    diary; diary; % flush diary
    snapshot(caffe_solver, bbox_means, bbox_stds, cache_dir, sprintf('iter_%d', iter_));
    save(fullfile(cache_dir,'fg_ratio_per_iter'),'fg_ratio');
    save(fullfile(cache_dir,'avg_feat_act'),'avg_feat_act');
    %model.output_model_file = snapshot(caffe_solver, bbox_means, bbox_stds, cache_dir, 'final');
    
    movefile(fullfile(cache_dir,sprintf('iter_%d', top_val.corresponding_iter)),fullfile(cache_dir,'final'));
    model.output_model_file=fullfile(cache_dir,'final');
    fprintf(sprintf('iter_%d is selected', top_val.corresponding_iter));

    diary off;
    caffe.reset_all(); 
    rng(prev_rng);
end

function [val_results, avg_feat_act] = do_validation(conf, caffe_solver, image_roidb_val)
    val_results=[];
    caffe_solver.net.set_phase('test');  
    L=length(image_roidb_val);
    avg_feat_act=zeros(2,4);
    fw=57;
    fh=45;
    for i = 1:L
        % 이미지마다 고정된 roi sample이 들어가도록 함
        [im_blob, rois_blob, labels_blob, bbox_targets_blob, bbox_loss_weights_blob] = ...
            fast_rcnn_get_minibatch2(conf, image_roidb_val(i), false);
        
        % Reshape net's input blobs
        net_inputs = {im_blob, rois_blob, labels_blob, bbox_targets_blob, bbox_loss_weights_blob};
        caffe_solver.net.reshape_as_input(net_inputs);
        caffe_solver.net.forward(net_inputs);

        tmp=squeeze(bbox_loss_weights_blob);
        fg_ind=tmp(1,:)==1;
        bg_ind=tmp(1,:)==0;
        
        tmp=squeeze(rois_blob);
        fg_rois=tmp(:,fg_ind);
        bg_rois=tmp(:,bg_ind);
        f1=caffe_solver.net.blob_vec(25).get_data();%f1
        f2=caffe_solver.net.blob_vec(26).get_data();%f2
        f= caffe_solver.net.blob_vec(27).get_data();%feature
        
        for fg=1:sum(fg_ind)
            roi=fg_rois(:,fg);
            roi = floor(roi(2:5) / single(conf.feat_stride))+1;
            if(roi(1)<1 || roi(1)>fw ||roi(2)<1 || roi(2)>fh ||roi(3)<1 || roi(3)>fw ||roi(4)<1 || roi(4)>fh)
                continue; end
            avg_feat_act(1,1)=avg_feat_act(1,1)+roi_mean(f1,roi);
            avg_feat_act(1,2)=avg_feat_act(1,2)+roi_mean(f2,roi);
            avg_feat_act(1,3)=avg_feat_act(1,3)+roi_mean(f,roi);
            avg_feat_act(1,4)=avg_feat_act(1,4)+1;
        end
        
        for bg=1:sum(bg_ind)
            roi=bg_rois(:,bg);
            roi = floor(roi(2:5) / single(conf.feat_stride))+1;
            if(roi(1)<1 || roi(1)>fw ||roi(2)<1 || roi(2)>fh ||roi(3)<1 || roi(3)>fw ||roi(4)<1 || roi(4)>fh)
                continue; end
            avg_feat_act(2,1)=avg_feat_act(2,1)+roi_mean(f1,roi);
            avg_feat_act(2,2)=avg_feat_act(2,2)+roi_mean(f2,roi);
            avg_feat_act(2,3)=avg_feat_act(2,3)+roi_mean(f,roi);
            avg_feat_act(2,4)=avg_feat_act(2,4)+1;
        end
        
        rst = caffe_solver.net.get_output();
        val_results = parse_rst(val_results, rst);
    end
end

function avg=roi_mean(f,roi)
    roi_f=f(roi(1):roi(3),roi(2):roi(4),:);
    avg=mean(roi_f(:));
end

function [shuffled_inds, sub_inds] = generate_random_minibatch(shuffled_inds, image_roidb_train, ims_per_batch)

    % shuffle training data per batch
    if isempty(shuffled_inds)
        % make sure each minibatch, only has horizontal images or vertical
        % images, to save gpu memory
        
        %hori_image_inds = arrayfun(@(x) x.imsize(2) >= x.imsize(1), image_roidb_train, 'UniformOutput', true);
        hori_image_inds = ones(length(image_roidb_train),1); % 모든 이미지크기는 고정
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
    im_blob = single(zeros(max(conf.scales), conf.max_size, 3, 3));
    rois_blob = single(repmat([0; 0; 0; max(conf.scales)-1; conf.max_size-1], 1, conf.batch_size2));
    rois_blob = permute(rois_blob, [3, 4, 1, 2]);
    labels_blob = single(ones(conf.batch_size2, 1));
    labels_blob = permute(labels_blob, [3, 4, 2, 1]);
    bbox_targets_blob = zeros(4 , conf.batch_size2, 'single');
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

function model_path = snapshot(caffe_solver, bbox_means, bbox_stds, cache_dir, file_name)
    bbox_stds_flatten = reshape(bbox_stds', [], 1);
    bbox_means_flatten = reshape(bbox_means', [], 1);
    
    % merge bbox_means, bbox_stds into the model
    bbox_pred_layer_name = 'bbox_pred';
    weights = caffe_solver.net.params(bbox_pred_layer_name, 1).get_data();
    biase = caffe_solver.net.params(bbox_pred_layer_name, 2).get_data();
    weights_back = weights;
    biase_back = biase;
    
    weights = ...
        bsxfun(@times, weights, bbox_stds_flatten'); % weights = weights * stds; 
    biase = ...
        biase .* bbox_stds_flatten + bbox_means_flatten; % bias = bias * stds + means;
    
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
