function [all_classes_svm_model_path, all_classes_svm_model] = train_detection_svm_with_hard_mining( ...
    model, image_paths, in_feature_paths, all_bbox_gt, all_bbox_proposals, varargin )

ip = inputParser;
ip.addParamValue('use_hard_pos',    false,      @islogical);
ip.addParamValue('pos_loss_weight',    2,       @isscalar);
ip.addParamValue('use_gt_for_neg',  true,       @islogical);
ip.addParamValue('neg_overlap_thr',  0.3,       @isscalar);

ip.addParamValue('train_classes',    {},        @iscell);
ip.addParamValue('svm_C',         10^-3,        @isscalar);
ip.addParamValue('max_epochs',        1,        @isscalar);
ip.addParamValue('prefix',           '',        @ischar);
ip.addParamValue('force',         false,        @islogical);
ip.addParamValue('exp_dir', '', @ischar);

ip.parse(varargin{:});
opts = ip.Results;

th_all = tic;
assert(~isempty(opts.exp_dir));

model.feat_norm_mean = compute_feature_stats(model, image_paths, in_feature_paths, all_bbox_proposals, opts.exp_dir);

opts = parse_training_opts(opts, model.classes, model.feat_norm_mean, model.feat_blob_name);

not_existing_class_inds = find_missing_models(opts, model.classes, opts.class_indices);
if ~isempty(not_existing_class_inds)
    do_training(model, image_paths, in_feature_paths, all_bbox_gt, ...
        all_bbox_proposals, opts, not_existing_class_inds)
end

for c = 1:numel(opts.class_indices)
    class_idx       = opts.class_indices(c);
    save_model_file = sprintf(opts.filepath_model_per_epoch{opts.max_epochs}, [opts.all_classes{class_idx}, '_all']);
    assert(exist(save_model_file,'file') ~= 0);
end


all_classes_svm_model_path = sprintf(opts.filepath_model_per_epoch{opts.max_epochs}, 'all_classes_svm');
try 
    all_classes_svm_model      = load_svm_model(all_classes_svm_model_path);
catch
    svm_models_path            = sprintf(opts.filepath_model_per_epoch{opts.max_epochs}, '%s_all');
    all_classes_svm_model      = gather_svm_detectors(opts.all_classes, svm_models_path, model.feat_norm_mean);
    save_svm_model(all_classes_svm_model_path, all_classes_svm_model);
end

fprintf('train_detection_svm_with_hard_mining time   %.4fmins\n', toc(th_all)/60);
end

function weights = gather_svm_detectors(classes, svm_models_path, feat_norm_mean)
num_classes = numel(classes); 
assert(ischar(svm_models_path));
is_first = true;
for class_idx = 1:num_classes
    svm_model = load_svm_model(sprintf(svm_models_path, classes{class_idx}));
    if is_first
        is_first = false;
        W = zeros(num_classes, length(svm_model{1}), 'single');
        B = zeros(num_classes, 1, 'single');
    end
    W(class_idx,:) = svm_model{1};
    B(class_idx,1) = svm_model{2};  
