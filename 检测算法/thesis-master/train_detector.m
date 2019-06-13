% Train SVM detector
init;

net_model = exp_params.net_model;
dataset = exp_params.dataset;

%range = get_norm_factor();
%range = (1/170);
range = 1;

% First, load the positive samples
pos = load(['data/' net_model '/' dataset '/positive.mat']);
num_pos = size(pos.labels, 2);

fid = fopen([VOC07PATH 'ImageSets/Main/' dataset '.txt']);
imgs = textscan(fid, '%s');
imgs = imgs{1};
num_imgs = length(imgs);

pos_features = zeros(num_pos, 4096);
for ii=1:num_pos
    pos_features(ii, :) = pos.features{ii}';
end
pos_labels = cell2mat(pos.labels)';

% Normalize
pos_features = pos_features .* range;

% Initialize the cache
train_cache = cell(20, 1);
for cls=1:20
    pos_index = (pos_labels==cls);
    train_cache{cls}.pos = pos_features(pos_index, :);
    train_cache{cls}.neg = [];
end

pos_weight = 2;
penalty = 0.001;
mode = 1;

% Train for each image
for ii=1:num_imgs
    disp(['Training with data from image: ' imgs{ii} ' ' num2str(ii) '/' num2str(num_imgs)]);
    train_data = load(['data/' net_model '/' dataset '/' imgs{ii} '.mat']);
    num_data = size(train_data.labels, 2);
    data_labels = cell2mat(train_data.labels);
    data_features = zeros(num_data, 4096);
    for jj=1:num_data
        data_features(jj, :) = train_data.features{jj}';
    end
    for cls=1:1
        % Prepare training data
        disp(['Training class: ' VOCCLASS{cls} ' ' num2str(cls) '/20']);
        neg_index = (data_labels == 0);
        neg_features = data_features(neg_index, :);
        neg_features = neg_features .* range;
        
        if isempty(train_cache{cls}.neg)
            train_cache{cls}.neg = neg_features;
        else
            train_cache{cls}.neg = [train_cache{cls}.neg; neg_features];
        end
        
        num_neg = size(train_cache{cls}.neg, 1);
        num_pos = size(train_cache{cls}.pos, 1);
        disp(['Before: pos: ' num2str(num_pos) ' neg: ' num2str(num_neg)]);
        
        train_features = sparse([train_cache{cls}.pos; train_cache{cls}.neg]);
        train_labels = [ones(num_pos, 1); -ones(num_neg, 1)];
        options = ['-w1 ' num2str(pos_weight) ' -c ' num2str(penalty) ' -s ' num2str(mode)];
        model = train(train_labels, train_features, options);
        
        % Evaluate
        scores = model.w * train_features';
        prediction = scores > 0;
        prediction = prediction .* 2 -1;
        prediction = prediction';
        tp = sum(prediction(1:num_pos)==train_labels(1:num_pos));
        tn = sum(prediction(num_pos+1:end)==train_labels(1+num_pos:end));
        disp(['tp ' num2str(tp) '/' num2str(num_pos)]);
        disp(['tn ' num2str(tn) '/' num2str(num_neg)]);
        
        % Update train_cache
        % First shrink the cache
        scores = model.w * train_cache{cls}.neg';
        not_easy_samples = train_cache{cls}.neg(scores > -1, :);
        num_easy = size(train_cache{cls}.neg, 1) - size(not_easy_samples,1);
        train_cache{cls}.neg = not_easy_samples;
        %disp(['Number of easy samples ' num2str(num_easy)]);
        
        num_neg = size(train_cache{cls}.neg, 1);
        num_pos = size(train_cache{cls}.pos, 1);
        disp(['After: pos: ' num2str(num_pos) ' neg: ' num2str(num_neg)]);
        
%         Then grow the cache by adding new hard negative from this dataset
%         scores = model.w * neg_features';
%         hard_samples = neg_features(scores > -1, :);
%         train_cache{cls}.neg = [train_cache{cls}.neg; hard_samples];
%         disp(['Number of hard samples ' num2str(size(hard_samples, 1))]);
        
        % Save the model for every iteration, so it can continue if
        % interrupted
        models{cls} = model;
        save(['svm_models/' net_model '/' dataset '.mat'], 'models', 'range', '-v7.3');
    end
end
