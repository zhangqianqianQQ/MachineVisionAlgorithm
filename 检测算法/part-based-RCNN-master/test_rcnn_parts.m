%% function to run rcnn detections with geometric constaints
%% Three constraints: box, prior and neighbor
%% return boxes which is a cell of N_parts x N_methods 
%% Written by Ning Zhang

function boxes = test_rcnn_parts(part_models, config)

% assume they are all the same
feat_opts = part_models{1}.opts;
% Get or compute the average norm of the features
save_file = 'caches/feat_norm_mean.mat';
try
  ld = load(save_file);
  feat_opts.feat_norm_mean = ld.feat_norm_mean;
  clear ld;
catch
  [feat_norm_mean, stddev] = feat_stats(dataset);
  save(save_file, 'feat_norm_mean', 'stddev');
  feat_opts.feat_norm_mean = feat_norm_mean;
end
fprintf('average norm = %.3f\n', feat_opts.feat_norm_mean);
% ------------------------------------------------------------------------

feat_opts = get_auxilary(config);

boxes = cell(config.N_parts, config.N_methods);
for i = 1 : config.N_parts
  for j  = 1 : config.N_methods
     boxes{i}{j} = -1 * ones(length(config.impathtest), 5);
  end
end

max_per_image = 100;
max_per_set = ceil(100000/2500) * length(config.impathtest);
% TODO are these arbitrary numbers legit?
top_scores = cell(1, config.N_methods);
thresh = -inf(1, config.N_methods);
box_counts = zeros(1, config.N_methods);

% bounding box detector weight and bias
ws = cat(2, cellfun(@(x) x.w, part_models(1), 'UniformOutput', false));
ws = cat(2, ws{:});
bs = cat(2, cellfun(@(x) x.b, part_models(1), 'UniformOutput', false));
bs = cat(2, bs{:});

% part detector weight and bias
wp = cat(2, cellfun(@(x) x.w, part_models(2:end), 'UniformOutput', false));
wp = cat(2, wp{:});
bp = cat(2, cellfun(@(x) x.b, part_models(2:end), 'UniformOutput', false));
bp = cat(2, bp{:});

