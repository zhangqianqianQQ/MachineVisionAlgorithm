function finetuned_model_path = train_net_bbox_rec(...
    image_db_train, image_db_test, pooler, opts)

data_param                  = opts.data_param;
solver_param.test_iter      = data_param.test_iter;     
solver_param.test_interval  = data_param.test_interval; 
solver_param.max_iter       = opts.max_iter;

% ------------------------------------------------

work_dir  = opts.finetune_rst_dir;
timestamp = datestr(datevec(now()), 'yyyymmdd_HHMMSS');
log_file  = fullfile(work_dir, 'output', ['mrcnn_recognition_' timestamp, '.txt']);

mkdir_if_missing(work_dir);
mkdir_if_missing(fileparts(log_file));
diary(log_file);

fprintf('data_param:\n');
disp(data_param);
fprintf('solver_param:\n');
disp(solver_param);
fprintf('opts_param:\n');
disp(opts);
fprintf('pooler:\n');
disp(pooler);

%% get all data info
data.feature_paths_train = image_db_train.feature_paths;
data.feature_paths_test  = image_db_test.feature_paths;

[data.fg_windows_train, data.bg_windows_train] = setup_data(image_db_train, data_param);
[data.fg_windows_test,  data.bg_windows_test]  = setup_data(image_db_test,  data_param);

data.fg_windows_num_train = cell2mat(cellfun(@(x) size(x, 1), data.fg_windows_train, 'UniformOutput', false));
data.fg_windows_num_test  = cell2mat(cellfun(@(x) size(x, 1), data.fg_windows_test,  'UniformOutput', false));
data.bg_windows_num_train = cell2mat(cellfun(@(x) size(x, 1), data.bg_windows_train, 'UniformOutput', false));
data.bg_windows_num_test  = cell2mat(cellfun(@(x) size(x, 1), data.bg_windows_test,  'UniformOutput', false));

fprintf('total fg_windows_num_train : %d\n', sum(data.fg_windows_num_train));
fprintf('total bg_windows_num_train : %d\n', sum(data.bg_windows_num_train));
fprintf('total fg_windows_num_test  : %d\n', sum(data.fg_windows_num_test));
fprintf('total bg_windows_num_test  : %d\n', sum(data.bg_windows_num_test));

model.pooler = pooler;

current_dir = pwd;
cd(fileparts(opts.finetune_net_def_file))
% init caffe solver
[solver, iter_] = InitializeSolver(opts);

fprintf('Starting iteration %d\n', iter_);

% fix the random seed for repeatability
data_param_test                = data_param;
data_param_test.iter_per_batch = solver_param.test_iter;
data_param_test.random_scale   = 0; % for test use the best scale
data_param_test.nTimesMoreData = 10;

data.save_data_test_file = fullfile(work_dir, ...
    sprintf('data_test_file_batch%d_test_iter%d.mat', ...
    data_param_test.img_num_per_iter, data_param_test.iter_per_batch));
              
%% finetune
prev_rng = seed_rand();
mean_test_error = TestNet(solver, model, data_param_test, solver_param, data);

if isfield(opts, 'test_only') && opts.test_only
    finetuned_model_path = '';
    return;
end
last_finetuned_model_prev_path = '';

rng(prev_rng);
while(iter_ < solver_param.max_iter)
    mean_train_error = TrainNet(solver, model, data_param,      solver_param, data);
    mean_test_error  = TestNet( solver, model, data_param_test, solver_param, data);
    iter_            = solver.iter();
    ShowState(iter_, mean_train_error, mean_test_error);

    last_finetuned_model_path = fullfile(opts.finetune_rst_dir, sprintf('%s_iter_%d.caffemodel', opts.snapshot_prefix, iter_));
    assert(exist(last_finetuned_model_path,'file')>0);
    fprintf('last save as %s\n', last_finetuned_model_path);

    delete_prev_model_if_exist(last_finetuned_model_prev_path);
    last_finetuned_model_prev_path = last_finetuned_model_path;
    diary; diary; % flush diary
end
cd(current_dir);
finetuned_model_path = last_finetuned_model_path;
fprintf('Optimization is finished.\n')
end