end
weights = {scale_features(W, feat_norm_mean)', B};
end

function cache = find_support_vectors(cache)
model_weights = cache.model_weights;
z_neg   = model_weights{1} * cache.X_neg + model_weights{2};
z_pos   = model_weights{1} * cache.X_pos + model_weights{2};

sup_vec_neg  = z_neg  >   -1 - eps;
sup_vec_pos  = z_pos  <  1.0 + eps;
    
margin_neg  = -1 * z_neg(sup_vec_neg);
margin_pos  =  1 * z_pos(sup_vec_pos);

cache.X_neg_bbox_sup_vec  = [cache.X_neg_bbox(sup_vec_neg,:), margin_neg(:)];
cache.X_neg_keys_sup_vec  = [cache.X_neg_keys(sup_vec_neg,:), margin_neg(:)];
cache.X_pos_bbox_sup_vec  = [cache.X_pos_bbox(sup_vec_pos,:), margin_pos(:)];

num_sup_vec_posx = 0;
if ~isempty(cache.X_posx)
    z_posx  = model_weights{1} * cache.X_posx + model_weights{2};
    sup_vec_posx = z_posx <  1.0 + eps;
    margin_posx =  1 * z_posx(sup_vec_posx);
    cache.X_posx_bbox_sup_vec = [cache.X_posx_bbox(sup_vec_posx,:), margin_posx(:)];
    cache.X_posx_keys_sup_vec = [cache.X_posx_keys(sup_vec_posx,:), margin_posx(:)];
    num_sup_vec_posx = sum(sup_vec_posx);
end

fprintf('Support vectors: %d positive %d negative %d extra positives\n',...
     sum(sup_vec_neg), sum(sup_vec_pos), num_sup_vec_posx);
end

function save_cache(cache, filename, img_idx, hard_epoch)
	cache.X_pos = single([]);
	cache.X_neg = single([]);
	cache.X_posx = single([]);
	if ~isempty(cache.X_neg_feat_new) || ~isempty(cache.X_posx_feat_new)
		cache.X_neg_feat_new = {}; 
		cache.X_posx_feat_new = {};
		warning('You should flush the cache before you save it');
	end
	save(filename, 'cache', 'img_idx', 'hard_epoch','-v7.3');
end

function [cache, img_idx, hard_epoch] = load_cache(filename)
load(filename, 'cache', 'img_idx', 'hard_epoch');
end

function cache = load_features_of_cache(cache, model, feature_paths, feat_opts)
num_neg = size(cache.X_neg_bbox,1);
if num_neg > 0
    img_ids        = cache.X_neg_bbox(:,end);
    unique_img_ids = unique(img_ids);
    unique_img_ids = sort(unique_img_ids(:),'ascend');
    bbox_per_img   = cell(length(unique_img_ids),1);
    for i = 1:length(unique_img_ids)
        is_this_img = img_ids == unique_img_ids(i);
        bbox_per_img{i} = cache.X_neg_bbox(is_this_img,1:(end-1));
    end
    cache.X_neg  = extract_features_mult_imgs(model, feature_paths(unique_img_ids), bbox_per_img, feat_opts);
end

if isfield(cache, 'X_posx_bbox')
    num_posx = size(cache.X_posx_bbox,1);
    if num_posx > 0
        img_ids = cache.X_posx_bbox(:,end);
        unique_img_ids = unique(img_ids);
        unique_img_ids = sort(unique_img_ids(:),'ascend');
        bbox_per_img = cell(length(unique_img_ids),1);
        for i = 1:length(unique_img_ids)
            is_this_img = img_ids == unique_img_ids(i);
            bbox_per_img{i} = cache.X_posx_bbox(is_this_img,1:(end-1));
        end
        cache.X_posx = extract_features_mult_imgs(model, feature_paths(unique_img_ids), bbox_per_img, feat_opts);
    end
else
    cache.X_posx = single([]);
    cache.X_posx_bbox = single([]);
    cache.X_posx_keys = single([]);
    cache.X_posx_num = 0;
    cache.X_posx_feat_new  = {};
    cache.X_posx_bbox_new  = {};
    cache.X_posx_keys_new  = {};
    cache.X_posx_imgs_new  = [];
    cache.X_posx_num_added = 0;
    cache.evict_thresh_posx = 1.6;
end
end

function model = load_svm_model(filename)
load(filename, 'weights', 'bias');
model = {weights; bias};
end

function save_svm_model(filename, model)
weights = model{1};
bias    = model{2};
save(filename, 'weights', 'bias');
end

function cache = update_svm_model(cache, opts, task_string)
th = tic;

bias_mult = 10;
svm_C = opts.svm_C;
num_pos = size(cache.X_pos,  2);
num_neg = size(cache.X_neg,  2);
num_posx = size(cache.X_posx, 2);
num_samples = num_pos + num_neg + num_posx;
pos_loss_weight = opts.pos_loss_weight;

if pos_loss_weight <= 0
    w1 = num_samples/(2 * num_pos);
    w2 = num_samples/(2 * num_neg);
    pos_loss_weight = w1 / w2;
    svm_C = svm_C * w2;
end

if num_posx == 0
    X = sparse(double([cache.X_pos, cache.X_neg]));
else
    X = sparse(double([cache.X_pos, cache.X_neg, cache.X_posx]));
end
y = cat(1, ones(num_pos,1), -ones(num_neg,1), ones(num_posx,1));

liblinear_type = 3;  % l2 regularized l1 hinge loss
if svm_C > 10
    liblinear_type = 2;
end
ll_opts = sprintf('-w1 %.15f -c %.15f -s %d -B %.5f', pos_loss_weight, svm_C, liblinear_type, bias_mult);

fprintf('liblinear opts: %s\n', ll_opts);

llm = liblinear_train(y, X, ll_opts, 'col');
weights = single(llm.w(1:end-1)')';
bias    = single(llm.w(end)*bias_mult);
weights = weights(:)';

z_pos     = weights * cache.X_pos + bias;
z_neg     = weights * cache.X_neg + bias;
reg_loss  = 0.5 * (llm.w*llm.w');
pos_loss  = sum(svm_C * pos_loss_weight * max(0, 1 - z_pos));
neg_loss  = sum(svm_C * max(0, 1 + z_neg));
posx_loss = 0;
if num_posx > 0
    z_posx = weights * cache.X_posx + bias;
    posx_loss = sum(svm_C * pos_loss_weight * max(0, 1 - z_posx));
end
total_loss = reg_loss + pos_loss + neg_loss + posx_loss;

fprintf('%s:: #%d Pos #%d Neg #%d Pox-x - C %.5f:: Training time   %.3fs\n', ...
    task_string, num_pos, num_neg, num_posx, svm_C, toc(th));
fprintf('pos_loss_weight  = %.4f\n', pos_loss_weight);
fprintf('pos_loss   = %.10f\n', pos_loss);
fprintf('neg_loss   = %.10f\n', neg_loss);
fprintf('posx_loss  = %.10f\n', posx_loss);
fprintf('reg_loss   = %.10f\n', reg_loss);
fprintf('total_loss = %.10f\n', total_loss);

% easy negatives
easy = find(z_neg < cache.evict_thresh);
cache.X_neg(:, easy) = [];
cache.X_neg_bbox(easy, :) = [];
cache.X_neg_keys(easy, :) = [];
fprintf('Removed negative features %d / %d\n', numel(easy), numel(z_neg));

if num_posx > 0
    % easy differences
    easy = find(z_posx(:) > cache.evict_thresh_posx);
    cache.X_posx(:, easy) = [];
    cache.X_posx_bbox(easy, :) = [];
    cache.X_posx_keys(easy, :) = [];
    fprintf('Removed extra positive features %d / %d\n', numel(easy), numel(z_posx));
    
end

cache.reg_loss   = reg_loss;
cache.pos_loss   = pos_loss;
cache.neg_loss   = neg_loss;
cache.posx_loss  = posx_loss;
cache.total_loss = total_loss;

cache.model_weights = {weights, bias};

end

function extract_and_save_features(model, in_feature_paths, all_bbox, feat_opts, save_file, all_keys)

if ~exist(save_file, 'file')
    [X_feat, X_feat_bbox] = extract_features_mult_imgs(model, in_feature_paths, all_bbox, feat_opts);
    save_features_file(save_file, X_feat, X_feat_bbox);
end

end

function [X_feat, X_feat_bbox] = read_mult_feature_files(save_files)

if ischar(save_files), save_files = {save_files}; end
num_files = numel(save_files);

if num_files == 1
    [X_feat, X_feat_bbox] = read_features_file(save_files{1});
else
    X_feat      = cell(num_files,1);
    X_feat_bbox = cell(num_files,1);
    for f = 1:num_files
        [X_feat{f}, X_feat_bbox{f}] = read_features_file(save_files{f});
    end
    [X_feat, X_feat_bbox] = mergeBBoxFeatures( X_feat, X_feat_bbox );
end
end

function [X_feat, X_feat_bbox] = read_features_file(filename)
load(filename, 'X_feat', 'X_feat_bbox');
end

function save_features_file(filename, X_feat, X_feat_bbox)
save(filename, 'X_feat', 'X_feat_bbox', '-v7.3');
end

function [all_bbox_pos, all_keys_pos] = seperate_positive_bboxes(all_bbox_gt, num_classes, use_hard_pos)

num_imgs      = numel(all_bbox_gt);
all_bbox_pos  = cell(num_classes, 1);
all_keys_pos  = cell(num_classes, 1);
for class_idx = 1:num_classes
    all_bbox_pos{class_idx} = cell(num_imgs, 1);
    for img_idx = 1:num_imgs
        if ~use_hard_pos
            gt_idx  = find(all_bbox_gt{img_idx}(:,5) == class_idx & all_bbox_gt{img_idx}(:,6) == 0); 
        else
            gt_idx  = find(all_bbox_gt{img_idx}(:,5) == class_idx); 
        end
        all_bbox_pos{class_idx}{img_idx} = single(all_bbox_gt{img_idx}(gt_idx,1:4));
        all_keys_pos{class_idx}{img_idx} = single(gt_idx(:));
%         all_keys_pos{class_idx}{img_idx} = [single(gt_idx(:)), img_idx * ones(numel(gt_idx), 1,'single')];
    end
end
end

function cache = init_cache(X_pos, X_pos_bbox)
% ------------------------------------------------------------------------
cache.X_pos         = X_pos;
cache.X_pos_bbox    = X_pos_bbox;

cache.X_posx         = single([]);
cache.X_posx_bbox    = single([]);
cache.X_posx_keys    = single([]);
cache.X_posx_num     = 0;

cache.X_posx_feat_new  = {};
cache.X_posx_bbox_new  = {};
cache.X_posx_keys_new  = {};
cache.X_posx_imgs_new  = [];
cache.X_posx_num_added = 0;

cache.X_neg         = single([]);
cache.X_neg_bbox    = single([]);
cache.X_neg_keys    = single([]);
cache.X_neg_num     = 0;

cache.X_neg_feat_new  = {};
cache.X_neg_bbox_new  = {};
cache.X_neg_keys_new  = {};
cache.X_neg_imgs_new  = [];
cache.X_neg_num_added = 0;

cache.X_feat_num_added = 0;

cache.retrain_limit = 2000;
cache.evict_thresh = -1.2;
cache.evict_thresh_posx = 1.6;
end

function cache = add_neg_to_cache(cache, bbox_mined, keys_mined, features, img_idx)
assert(size(bbox_mined,1) == size(keys_mined,1));

unique_idx = cache_find_new_unique_entries(bbox_mined, cache.X_neg_bbox, img_idx);

num_new_bbox = size(bbox_mined,1);
if num_new_bbox > 0 && ~isempty(unique_idx)
    bbox_mined = bbox_mined(unique_idx,:);
    keys_mined = keys_mined(unique_idx,:);
    num_new_bbox = size(bbox_mined,1);
    
    cache.X_neg_bbox_new{end+1} = single(bbox_mined);
    cache.X_neg_keys_new{end+1} = single(keys_mined);
    cache.X_neg_feat_new{end+1} = single(features(:,keys_mined));
    cache.X_neg_imgs_new(end+1) = img_idx;
    cache.X_neg_num_added       = cache.X_neg_num_added + num_new_bbox;
end
end

function unique_idx = cache_find_new_unique_entries(new_keys, old_keys, img_idx)
unique_idx = 1:size(new_keys,1);
if ~isempty(old_keys) && ~isempty(new_keys)
    assert(size(old_keys,2) == (size(new_keys,2) + 1));
    is_of_this_img = old_keys(:,end) == img_idx;
    if any(is_of_this_img)
        old_keys = old_keys(is_of_this_img,1:(end-1));
        keys = [new_keys; old_keys];
        [~, unique_idx] = unique(keys, 'rows', 'stable');
        unique_idx = unique_idx(unique_idx <= size(new_keys,1));    
    end
end
end

function cache = flush_cache(cache)

% add image idx
for i = 1:length(cache.X_neg_keys_new)
    img_idx = cache.X_neg_imgs_new(i);
    cache.X_neg_keys_new{i} = [cache.X_neg_keys_new{i}, ...
        img_idx * ones(size(cache.X_neg_keys_new{i},1), 1, 'single')];

    cache.X_neg_bbox_new{i} = [cache.X_neg_bbox_new{i}, ...
        img_idx * ones(size(cache.X_neg_bbox_new{i},1), 1, 'single')];     
end

cache.X_neg_bbox = cat(1, cache.X_neg_bbox, cell2mat(cache.X_neg_bbox_new(:)));
cache.X_neg_keys = cat(1, cache.X_neg_keys, cell2mat(cache.X_neg_keys_new(:)));
cache.X_neg      = cat(2, cache.X_neg,      cell2mat(cache.X_neg_feat_new(:)'));

cache.X_neg_num_added = 0;
cache.X_neg_imgs_new = [];
cache.X_neg_bbox_new = {};
cache.X_neg_keys_new = {};
cache.X_neg_feat_new = {};

for i = 1:length(cache.X_posx_keys_new)
    img_idx = cache.X_posx_imgs_new(i);
    cache.X_posx_keys_new{i} = [cache.X_posx_keys_new{i}, ...
        img_idx * ones(size(cache.X_posx_keys_new{i},1), 1, 'single')];

    cache.X_posx_bbox_new{i} = [cache.X_posx_bbox_new{i}, ...
        img_idx * ones(size(cache.X_posx_bbox_new{i},1), 1, 'single')];
end

cache.X_posx_bbox = cat(1, cache.X_posx_bbox, cell2mat(cache.X_posx_bbox_new(:)));
cache.X_posx_keys = cat(1, cache.X_posx_keys, cell2mat(cache.X_posx_keys_new(:)));
cache.X_posx      = cat(2, cache.X_posx,      cell2mat(cache.X_posx_feat_new(:)'));

cache.X_posx_num_added = 0;
cache.X_posx_imgs_new  = [];
cache.X_posx_bbox_new  = {};
cache.X_posx_keys_new  = {};
cache.X_posx_feat_new  = {};

end

function opts = parse_training_opts(opts, all_classes, feat_norm_mean, feat_blob_name)
if isempty(opts.train_classes), opts.train_classes = all_classes; end
if ~exist(opts.exp_dir,'dir'), mkdir_if_missing(opts.exp_dir); end
opts.exp_dir = [opts.exp_dir, filesep];
opts.all_classes = all_classes;
class_indices = str_indices( opts.train_classes, all_classes );
class_indices = unique(class_indices);
assert(all(class_indices~=0))
class_indices = class_indices(:)';
opts.class_indices = class_indices;

% FEATURE OPTIONS
feat_opts                = struct;
feat_opts.feat_blob_name = feat_blob_name;
feat_opts.feat_norm_mean = feat_norm_mean;

% HARD NEGATIVE MINING OPTIONS
neg_opts = struct;
neg_opts.neg_overlap_thr = opts.neg_overlap_thr;

neg_opts.num_negs_per_img = -1;
neg_opts.hardneg_nms_overlap = -1;
neg_opts.min_neg_score = -1.0001;

if neg_opts.neg_overlap_thr == 0.3
    neg_opts.suffix = '';
else
    neg_opts.suffix = sprintf('_NegOver%.2f_', neg_opts.neg_overlap_thr);
end

opts.neg_opts = neg_opts;
opts.feat_opts = feat_opts;
opts = create_model_paths(opts);
fprintf('Options:\n');
disp(opts);
fprintf('Negative mining options:\n');
disp(opts.neg_opts);
fprintf('Feature options:\n');
disp(opts.feat_opts);
end

function opts = create_model_paths(opts)

model_directories_per_epoch = cell(opts.max_epochs,1);
filepath_model_per_epoch = cell(opts.max_epochs,1);
filepath_model_cache_per_epoch = cell(opts.max_epochs,1);

if opts.use_gt_for_neg
    use_gt_for_neg_suffix = '';
else
    use_gt_for_neg_suffix = '_no_gt_for_neg';
end 

for hard_epoch = 1:opts.max_epochs
    model_directory = fullfile(opts.exp_dir, filesep, ...
        sprintf('%sOnline_Hard_Negative%d%s%s_svmC%.7f_pos_loss%.3f_Models_liblinear%s/', ...
        opts.prefix, hard_epoch, opts.neg_opts.suffix, ...
        use_gt_for_neg_suffix, opts.svm_C, opts.pos_loss_weight));

    mkdir_if_missing(model_directory);
    fprintf('%s\n',model_directory);
    
    filepath_model       = fullfile(model_directory, '%s_model.mat');
    filepath_model_cache = fullfile(model_directory, '%s_model_cache.mat');
    model_directories_per_epoch{hard_epoch}    = model_directory;
    filepath_model_per_epoch{hard_epoch}       = filepath_model;
    filepath_model_cache_per_epoch{hard_epoch} = filepath_model_cache;
end
opts.model_directories_per_epoch    = model_directories_per_epoch;
opts.filepath_model_per_epoch       = filepath_model_per_epoch;
opts.filepath_model_cache_per_epoch = filepath_model_cache_per_epoch;

end

function class_indices = find_missing_models(opts, class_names, class_indices)
filepath_model = opts.filepath_model_per_epoch{opts.max_epochs};
does_exist = zeros(numel(class_indices),1);
for c = 1:numel(class_indices)
    save_model_file = sprintf(filepath_model, [class_names{class_indices(c)}, '_all']);
    if ~opts.force && exist(save_model_file,'file'), does_exist(c) = 1; end
end
class_indices = class_indices(~does_exist);
end

function do_training(model, image_paths, in_feature_paths, ...
    all_bbox_gt, all_bbox_proposals, opts, class_indices)
all_classes = opts.all_classes;
num_classes = length(all_classes);
feat_opts = opts.feat_opts;

model.detectors.W = [];
model.detectors.B = [];

cache = cell(num_classes, 1);
num_updates = zeros(num_classes, 1);

% extract ground truth positives
% collect the positive features and write them to a file
fprintf('Extract and save positive features... \n');
filepath_positives = [opts.exp_dir,  '%s_positives.mat'];
[all_pos_bbox, all_keys_pos] = seperate_positive_bboxes(all_bbox_gt, num_classes, opts.use_hard_pos);
for class_idx = 1:num_classes
    fprintf('Class %s:: extract positives\n', all_classes{class_idx})
    save_pos_file = sprintf(filepath_positives, [all_classes{class_idx}, '_all']);
    extract_and_save_features(model, in_feature_paths, ...
        all_pos_bbox{class_idx}, feat_opts, save_pos_file, all_keys_pos{class_idx});
    [X_pos, X_pos_bbox] = read_mult_feature_files(save_pos_file);
    cache{class_idx} = init_cache(X_pos, X_pos_bbox);
    clear X_pos;
    clear X_pos_bbox
end

is_first_time = true;
num_images = length(in_feature_paths);
total_el_time = 0;
mAP = 0;
mAP_i = 0;
for hard_epoch = 1:opts.max_epochs
    model_directory = opts.model_directories_per_epoch{hard_epoch};
    fprintf('%s\n',model_directory);
    mkdir_if_missing(model_directory);
    
    try % try to load last saved progress
        [cache, first_img, model] = load_cache_from_saved_checkpoint(...
            model, cache, in_feature_paths, opts, hard_epoch, '_in_progress');
        is_first_time = false;
    catch exception
        fprintf('Exception message %s\n', getReport(exception));
        first_img = 1;
    end
    
    % add negatives from ground truth and train
    if opts.use_gt_for_neg && hard_epoch == 1 && first_img == 1
        for class_idx = class_indices
            fprintf('****************** Update %d class %s ********************\n', ...
                num_updates(class_idx), all_classes{class_idx});
            cache = add_negatives_from_ground_truth(cache, class_idx, all_bbox_gt, opts.neg_opts);
            cache{class_idx} = update_svm_model(cache{class_idx}, opts, all_classes{class_idx});

            if isempty(model.detectors.W) || isempty(model.detectors.B)
                model.detectors.W = zeros(num_classes, length(cache{class_idx}.model_weights{1}),'single');
                model.detectors.B = zeros(num_classes, 1,'single');
            end

            model.detectors.W(class_idx, :) = cache{class_idx}.model_weights{1};
            model.detectors.B(class_idx, 1) = cache{class_idx}.model_weights{2};

            num_updates(class_idx) = num_updates(class_idx) + 1;
        end
        is_first_time = false;
    end
    
    aboxes = cell(num_classes,1);
    for class_idx = 1:num_classes, aboxes{class_idx} = cell(num_images, 1); end;
    
    for img_idx = first_img:num_images
        th = tic;
        fprintf('%s: hard_epoch %d/%d | image %d/%d | ', procid(), hard_epoch, opts.max_epochs, img_idx, num_images)
        bbox_pool     = all_bbox_proposals{img_idx}; % pool of bounding boxes
        bbox_gt       = all_bbox_gt{img_idx}(:,1:4); % ground truth bounding boxes
        bbox_gt_class = all_bbox_gt{img_idx}(:,5:6); % class label of ground truth bounding boxes
        
        [features, bbox_pool] = get_uniq_img_features(model, in_feature_paths{img_idx}, bbox_pool, feat_opts);
        
        assert(size(features,2) == size(bbox_pool,1));
        if is_first_time
            bbox_scores = [];
        else
            bbox_scores = score_features_with_svm( model, features);
            bbox_scores = bbox_scores{1};
        end
        
        if ~isempty(bbox_scores)
            for class_idx = class_indices
                aboxes{class_idx}{img_idx} = post_process_bboxes(bbox_pool, bbox_scores(:,class_idx), -1.5, 0.3, 100);
            end
        end
        
        opts.neg_opts.do_random = is_first_time; 
        opts.pos_opts.do_random = is_first_time; 
        [bbox_mined_neg, keys_mined_neg] = mine_negative_bboxes(model, bbox_gt, bbox_gt_class(:,1), bbox_pool, bbox_scores, opts.neg_opts );
        
        is_check_point = mod(img_idx, 500) == 0;
        for class_idx = class_indices
            cache{class_idx} = add_neg_to_cache(cache{class_idx}, bbox_mined_neg{class_idx}, keys_mined_neg{class_idx}, features, img_idx);
 
            cache{class_idx}.X_feat_num_added = cache{class_idx}.X_neg_num_added + cache{class_idx}.X_posx_num_added;
            if (cache{class_idx}.X_feat_num_added > cache{class_idx}.retrain_limit ||...
                    img_idx == num_images || is_check_point || is_first_time)
                if cache{class_idx}.X_feat_num_added > 0
                    fprintf('****************** Update %d class %s ********************\n', ...
                        num_updates(class_idx), all_classes{class_idx});
                    fprintf('Options:\n');
                    disp(opts);
                    fprintf('Added features: %d negatives %d positives %d Total\n', ...
                        cache{class_idx}.X_neg_num_added, cache{class_idx}.X_posx_num_added, cache{class_idx}.X_feat_num_added);
                    
                    num_updates(class_idx) = num_updates(class_idx) + 1;
                    cache{class_idx} = flush_cache(cache{class_idx});
                    cache{class_idx} = update_svm_model(cache{class_idx}, opts, all_classes{class_idx});
                    
                    if isempty(model.detectors.W) || isempty(model.detectors.B)
                        model.detectors.W = zeros(num_classes, length(cache{class_idx}.model_weights{1}),'single');
                        model.detectors.B = zeros(num_classes, 1,'single');
                    end
                    
                    model.detectors.W(class_idx, :) = cache{class_idx}.model_weights{1};
                    model.detectors.B(class_idx, 1) = cache{class_idx}.model_weights{2};
                end
            end
        end
        
        if is_check_point || img_idx == num_images 
            for class_idx = class_indices % save progress
                save_model_file_cache = sprintf(opts.filepath_model_cache_per_epoch{hard_epoch}, [all_classes{class_idx}, '_in_progress']);
                cache{class_idx} = find_support_vectors(cache{class_idx});
                save_cache(cache{class_idx}, save_model_file_cache, img_idx, hard_epoch);
            end
            % display mAP
            mAP   = display_mAP(aboxes, first_img, img_idx, all_classes, all_bbox_gt );
            mAP_i = img_idx;
        end
        is_first_time = false;
        
        elapsed_time    = toc(th);
        [total_el_time, ~, est_rem_time] = timing_process(elapsed_time, total_el_time, first_img, img_idx, num_images);
        fprintf(' time: %.3fs | total time %.4fmin | est. remaining time %.4fmin | mAP[%d~%d] = %.4f\n', ...
            elapsed_time, total_el_time/60, est_rem_time/60, first_img, mAP_i, mAP);
    end
        
    for class_idx = class_indices
        model_weights = {model.detectors.W(class_idx, :), model.detectors.B(class_idx, :)};
        save_model_file = sprintf(opts.filepath_model_per_epoch{hard_epoch}, [all_classes{class_idx}, '_all']);
        save_svm_model(save_model_file, model_weights);

        save_model_file_cache = sprintf(opts.filepath_model_cache_per_epoch{hard_epoch}, [all_classes{class_idx}, '_finished']);
        cache{class_idx} = find_support_vectors(cache{class_idx});
        save_cache(cache{class_idx}, save_model_file_cache, img_idx, hard_epoch);
    end
end

end

function [ scores ] = score_features_with_svm(model, feat)

num_detectors = length(model.detectors);
scores        = cell(num_detectors, 1);
for d = 1:num_detectors
    scores{d}  = bsxfun(@plus, (model.detectors(d).W * feat), model.detectors(d).B)';
end

end

function mAP = display_mAP(aboxes, first_img, img_idx, all_classes, all_bbox_gt )
aboxes      = cellfun(@(x) x(first_img:img_idx), aboxes, 'UniformOutput', false);
mAP_result  = evaluate_average_precision_pascal( all_bbox_gt(first_img:img_idx), aboxes, all_classes );
printAPResults(all_classes, mAP_result);
mAP         = mean([mAP_result(:).ap]');
end

function [features, bbox_pool] = get_uniq_img_features(model, in_feature_path, bbox_pool, feat_opts)
feat_data       = read_feat_conv_data( in_feature_path );

features        = extract_features( model, feat_data.feat, bbox_pool, feat_opts.feat_blob_name );

[~, unique_ids] = unique(features', 'rows', 'stable');
features        = features(:,unique_ids);
bbox_pool       = bbox_pool(unique_ids,:);
features        = scale_features(features, feat_opts.feat_norm_mean);
end

function cache = add_negatives_from_ground_truth(cache, class_idx, all_bbox_gt, neg_opts)
num_classes = length(cache);
for c = 1:num_classes
    if class_idx ~= c
        num_bbox = size(cache{c}.X_pos_bbox,1);
        keep = true(num_bbox,1);
        for j = 1:num_bbox
            img_idx = cache{c}.X_pos_bbox(j,end);
            bbox_gt = all_bbox_gt{img_idx}(all_bbox_gt{img_idx}(:,5)==class_idx,1:4); % ground truth bounding boxes
            if ~isempty(bbox_gt)
                overlap = boxoverlap(bbox_gt, cache{c}.X_pos_bbox(j,1:4));
                keep(j) = max(overlap) <= neg_opts.neg_overlap_thr;
            end
        end
        cache{class_idx}.X_neg      = cat(2, cache{class_idx}.X_neg,      cache{c}.X_pos(:,keep));
        cache{class_idx}.X_neg_bbox = cat(1, cache{class_idx}.X_neg_bbox, cache{c}.X_pos_bbox(keep,:));
        num_bbox = sum(keep);
        cache{class_idx}.X_neg_keys = cat(1, cache{class_idx}.X_neg_keys, single([-1*ones(num_bbox,1,'single'), cache{c}.X_pos_bbox(keep,5)]));
    end
end
end

function [cache, first_img, model] = load_cache_from_saved_checkpoint(...
    model, cache, in_feature_paths, opts, hard_epoch, suffix)

all_classes   = opts.all_classes;
num_classes   = length(all_classes);
feat_opts     = opts.feat_opts;
num_images    = length(in_feature_paths);
class_indices = opts.class_indices;

c = 0;
img_idx_per_class = zeros(length(class_indices),1);
for class_idx = class_indices
    c = c + 1;
    save_model_file_cache = sprintf(opts.filepath_model_cache_per_epoch{hard_epoch}, [all_classes{class_idx}, suffix]);
    [lcache, img_idx_, hard_epoch_] = load_cache(save_model_file_cache);
    img_idx_per_class(c) = img_idx_;
    assert(hard_epoch_ == hard_epoch);
    assert(img_idx_ <= num_images);
    lcache.X_pos      = cache{class_idx}.X_pos;
    lcache.X_pos_bbox = cache{class_idx}.X_pos_bbox;
    cache{class_idx}  = lcache;
    cache{class_idx}  = load_features_of_cache(cache{class_idx}, model, in_feature_paths, feat_opts);
    if isempty(model.detectors.W) || isempty(model.detectors.B)
        model.detectors.W = zeros(num_classes, length(cache{class_idx}.model_weights{1}),'single');
        model.detectors.B = zeros(num_classes, 1,'single');
    end
    model.detectors.W(class_idx, :) = cache{class_idx}.model_weights{1};
    model.detectors.B(class_idx, 1) = cache{class_idx}.model_weights{2};
end
assert(all(img_idx_per_class(1) == img_idx_per_class));
first_img = img_idx_per_class(1) + 1;

end

function [bbox_dets, indices] = post_process_bboxes(boxes, scores, score_thresh, nms_over_thrs, max_per_image)
indices = find(scores > score_thresh);
keep    = nms(cat(2, single(boxes(indices,:)), single(scores(indices))), nms_over_thrs);
indices = indices(keep);
if ~isempty(indices)
    [~, order] = sort(scores(indices), 'descend');
    order      = order(1:min(length(order), max_per_image));
    indices    = indices(order);
    boxes      = boxes(indices,:);
    scores     = scores(indices);
    bbox_dets   = cat(2, single(boxes), single(scores));
else
    bbox_dets   = zeros(0, 5, 'single');
end
end

function [bboxes, bbox_indices] = mine_negative_bboxes(spp_model, bbox_gt, bbox_gt_class, all_bbox, all_scores, opts )
assert(size(bbox_gt,1) == size(bbox_gt_class,1));

if ~isfield(opts, 'type')
    assert(isfield(opts, 'do_random'));
    if opts.do_random
        opts.type = 'random';
    else
        opts.type = 'hard_negatives';
    end
end

num_classes    = numel(spp_model.classes);

switch opts.type
    case 'random'
        bbox_indices = random_negatives(all_bbox, bbox_gt, bbox_gt_class, ...
            num_classes, opts.neg_overlap_thr, opts.num_negs_per_img);
    case 'hard_negatives'
        % mine hard negatives for each class
        assert(exist('all_scores','var') && ~isempty(all_scores));
        assert(size(all_scores,1) == size(all_bbox,1));
        assert(size(all_scores,2) == num_classes);
        bbox_indices = hard_negatives(all_scores, all_bbox, bbox_gt, bbox_gt_class, ...
            num_classes, opts.neg_overlap_thr, opts.min_neg_score, opts.num_negs_per_img, opts.hardneg_nms_overlap);
end

bboxes = cell(num_classes,1);
for class_idx = 1:numel(spp_model.classes)
    if ~isempty(bbox_indices{class_idx})
        bboxes{class_idx} = all_bbox(bbox_indices{class_idx},:);
        bbox_indices{class_idx} = bbox_indices{class_idx}(:);
    else
        bboxes{class_idx} = zeros(0,4,'single');
    end
end

end

function all_bbox_indices = hard_negatives(all_scores, all_bbox, bbox_gt, bbox_gt_class, num_classes, neg_overlap_thr, min_neg_score, num_negs_per_img, nms_overlap)
all_bbox_indices = cell(num_classes,1);

if ~exist('nms_overlap', 'var') && (nms_overlap>0 && nms_overlap<=1)
    do_nms = true;
else
    do_nms = false;
end

if num_negs_per_img < 0
    num_negs_per_img = size(all_bbox, 1);
end

for class_idx = 1:num_classes
    % select the bounding boxes that are not negative enough and
    % that dont overlap with the ground truth more than 0.3
    [~, overlap_val ] = bboxAssignToGroundTruth( all_bbox, bbox_gt(bbox_gt_class==class_idx,:));
    keep_idx          = (overlap_val <= neg_overlap_thr) & (all_scores(:,class_idx) > min_neg_score);
    bbox_indices      = single(1:size(all_bbox,1));
    bbox_indices      = bbox_indices(keep_idx);
    
    if ~isempty(bbox_indices)
        if do_nms
            keep_idx     = nms(single([all_bbox(bbox_indices,:), all_scores(bbox_indices,class_idx)]), nms_overlap);
            bbox_indices = bbox_indices(keep_idx);
        end
        [~, order_indeces]          = sort(all_scores(bbox_indices,class_idx), 'descend'); % from positive scores to negative ones
        num_extra_bbox              = min( numel(bbox_indices), num_negs_per_img);
        all_bbox_indices{class_idx} = sort(bbox_indices(order_indeces(1:num_extra_bbox)), 'ascend');
    end
end
end

function all_bbox_indices = random_negatives(all_bbox, bbox_gt, bbox_gt_class, num_classes, neg_overlap_thr, num_negs_per_img)
all_bbox_indices = cell(num_classes,1);

if num_negs_per_img < 0
    num_negs_per_img = size(all_bbox, 1);
end

for class_idx = 1:num_classes
    % select random bounding boxes that dont overlap with the gt more than
    % 0.3
    [~, overlap_val ] = bboxAssignToGroundTruth( all_bbox, bbox_gt(bbox_gt_class==class_idx,:) );
    keep_idx          = (overlap_val <= neg_overlap_thr);
    bbox_indices      = single(1:size(all_bbox,1));
    bbox_indices      = bbox_indices(keep_idx);
   
    if ~isempty(bbox_indices)
        order_indeces               = randperm(numel(bbox_indices));
        num_extra_bbox              = min( numel(bbox_indices), num_negs_per_img);
        all_bbox_indices{class_idx} = sort(bbox_indices(order_indeces(1:num_extra_bbox)), 'ascend');
    end
end
end

function [total_el_time, ave_time, est_rem_time] = timing_process(...
    elapsed_time, total_el_time, fist_img_idx, i, num_imgs)

total_el_time   = total_el_time + elapsed_time;
ave_time        = total_el_time / (i-fist_img_idx+1);
est_rem_time    = ave_time * (num_imgs - i);
end

function [mean_norm, stdd] = compute_feature_stats(model, ...
    image_paths, feature_paths, all_bbox, stats_dir, stats_suffix)

if ~exist('stats_dir', 'var') || isempty(stats_dir)
    stats_dir = model.cache_dir; 
end

if ~exist('stats_suffix', 'var') || isempty(stats_suffix)
    stats_suffix = ''; 
end

fprintf('stats_dir = %s\n', stats_dir);

layer = model.feat_blob_name;
layer_str = layer{1};
for i = 2:length(layer), layer_str = [layer_str, '_', layer{i}]; end

save_file = sprintf('%s/feature_stats_layer_%s%s.mat', stats_dir, layer_str, stats_suffix);

t_start = tic();
try
    ld        = load(save_file);
    mean_norm = ld.mean_norm;
    stdd      = ld.stdd;
    clear ld;
catch
    % fix the random seed for repeatability
    prev_rng        = seed_rand();

    num_images      = min(length(image_paths), 200);
    boxes_per_image = 200;
    valid_idx       = randperm(length(image_paths), num_images);

    ns = [];
    for i = 1:length(valid_idx)
        image_idx = valid_idx(i);
        tic_toc_print('feature stats: %d/%d\n', i, length(valid_idx));
        bbox       = all_bbox{image_idx}(:,1:4);
        keep       = randperm(size(bbox,1), min(boxes_per_image, size(bbox,1)));
        bbox       = bbox(keep,:); 

        feat_data  = read_feat_conv_data( feature_paths{image_idx} );
        features   = extract_features( model, feat_data.feat, bbox, model.feat_blob_name );
        
        ns         = cat(2, ns, sqrt(sum(features.^2, 1)));
    end

    mean_norm = mean(ns);
    stdd      = std(ns);

    save(save_file, 'mean_norm', 'stdd');

    % restore previous rng
    rng(prev_rng);
end
fprintf('Feat mean norm = %f\n', mean_norm);
fprintf('Feat stdd norm = %f\n', stdd);
fprintf('compute_feature_stats in %f seconds.\n', toc(t_start));
end

function feats = scale_features(feats, feat_norm_mean)
% My initial experiments were conducted on features with an average norm
% very close to 20. Using those features, I determined a good range of SVM
% C values to cross-validate over. Features from different layers end up
% have very different norms. We rescale all features to have an average norm
% of 20 (why 20? simply so that I can use the range of C values found in my 
% initial experiments), to make the same search range for C reasonable 
% regardless of whether these are pool5, fc6, or fc7 features. This strategy
% seems to work well. In practice, the optimal value for C ends up being the
% same across all features.
target_norm = 20;
feats = feats .* (target_norm / feat_norm_mean);
end


function [X_feat, X_bboxes] = extract_features_mult_imgs(model, in_feat_path, bboxes, opts)

t_start    = tic();
num_imgs   = length(in_feat_path);
nLoadEach  = 3000; % load n images in each parfor
num_turns  = ceil(num_imgs / nLoadEach);
totalImIdx = 0;

X_feat   = cell(num_turns,1);
X_bboxes = cell(num_turns,1);

num_streams = length(model.pooler);

for iturn = 1:num_turns
    t_turn  = tic();
    
    i_start = (iturn - 1) * nLoadEach + 1;
    i_end   = min(iturn * nLoadEach, num_imgs);
    i_num   = i_end - i_start + 1;

    X_feat_sub  = cell(i_num, num_streams);
    bboxes_sub2 = cell(i_num, 1);
    
    in_feat_path_sub = in_feat_path(i_start:i_end);
    bboxes_sub       = bboxes(i_start:i_end);
    pooler           = model.pooler;
   
    parfor (i = 1:i_num)
        if size(bboxes_sub{i},1) == 0, continue; end   
        in_feat_data    = read_feat_conv_data(in_feat_path_sub{i});
        X_feat_sub(i,:) = convFeat_to_poolFeat_multi_region(pooler, in_feat_data.feat, bboxes_sub{i}(:,1:4));
        bboxes_sub2{i}  = [bboxes_sub{i}, ones(size(bboxes_sub{i},1),1,'single') * (i + i_start - 1)];
    end
    
    valid = cellfun(@(x) ~isempty(x), X_feat_sub(:,1),  'UniformOutput', true);
    X_feat_sub_stream = cell(num_streams, 1);
    for s = 1:num_streams 
        assert(all(cellfun(@(x) ~isempty(x), X_feat_sub(:,s),  'UniformOutput', true) == valid));
        X_feat_sub_stream{s} = cell2mat(X_feat_sub(valid,s)');
    end
    
    if isfield(model, 'net')
        [outputs, out_blob_names_total] = caffe_forward_net(model.net, X_feat_sub_stream, opts.feat_blob_name);
        idx = find(strcmp(out_blob_names_total, opts.feat_blob_name));
        assert(numel(idx) == 1);
        X_feat{iturn} = outputs{idx};
    else
        X_feat{iturn} = cell2mat(X_feat_sub_stream(:));
    end
    
    if isfield(opts, 'feat_norm_mean')
        X_feat{iturn} = scale_features(X_feat{iturn}, opts.feat_norm_mean);
    end

    X_bboxes{iturn} = cell2mat(bboxes_sub2(valid));
    fprintf('Feature extraction:: image %d/%d in %f seconds. \n', i_end, num_imgs, toc(t_turn));

    totalImIdx = totalImIdx + i_num;
end
X_feat   = cell2mat(X_feat');
X_bboxes = cell2mat(X_bboxes);

fprintf('Images %d Features %d Elapsed time %f seconds \n', num_imgs, size(X_feat,2), toc(t_start))
end

function [gt_index, overlap_max] = bboxAssignToGroundTruth(bboxes, bbox_gt)
if isempty(bbox_gt)
    overlap_max = zeros(size(bboxes,1),1,'single');
    gt_index = -ones(size(bboxes,1),1,'single');
else
    [overlap_max, gt_index] = max(boxoverlap(bboxes, bbox_gt),[],2);
    gt_index(overlap_max == 0) = -1;

    overlap_max = single(overlap_max);
    gt_index    = single(gt_index);
end
end

function [ indices ] = str_indices( set_strings1, set_strings2 )
indices = zeros(numel(set_strings1), 1);
for i = 1:numel(set_strings1)
    index = find(strcmp(set_strings2, set_strings1{i}));
    if numel(index) == 1
        indices(i) = index;
    end
end
end