% TODO fix num_batches
for i = 1 : num_batches
  fprintf('test %d/%d\n', i, num_batches);
  d = load_test_batch_feature(i, config.impathtest, config.test_box{1});
  feat = xform_feat(d.feat, feat_opts);
  zs = bsxfun(@plus, feat*ws, bs);
  zp = bsxfun(@plus, feat*wp, bp);

  ims_b = unique(d.im);
  for ii = 1 : numel(ims_b) % for each image
    img_idx = find(~cellfun('isempty', strfind(impaths,ims_b{ii})));

    % find knn_idx on the fly
    [~, best_root_guess] = max(zs(img_idx,:));
    knn_idx = knnsearch(feat_opts.train_fea, d.feat(best_root_guess,:), 'K', 30);

    I_im = find(strcmp(ims_b{ii}, d.im));
    boxes_ = d.boxes(I_im,:);
    feat_ = d.feat(I_im,:);
    zs_ = zs(I_im,:);
    zs_n = exp(zs_) ./ (1 + exp(zs_));

    zp_n = zeros(length(I_im), length(part_models) - 1);
    for p = 1 : length(part_models) - 1
       zp_n(:,p) = exp(zp(I_im, p)) ./ (1 + exp(zp(I_im, p)));
    end

    scores = repmat(zs_n, 1, config.N_methods);
    scores_idx = zeros(length(zs_), length(part_models) - 1, config.N_methods);
    neighbor_prior = fit_neighbors(knn_idx, feat_opts.X);
    
    parfor k = 1 : length(zs_)
      % fix one root filter
      w = double(boxes_(k,3) - boxes_(k,1));
      h = double(boxes_(k,4) - boxes_(k,2));
      
      % box constraint
      I_p = find(boxes_(:,1) >= boxes_(k,1) - 10 & boxes_(:,2) >= boxes_(k,2)-10 ...
            & boxes_(:,3) <= boxes_(k,3) + 10 & boxes_(:,4) <= boxes_(k,4) + 10);
      zp_ = zp(I_p, :);
      s_idx = scores_idx(k, :, :);
      s_ = scores(k, :);
      for p = 1 : length(part_models) - 1
        [max_p, argmax_p] = max(zp_n(:,p));
        s_(1)= s_(1) * max_p;
        s_idx(1, p, 1) = argmax_p;
      end
      
      % normalize boxes and change the format to [center_x center_y width height]
      n_boxes = double(boxes_(I_p, :)- repmat([boxes_(k, 1) boxes_(k, 2) boxes_(k, 1) boxes_(k, 2)], length(I_p), 1)) ...
                    ./ repmat([w h w h], length(I_p), 1);
      n_boxes = [(n_boxes(:, 1) + n_boxes(:, 3)) / 2 (n_boxes(:, 2) + n_boxes(:, 4)) / 2 ...
                    n_boxes(:, 3) - n_boxes(:, 1)  n_boxes(:, 4) - n_boxes(:, 2)];
      
      % prior constraint
      for p = 1 : length(part_models) - 1
        zz = zp_n(I_p, p) .* (pdf(feat_opts.prior{p}, n_boxes) .^ 0.01);
        [max_p, argmax_p] = max(zz);
        s_(2) = s_(2) * max_p;
        s_idx(1, p, 2) = I_p(argmax_p);
      end

      % neighbor constraint
      for p = 1 : length(part_models) - 1
        zz = zp_n(I_p, p) .* (pdf(neighbor_prior{p}, n_boxes) .^ 0.01);
        [max_p, argmax_p] = max(zz);
        s_(3) = s_(3) * max_p;
        s_idx(1,p,3) = I_p(argmax_p);
      end

      scores_idx(k,:,:) = s_idx;
      scores(k,:) = s_;
  end
  for m = 1 : config.N_methods
    [max_score, argmax] = max(scores(:, m));
    I = find(scores(:, m) > thresh(m)); 
    [~, ord] = sort(scores(I, m), 'descend');
    ord = ord(1 : min(length(ord), max_per_images));
    box_counts(k) = box_counts(k) + length(ord);
    top_scores{k} = cat(1, top_scores{k}, scores(I(ord),k));
    top_scores{k} = sort(top_scores{k}, 'descend');
    if box_counts(k) > max_per_set
      top_scores{k}(max_per_set+1:end) = [];
      thresh(k) = top_scores{k}(end);
    end

    boxes{1}{m}(img_idx, :) = [boxes_(argmax, :) max_score];
    for p = 1 : length(part_models) - 1
      boxes{p+1}{m}(img_idx, :) = [boxes_(scores_idx(argmax, p, m), :) max_score];
    end
  end
end

% filter out detections below thresh and fill with -1
for m = 1 : config.N_methods
  for i = 1 : config.N_parts
    I = find(boxes{i}{m}(:, end) < thresh(m));
    boxes{i}{m}(I,:) = [-1 -1 -1 -1 -1];
    boxes{i}{m} = boxes{i}{m}(:,1:4);
  end
end
end

function d = load_test_batch_feature(batch_id, impaths, gt_pos)
    fea_basis = '/u/vis/x1/nzhang/recurPart/img_fea_whole/fea_test_'; % the path where you extract the deep features
    fea_filename = [fea_basis num2str(batch_id) '.mat'];
    dd = load(fea_filename);
    d.im = dd.fea(:,1);
 
    d.boxes = cell2mat(dd.fea(:,2)')';
    d.feat = cell2mat(dd.fea(:,3)')';

    d.overlap = zeros(numel(d.im),1);
    ims_bb = unique(d.im);
    for ii = 1: numel(ims_bb)
        I = find(strcmp(ims_bb{ii}, d.im));
        image_id = find(~cellfun('isempty', strfind(impaths,ims_bb{ii})));
        bbox_box = gt_pos{image_id};
        d.overlap(I) = boxoverlap(d.boxes(I,:), bbox_box);
    end
end

function [mean_norm, stdd] = feat_stats(dataset)
   num_batches = 10;
   boxes_per_batch = 1000;
   batches = randperm(300,10);
   ns = [];
   for i = 1: num_batches
       d = load_batch_feature(dataset, batches(i));
       X = d.feat(randperm(size(d.feat,1), min(boxes_per_batch, size(d.feat,1))), :);
       ns = cat(1, ns, sqrt(sum(X.^2, 2)));
   end
   mean_norm = mean(ns);
stdd = std(ns);
end

function g = fit_neighbors(idx, X)
for p = 1:numel(X)
    try
      g{p} = gmdistribution.fit(X{p}(idx,:), 2);
    catch
      g{p} = gmdistribution.fit(X{p}(idx,:),1);
    end
end
end