function [solver, iter_] = InitializeSolver(opts)
solver = caffe.Solver(opts.finetune_net_def_file);
iter_   = 1;

if isfield(opts,'solver_state_file') && ~isempty(opts.solver_state_file)
    solver.restore(opts.solver_state_file);
    [directory,filename] = fileparts(opts.solver_state_file);
    model_file = [directory,filesep, filename, '.caffemodel'];
    solver.net.copy_from(model_file);
    solver.test_nets(1).copy_from(model_file);
    iter_   = solver.iter();    
    rng('shuffle')
else
    solver.net.copy_from(opts.net_file);
    solver.test_nets(1).copy_from(opts.net_file);
end
end

function delete_prev_model_if_exist(finetuned_model_prev_path)
if exist(finetuned_model_prev_path, 'file')
	delete(finetuned_model_prev_path);
end
[directory,filename] = fileparts(finetuned_model_prev_path);
finetuned_model_prev_path_solver_state = [directory,filesep, filename,'.solverstate'];
if exist(finetuned_model_prev_path_solver_state, 'file')
    delete(finetuned_model_prev_path_solver_state);
end
end

function [fg_windows, bg_windows] = setup_data_overlapV0(data_filename, data_param)

ld            = load(data_filename);
image_paths   = ld.image_paths;
all_proposals = ld.all_proposals;
all_bbox_gt   = ld.all_bbox_gt;
clear ld;

num_elems  = length(image_paths);
fg_windows = cell(num_elems, 1);
bg_windows = cell(num_elems, 1);

num_classes      = data_param.num_classes;
fg_threshold     = data_param.fg_threshold;
bg_threshold     = data_param.bg_threshold;
bg_threshold_min = bg_threshold(1);
bg_threshold_max = bg_threshold(2);

parfor i = 1:num_elems
    boxe_n_overap = select_bbox(image_paths{i}, all_bbox_gt{i}, all_proposals{i}, num_classes);
    boxes         = boxe_n_overap(:,1:4);
    overlap       = boxe_n_overap(:,5:end);
    
    [max_ov, label]    = max(overlap, [], 2);
    max_ov             = full(max_ov);
    
    fg_mask        = max_ov >= fg_threshold;
    fg_ov          = max_ov(fg_mask);
    fg_label       = label(fg_mask);
    fg_img_idx     = fg_label * 0 + i;
    fg_window      = boxes(fg_mask, :);
    fg_overlap_all = overlap(fg_mask,:);
    fg_windows{i} = [fg_img_idx, fg_label, fg_ov, fg_window, fg_overlap_all];
    if isempty(fg_windows{i})
        fg_windows{i} = zeros(0,7+size(overlap,2),'single');
    end
    
    bg_mask        = ~fg_mask & max_ov >= bg_threshold_min & max_ov < bg_threshold_max;
    bg_ov          = max_ov(bg_mask) * 0;
    bg_label       = label(bg_mask) * 0;
    bg_img_idx     = bg_label * 0 + i;
    bg_window      = boxes(bg_mask, :);
    bg_overlap_all = overlap(bg_mask,:);
    bg_windows{i}  = [bg_img_idx, bg_label, bg_ov, bg_window, bg_overlap_all];
    if isempty(bg_windows{i})
        bg_windows{i} = zeros(0,7+size(overlap,2),'single');
    end        
end
end

function [fg_windows, bg_windows] = setup_data(image_db, data_param)

image_paths   = image_db.image_paths;
all_regions   = image_db.all_regions;
all_bbox_gt   = image_db.all_bbox_gt;

num_elems  = length(image_paths);
fg_windows = cell(num_elems, 1);
bg_windows = cell(num_elems, 1);

num_classes      = data_param.num_classes;
fg_threshold     = data_param.fg_threshold;
bg_threshold     = data_param.bg_threshold;
bg_threshold_min = bg_threshold(1);
bg_threshold_max = bg_threshold(2);

