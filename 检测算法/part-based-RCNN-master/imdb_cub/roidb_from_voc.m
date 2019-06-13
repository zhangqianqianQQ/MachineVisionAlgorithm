function roidb = roidb_from_voc(imdb)
% roidb = roidb_from_voc(imdb)
%   Builds an regions of interest database from imdb image
%   database. Uses precomputed selective search boxes available
%   in the R-CNN data package.
%
%   Inspired by Andrea Vedaldi's MKL imdb and roidb code.

% AUTORIGHTS
% ---------------------------------------------------------
% Copyright (c) 2014, Ross Girshick
% 
% This file is part of the R-CNN code and is available 
% under the terms of the Simplified BSD License provided in 
% LICENSE. Please retain this notice and LICENSE if you use 
% this file (or any portion of it) in your project.
% ---------------------------------------------------------
% Change by Ning Zhang

cache_file = ['./imdb/cache/roidb_' imdb.name];
try
  load(cache_file);
catch
  roidb.name = imdb.name;

  fprintf('Loading region proposals...');
  
  regions_file = sprintf('./data/selective_search_data/%s', roidb.name);
  % follow the selective search instructions and run selective search on bird images.
  try 
    regions = load(regions_file);
  catch
    disp('Run selective search on cub2011 images first.');
    exit(-1);
  end
  fprintf('done\n');
  % if config file doesn't exist. run config = get_bird_data;
  load('caches/cub2011_config.mat');
  for i = 1:length(imdb.image_ids)
    tic_toc_print('roidb (%s): %d/%d\n', roidb.name, i, length(imdb.image_ids));
    voc_rec = get_pascal_format(config, imdb.image_ids{i});
    roidb.rois(i) = attach_proposals(voc_rec, regions.boxes{i}, imdb.class_to_id);
  end

  fprintf('Saving roidb to cache...');
  save(cache_file, 'roidb', '-v7.3');
  fprintf('done\n');
end

function voc_rec = get_pascal_format(config, img_path)
  % find image id for img_path
  full_path = [config.img_base img_path];
  train_idx = find(ismember(config.impathtrain, full_path));
  test_idx = find(ismember(config.impathtest, full_path));
  assert(isempth(train_idx) || isempty(test_idx));
  assert(~isempty(train_idx) || ~isempty(test_idx));
  if ~isempty(train_idx)
    voc_rec.object(1).bbox = config.train_box{1}(train_idx,:);
    voc_rec.object(1).class = 'bbox';
    count = 2;
    if config.train_box{2}(train_idx,1) ~= -1
      voc_rec.object(count).bbox = config.train_box{2}(train_idx,:);
      voc_rec.object(count).class = 'head';
      count = count + 1;
    end
    if config.train_box{3}(train_idx,1) ~= -1
      voc_rec.object(count).bbox = config.train_box{3}(train_idx,:);
      voc_rec.object(count).class = 'body';
    end
  end
  if ~isempty(test_idx)
    voc_rec.object(1).bbox = config.test_box{1}(test_idx,:);
    voc_rec.object(1).class = 'bbox';
    count = 2;
    if config.test_box{2}(test_idx,1) ~= -1
      voc_rec.object(count).bbox = config.test_box{2}(test_idx,:);
      voc_rec.object(count).class = 'head';
      count = count + 1;
    end
    if config.test_box{3}(test_idx,1) ~= -1
      voc_rec.object(count).bbox = config.test_box{3}(test_idx,:);
      voc_rec.object(count).class = 'body';
    end
  end 
end 


% ------------------------------------------------------------------------
function rec = attach_proposals(voc_rec, boxes, class_to_id)
% ------------------------------------------------------------------------

% change selective search order from [y1 x1 y2 x2] to [x1 y1 x2 y2]
boxes = boxes(:, [2 1 4 3]);

%           gt: [2108x1 double]
%      overlap: [2108x20 single]
%      dataset: 'voc_2007_trainval'
%        boxes: [2108x4 single]
%         feat: [2108x9216 single]
%        class: [2108x1 uint8]
if isfield(voc_rec, 'objects')
  gt_boxes = cat(1, voc_rec.objects(:).bbox);
  all_boxes = cat(1, gt_boxes, boxes);
  gt_classes = class_to_id.values({voc_rec.objects(:).class});
  gt_classes = cat(1, gt_classes{:});
  num_gt_boxes = size(gt_boxes, 1);
else
  gt_boxes = [];
  all_boxes = boxes;
  gt_classes = [];
  num_gt_boxes = 0;
end
num_boxes = size(boxes, 1);

rec.gt = cat(1, true(num_gt_boxes, 1), false(num_boxes, 1));
rec.overlap = zeros(num_gt_boxes+num_boxes, class_to_id.Count, 'single');
for i = 1:num_gt_boxes
  rec.overlap(:, gt_classes(i)) = ...
      max(rec.overlap(:, gt_classes(i)), boxoverlap(all_boxes, gt_boxes(i, :)));
end
rec.boxes = single(all_boxes);
rec.feat = [];
rec.class = uint8(cat(1, gt_classes, zeros(num_boxes, 1)));
