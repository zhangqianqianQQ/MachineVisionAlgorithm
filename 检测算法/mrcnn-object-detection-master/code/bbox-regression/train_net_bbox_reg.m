function finetuned_model_path = train_net_bbox_reg(...
    image_db_train, image_db_test, pooler, opts)


data_param                  = opts.data_param;
solver_param.test_iter      = data_param.test_iter;     
solver_param.test_interval  = data_param.test_interval; 
solver_param.max_iter       = opts.max_iter;

% ------------------------------------------------

work_dir  = opts.finetune_rst_dir;
timestamp = datestr(datevec(now()), 'yyyymmdd_HHMMSS');
log_file  = fullfile(work_dir, 'output', ['mrcnn_regression_' timestamp, '.txt']);

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

data.feature_paths_train = image_db_train.feature_paths;
data.feature_paths_test  = image_db_test.feature_paths;

[data.fg_windows_train] = setup_data(image_db_train, data_param);
[data.fg_windows_test]  = setup_data(image_db_test,  data_param);

% data.fg_windows_train = setup_data(image_db_train, data_param);
% data.fg_windows_test  = setup_data(image_db_test,  data_param);

data.fg_windows_num_train = cell2mat(cellfun(@(x) size(x, 1), data.fg_windows_train, 'UniformOutput', false));
data.fg_windows_num_test  = cell2mat(cellfun(@(x) size(x, 1), data.fg_windows_test,  'UniformOutput', false));

fprintf('total fg_windows_num_train : %d\n', sum(data.fg_windows_num_train));
fprintf('total fg_windows_num_test  : %d\n', sum(data.fg_windows_num_test));

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

%min_test_error = TestNet(model, data_param_test, solver_param, data);

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
fprintf('Optimization is finished\n');
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

function ShowState(iter, train_error, test_error)
fprintf('\n------------------------- Iteration %d -------------------------\n', iter);
fprintf('Error - Training : %.4f - Testing : %.4f\n', train_error, test_error);
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

function fg_windows = setup_data(image_db, data_param)

image_paths = image_db.image_paths;
all_regions = image_db.all_regions;
all_bbox_gt = image_db.all_bbox_gt;

num_elems  = length(image_paths);
fg_windows = cell(num_elems, 1);

num_classes  = data_param.num_classes;
fg_threshold = data_param.fg_threshold;

for i = 1:num_elems
    fg_windows_this = setup_img_data(image_paths{i}, all_bbox_gt{i}, all_regions{i}, num_classes, fg_threshold);
    fg_windows{i}   = [ones(size(fg_windows_this,1),1,'single')*i, fg_windows_this];
end

end

function bbox_out = setup_img_data(image_file, bbox_gt, bbox_proposals, num_classes, low_ov_threshold)

bbox_gt_label = bbox_gt(:,5);

bbox_all    = [bbox_gt(:,1:4); bbox_proposals(:,1:4)];
overlap     = zeros(size(bbox_all,1), num_classes,     'single');
bbox_target = zeros(size(bbox_all,1), num_classes * 4, 'single');

for class_idx = 1:num_classes
    if any(bbox_gt_label == class_idx)
        bbox_gt_class = bbox_gt(bbox_gt_label == class_idx,1:4);
        overlap_class = boxoverlap(bbox_all(:,1:4), bbox_gt_class(:,1:4));
        [overlap(:, class_idx), gt_index] = max(overlap_class, [], 2);
        does_overlap = overlap(:, class_idx) > 0.001;
        bbox_target(does_overlap, (class_idx-1)*4 + (1:4)) = bbox_gt_class(gt_index(does_overlap), 1:4);
    end
end

[max_overlap, label] = max(overlap, [], 2);
keep = max_overlap >= low_ov_threshold;

bbox_all         = bbox_all(   keep,:);
overlap          = overlap(    keep,:);
bbox_target      = bbox_target(keep,:);
bbox_target_vals = encode_bbox_targets_to_reg_vals(bbox_all, bbox_target);

max_overlap      = max_overlap(keep);
label            = label(keep);