for i = 1:num_elems
    boxe_n_overap = select_bbox(image_paths{i}, all_bbox_gt{i}, all_regions{i}, num_classes);
    boxes         = boxe_n_overap(:,1:4);
    overlap       = boxe_n_overap(:,5:end);
    
    [max_ov, label]    = max(overlap, [], 2);
    max_ov             = full(max_ov);
    
    fg_mask        = max_ov >= fg_threshold;
    fg_ov          = max_ov(fg_mask);
    fg_label       = label(fg_mask);
    fg_img_idx     = fg_label * 0 + i;
    fg_window      = boxes(fg_mask, :);
    fg_overlap_all = overlap(fg_mask,:);
    fg_windows{i} = [fg_img_idx, fg_label, fg_ov, fg_window, fg_overlap_all];
    if isempty(fg_windows{i})
        fg_windows{i} = zeros(0,7+size(overlap,2),'single');
    end
    
    bg_mask        = ~fg_mask & max_ov >= bg_threshold_min & max_ov < bg_threshold_max;
    bg_ov          = max_ov(bg_mask) * 0;
    bg_label       = label(bg_mask) * 0;
    bg_img_idx     = bg_label * 0 + i;
    bg_window      = boxes(bg_mask, :);
    bg_overlap_all = overlap(bg_mask,:);
    bg_windows{i}  = [bg_img_idx, bg_label, bg_ov, bg_window, bg_overlap_all];
    if isempty(bg_windows{i})
        bg_windows{i} = zeros(0,7+size(overlap,2),'single');
    end        
end
end

function bbox_out = select_bbox(image_file, bbox_gt_in, bbox_proposals, num_classes)

bbox_gt     = bbox_gt_in(:,1:4);
gt_label    = bbox_gt_in(:,5);

bbox_all    = [bbox_gt(:,1:4); bbox_proposals(:,1:4)];
overlap     = zeros(size(bbox_all,1), num_classes,'single');
    
for class_idx = 1:num_classes
    if any(gt_label == class_idx)
        bbox_gt_class = bbox_gt(gt_label == class_idx,1:4);
        overlap(:, class_idx) = max(boxoverlap(bbox_all, bbox_gt_class),[],2);
    end
end
bbox_out = single([bbox_all, overlap]);
end

function ShowState(iter, train_error, test_error)
fprintf('\n------------------------- Iteration %d -------------------------\n', iter);
fprintf('Error - Training : %.4f - Testing : %.4f\n', train_error, test_error);
end

function [mean_ave_prec, mean_test_error] = TestNet(solver, model, data_param, solver_param, data)
fprintf('Testing: ');
th = tic;

[data_test, label_test, windows_test] = create_test_batch(model, data_param, data);

assert(isnumeric(data_test));
assert(isnumeric(label_test));
assert(size(data_test,2)    == solver_param.test_iter * data_param.img_num_per_iter);
assert(size(data_test,1)    == data_param.feat_dim);
assert(size(label_test,2)   == solver_param.test_iter * data_param.img_num_per_iter);
assert(size(windows_test,1) == solver_param.test_iter * data_param.img_num_per_iter);

mini_batch_size = data_param.img_num_per_iter;

fprintf('elapsed time %.2f + ', toc(th));
th = tic;
test_error = nan(solver_param.test_iter, 1);
test_pred  = cell(solver_param.test_iter,1);
% fprintf('Testing: ');
for it = 1:solver_param.test_iter
    start_idx = (it-1) * mini_batch_size + 1;
    stop_idx  = it * mini_batch_size;
    assert(stop_idx <= size(data_test,2));

    mini_batch = prepare_mini_batch(data_test(:,start_idx:stop_idx), ...
                                   label_test(:,start_idx:stop_idx), data_param);
    caffe_set_input(solver.test_nets(1), mini_batch);
    solver.test_nets(1).forward_prefilled();
    
    test_error(it) = 1-solver.test_nets(1).blobs('accuracy').get_data();
    test_pred{it}  = solver.test_nets(1).blobs('predictions').get_data();
end

mean_test_error = mean(test_error);
data_test = []; label_test = [];
test_pred = cell2mat(test_pred(:)')';
mean_ave_prec = compute_mAP(test_pred, -1 + 2 * (windows_test(:,8:end) > data_param.fg_threshold ));
fprintf('%.2f sec --- error %.4f mAP %.5f\n', toc(th), mean_test_error, mean_ave_prec);
mean_ave_prec = 1 - mean_ave_prec;
end

function [mAP, AP] = compute_mAP(confidence, labels)
num_classes = size(labels,2);
if size(confidence,2) == num_classes
elseif size(confidence,2) == (num_classes+1)
    confidence = confidence(:,2:end); % the first column is the score for the background class
else
    error('Different number of confidence scores and labels');
end
AP = zeros(1,num_classes);
fprintf('\nAvePrec: ')
for c = 1:num_classes
    AP(c) = compute_average_precision( confidence(:,c), labels(:,c) );
    fprintf('[%d]=%.2f ',c,AP(c));
end
fprintf('\n')
mAP = mean(AP);
end

function mean_train_error = TrainNet(solver, model, data_param, solver_param, data)

test_interval   = solver_param.test_interval;
num_batches     = data_param.iter_per_batch;
num_epochs      = test_interval / num_batches;
mini_batch_size = data_param.img_num_per_iter;

train_count = 0;
train_error_sum   = 0;
for epoch = 1:num_epochs
    fprintf('Training: ');
    th = tic;

    windows_train = sample_window_data(data.fg_windows_train, data.fg_windows_num_train, ...
        data.bg_windows_train, data.bg_windows_num_train, data_param);
    label_train = windows_train(:,2)';
    data_train = prepare_batch_feat_input_data(model.pooler, ...
        data.feature_paths_train, windows_train, data_param);
    
    assert(isnumeric(data_train));
    assert(isnumeric(label_train));
    assert(size(data_train,2)  == num_batches * data_param.img_num_per_iter);
    assert(size(data_train,1)  == data_param.feat_dim);
    assert(size(label_train,2) == num_batches * data_param.img_num_per_iter);
    
    fprintf('elapsed time %3.2f + ', toc(th));
    
    th = tic;
    train_loss_sum = 0;
    for it = 1:num_batches
        start_idx = (it-1) * mini_batch_size + 1;
        stop_idx  = it * mini_batch_size;
        assert(stop_idx <= size(data_train,2));
        caffe_set_input(solver.net, ...
            prepare_mini_batch(data_train( :,start_idx:stop_idx), ...
                               label_train(:,start_idx:stop_idx), data_param));
        solver.step(1);
        
        results         = caffe_get_output(solver.net);
        train_error_sum = train_error_sum + (1-results{1}(1));
    	train_loss_sum  = train_loss_sum +  results{2}(1);
    end
    train_count = train_count + num_batches;
    data_train = []; label_train = [];
    fprintf('%3.2f sec --- error %.4f  loss %1.4f\n', toc(th), ...
        train_error_sum/train_count, train_loss_sum/num_batches);
end
mean_train_error = train_error_sum/train_count;
end

function [data_test, label_test, windows_test] = create_test_batch(model, data_param_test, data )
try 
    ld = load(data.save_data_test_file);
    data_test    = ld.data_test;
    label_test   = ld.label_test;
	windows_test = ld.windows_test;
catch
    windows_test = sample_window_data(data.fg_windows_test, data.fg_windows_num_test, ...
                                      data.bg_windows_test, data.bg_windows_num_test, data_param_test);
    data_test    = prepare_batch_feat_input_data(model.pooler, data.feature_paths_test, windows_test, data_param_test);
    label_test   = windows_test(:,2)';
    
    save(data.save_data_test_file, 'data_test', 'label_test', 'windows_test', '-v7.3');
end
end

function [windows, select_img_idx] = sample_window_data(...
    fg_windows, fg_windows_num, bg_windows, bg_windows_num, data_param)

nTimesMoreData = 10;

if isfield(data_param,'nTimesMoreData')
    nTimesMoreData = data_param.nTimesMoreData;
end
fg_num_each  = int32(data_param.fg_fraction * data_param.img_num_per_iter);
bg_num_each  = data_param.img_num_per_iter - fg_num_each;
fg_num_total = fg_num_each * data_param.iter_per_batch;
bg_num_total = bg_num_each * data_param.iter_per_batch;
num_img      = length(fg_windows);

% random perm image and get top n image with total more than patch_num
% windows
img_idx           = randperm(num_img);
fg_windows_num    = fg_windows_num(img_idx);
fg_windows_cumsum = cumsum(fg_windows_num);
bg_windows_num    = bg_windows_num(img_idx);
bg_windows_cumsum = cumsum(bg_windows_num);
img_idx_end       = max(find(fg_windows_cumsum > fg_num_total * nTimesMoreData, 1, 'first'), ...
                        find(bg_windows_cumsum > bg_num_total * nTimesMoreData, 1, 'first'));

if isempty( img_idx_end ), img_idx_end = length(img_idx); end

select_img_idx = img_idx(1:img_idx_end);
fg_windows_sel = cell2mat(fg_windows(select_img_idx));
bg_windows_sel = cell2mat(bg_windows(select_img_idx));

% random perm all windows, and drop redundant data
window_idx     = randperm(size(fg_windows_sel, 1));
fg_indices     = mod((1:fg_num_total) - 1, length(window_idx)) + 1;
fg_windows_sel = fg_windows_sel(window_idx(fg_indices), :);

window_idx     = randperm(size(bg_windows_sel, 1));
bg_indices     = mod((1:bg_num_total) - 1, length(window_idx)) + 1;
bg_windows_sel = bg_windows_sel(window_idx(bg_indices), :);

random_seed = randi(10^6, length(select_img_idx),1);
for i = 1:length(select_img_idx), rng(random_seed(i), 'twister'); end 

fg_windows_sel  = fg_windows_sel(randperm(size(fg_windows_sel, 1)),:);
bg_windows_sel  = bg_windows_sel(randperm(size(bg_windows_sel, 1)),:);

fg_split_div   = ones(1, data_param.iter_per_batch) * double(fg_num_each);
bg_split_div   = ones(1, data_param.iter_per_batch) * double(bg_num_each);
fg_windows_sel = mat2cell(fg_windows_sel, fg_split_div, size(fg_windows_sel, 2));
bg_windows_sel = mat2cell(bg_windows_sel, bg_split_div, size(bg_windows_sel, 2));
windows        = cellfun(@(x, y) [x; y], fg_windows_sel, bg_windows_sel, 'UniformOutput', false);
windows        = cell2mat(windows(:)); 
end

function mini_batch = prepare_mini_batch(data, labels, data_param)
data   = prepare_data(    data, data_param);
labels = prepare_labels(labels, data_param);
mini_batch = [data, labels];
end

function labels = prepare_labels(labels, data_param)

num_samples = size(labels,2);

if ~isfield(data_param, 'labels_split_div')
    labels_split_div = size(labels,1);
else
    labels_split_div = data_param.labels_split_div;
    assert(sum(labels_split_div) == size(labels,1));
end

labels = mat2cell(labels, labels_split_div, size(labels,2))';

if isfield(data_param, 'reshape_labels') 
    reshape_labels = data_param.reshape_labels;
    num_labels_types = length(labels);
    assert(length(labels) == length(reshape_labels));
    for i = 1:num_labels_types
        assert(length(reshape_labels{i}) == 4 || length(reshape_labels{i}) == 3);
        if length(reshape_labels{i}) == 3
            reshape_labels{i}(4) = num_samples;
        end
        labels{i} = reshape(labels{i}, reshape_labels{i});
    end
end

end

function data = prepare_data(data, data_param)
num_samples = size(data,2);

if ~isfield(data_param, 'data_split_div')
    data_split_div = size(data,1);
else
    data_split_div = data_param.data_split_div;
    assert(sum(data_split_div) == size(data,1));
end

data = mat2cell(data, data_split_div, size(data,2))';

if isfield(data_param, 'reshape_data') 
    reshape_data = data_param.reshape_data;
    num_data_types = length(data);
    assert(length(data) == length(reshape_data));
    for i = 1:num_data_types
        assert(length(reshape_data{i}) == 4 || length(reshape_data{i}) == 3);
        if length(reshape_data{i}) == 3
            reshape_data{i}(4) = num_samples;
        end
        data{i} = reshape(data{i}, reshape_data{i});
    end
end
end