bbox_out         = single([label, max_overlap, bbox_all, overlap, bbox_target_vals, bbox_target]);
end

function [data_test, label_test, windows_test] = create_test_batch(model, data_param_test, data )
try 
    ld = load(data.save_data_test_file);
    data_test    = ld.data_test;
    label_test   = ld.label_test;
    windows_test = ld.windows_test;
catch
    windows_test = sample_window_data(data.fg_windows_test, data.fg_windows_num_test, data_param_test);
    data_test    = prepare_batch_feat_input_data(model.pooler, data.feature_paths_test, windows_test, data_param_test);
    label_test   = prepare_batch_target_data(windows_test, data_param_test);

    save(data.save_data_test_file, 'data_test', 'label_test', 'windows_test', '-v7.3');
end
end

function [windows, select_img_idx] = sample_window_data(fg_windows, fg_windows_num, data_param)

nTimesMoreData = 10;

if isfield(data_param,'nTimesMoreData')
    nTimesMoreData = data_param.nTimesMoreData;
end

fg_num_total = data_param.img_num_per_iter * data_param.iter_per_batch;
num_img      = length(fg_windows);

% random perm image and get top n image with total more than patch_num
% windows
img_idx           = randperm(num_img);
fg_windows_num    = fg_windows_num(img_idx);
fg_windows_cumsum = cumsum(fg_windows_num);
img_idx_end       = find(fg_windows_cumsum > (fg_num_total * nTimesMoreData), 1, 'first');


if isempty( img_idx_end ), img_idx_end = length(img_idx); end

select_img_idx = img_idx(1:img_idx_end);
fg_windows_sel = cell2mat(fg_windows(select_img_idx));

% random perm all windows, and drop redundant data
window_idx     = randperm(size(fg_windows_sel, 1));
fg_indices     = mod((1:fg_num_total) - 1, length(window_idx)) + 1;
fg_windows_sel = fg_windows_sel(window_idx(fg_indices), :);

random_seed = randi(10^6, length(select_img_idx),1); 
for i = 1:length(select_img_idx), rng(random_seed(i), 'twister'); end 

windows     = fg_windows_sel(randperm(size(fg_windows_sel, 1)),:);
end

function label = prepare_batch_target_data(windows, data_param)
num_classes  = data_param.num_classes;
num_reg_vals = num_classes * 4;
fg_threshold = data_param.fg_threshold;
mask         = windows(:,7+(1:num_classes)) >= fg_threshold;
mask         = repmat( mask, [4, 1]);
mask         = reshape(mask, [size(windows,1), num_classes*4]);
label        = [single(mask), windows(:,(7+num_classes)+(1:num_reg_vals))]';
end

function [mean_ave_recall, mean_test_error] = TestNet(solver, model, data_param, solver_param, data)
fprintf('Testing: ');
th = tic;

[data_test, label_test, windows_test] = create_test_batch(model, data_param, data );

assert(isnumeric(data_test));
assert(isnumeric(label_test));
assert(size(data_test,2)    == solver_param.test_iter * data_param.img_num_per_iter);
assert(size(data_test,1)    == data_param.feat_dim);
assert(size(label_test,2)   == solver_param.test_iter * data_param.img_num_per_iter);
assert(size(windows_test,1) == solver_param.test_iter * data_param.img_num_per_iter);

% windows_test = [fg_img_idx, fg_label, fg_ov, fg_window, fg_overlap_all, fg_bbox_target_vals, fg_bbox_target];
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

    mini_batch = prepare_mini_batch(data_test( :,start_idx:stop_idx), ...
                               label_test(:,start_idx:stop_idx), data_param);
    caffe_set_input(solver.test_nets(1), mini_batch);
    forward_prefilled(solver.test_nets(1));
    
    test_error(it) = solver.test_nets(1).blobs('error').get_data();
    test_pred{it}  = solver.test_nets(1).blobs('predictions').get_data();
end

mean_test_error = mean(test_error);

num_classes      = data_param.num_classes;
bbox_init        = windows_test(:,4:7);
all_bbox_pred    = repmat(bbox_init, [1, num_classes]);
all_bbox_targets = windows_test(:, (7+num_classes+num_classes*4) + (1:(num_classes*4)));
all_mask         = label_test(1:(num_classes*4),:)';

fprintf('Initial Candidate Boxes');
mean_ave_recall_init  = compute_mAR_of_bbox_reg(bbox_init, all_bbox_pred, all_bbox_targets, all_mask, num_classes);

all_reg_values  = cell2mat(test_pred(:)')';
all_bbox_pred   = decode_reg_vals_to_bbox_targets(bbox_init, all_reg_values);
fprintf('After Regression Candidate Boxes');
mean_ave_recall = compute_mAR_of_bbox_reg(bbox_init, all_bbox_pred, all_bbox_targets, all_mask, num_classes);
fprintf('%.2f sec --- error %.4f mAR %.5f --> %.5f\n', toc(th), mean_test_error, mean_ave_recall_init, mean_ave_recall);
mean_ave_recall = 1 - mean_ave_recall;

end

function mean_train_error = TrainNet(solver, model, data_param, solver_param, data)

test_interval   = solver_param.test_interval;
num_batches     = data_param.iter_per_batch;
num_epochs      = test_interval / num_batches;
mini_batch_size = data_param.img_num_per_iter;

train_count = 0;
train_error_sum = 0;
for epoch = 1:num_epochs
    fprintf('Training: ');
    th = tic;
    
    windows_train = sample_window_data(data.fg_windows_train,   data.fg_windows_num_train, data_param);
    data_train    = prepare_batch_feat_input_data(model.pooler, data.feature_paths_train, windows_train, data_param);
    label_train   = prepare_batch_target_data(windows_train, data_param);

    assert(isnumeric(data_train));
    assert(isnumeric(label_train));
    assert(size(data_train,2)  == num_batches * data_param.img_num_per_iter);
    assert(size(data_train,1)  == data_param.feat_dim);
    assert(size(label_train,2) == num_batches * data_param.img_num_per_iter);
    
    fprintf('elapsed time %.2f + ', toc(th));
    
    th = tic;
    train_error_sum_this = 0;
    for it = 1:num_batches
        start_idx = (it-1) * mini_batch_size + 1;
        stop_idx  = it * mini_batch_size;
        assert(stop_idx <= size(data_train,2));
        caffe_set_input(solver.net, ...
            prepare_mini_batch(data_train( :,start_idx:stop_idx), ...
                               label_train(:,start_idx:stop_idx), data_param));
        solver.step(1);
        
        results = caffe_get_output(solver.net);
    
        train_error_sum_this = train_error_sum_this + results{1}(1);
    end
    train_error_sum = train_error_sum + train_error_sum_this;
    train_count = train_count + num_batches;
    data_train = []; label_train = [];
    fprintf('%.2f sec --- error[total] %.4f - error[this] %.4f\n', toc(th), train_error_sum/train_count, train_error_sum_this/num_batches);
end
mean_train_error = train_error_sum/train_count;
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

function [mAR, AR] = compute_mAR_of_bbox_reg(bbox_init, all_bbox_pred, all_bbox_targets, all_mask, num_classes)

AR = zeros(1,num_classes);
fprintf('\nAveRecall: ')
for c = 1:num_classes
    bbox_pred    = all_bbox_pred(:,    (c-1)*4 + (1:4));
    bbox_targets = all_bbox_targets(:, (c-1)*4 + (1:4));
    mask         = all_mask(:,         (c-1)*4 + (1:4));
    is_not_gt    = ~all(bbox_init == bbox_targets, 2);
    bbox_pred    = bbox_pred(   is_not_gt, :);
    bbox_targets = bbox_targets(is_not_gt, :);
    mask         = mask(        is_not_gt, :);
    mask         = all(mask,2);
    bbox_pred    = bbox_pred(   mask,:);
    bbox_targets = bbox_targets(mask,:);
    AR(c)        = compute_ave_recall_of_bbox( bbox_pred, bbox_targets );
    fprintf('[%d]=%.2f ',c, AR(c));
end

fprintf('\n')
mAR = mean(AR);

end