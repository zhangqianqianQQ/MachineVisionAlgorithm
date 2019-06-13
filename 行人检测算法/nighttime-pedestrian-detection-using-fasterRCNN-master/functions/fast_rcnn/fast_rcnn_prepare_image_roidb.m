function [image_roidb, bbox_means, bbox_stds] = fast_rcnn_prepare_image_roidb(conf, imdbs, roidbs, bbox_means, bbox_stds)
% [image_roidb, bbox_means, bbox_stds] = fast_rcnn_prepare_image_roidb(conf, imdbs, roidbs, cache_img, bbox_means, bbox_stds)
%   Gather useful information from imdb and roidb
%   pre-calculate mean (bbox_means) and std (bbox_stds) of the regression
%   term for normalization
% --------------------------------------------------------
% Fast R-CNN
% Reimplementation based on Python Fast R-CNN (https://github.com/rbgirshick/fast-rcnn)
% Copyright (c) 2015, Shaoqing Ren
% Licensed under The MIT License [see LICENSE for details]
% -------------------------------------------------------- 


    if ~exist('bbox_means', 'var')
        bbox_means = [];
        bbox_stds = [];
    end
    
    for i=1:length(imdbs)
        image_roidb(i) = cellfun(@(x, y) arrayfun(@(z) ...
                struct('imgs', x.image_at(z),'rois',y.rois(z).proposals),...
                [1:length(x.image_ids)]', 'UniformOutput', true),...
                {imdbs(i)}, {roidbs(i)}, 'UniformOutput', false);
    end
    image_roidb = cat(1, image_roidb{:});
    % enhance roidb to contain bounding-box regression targets
    [image_roidb, bbox_means, bbox_stds] = append_bbox_regression_targets(conf, image_roidb, bbox_means, bbox_stds);
end

function [image_roidb, means, stds] = append_bbox_regression_targets(conf, image_roidb, means, stds)
    % means and stds -- (k+1) * 4, include background class

    num_images = length(image_roidb);
    % Infer number of classes from the number of columns in gt_overlaps
    for i = 1:num_images
       rois = image_roidb(i).rois; 
       image_roidb(i).bbox_targets = compute_targets(conf, rois(:,1:4), rois(:,5));
    end
        
    if ~( exist('means', 'var') && ~isempty(means) && exist('stds', 'var') && ~isempty(stds) )
        % Compute values needed for means and stds
        % var(x) = E(x^2) - E(x)^2
        pos_counts = 0;
        sums = zeros(1, 4);
        squared_sums = zeros(1, 4);
        for i = 1:num_images
           targets = image_roidb(i).bbox_targets;
           %pos_inds = find(targets(:, 1) > 0);
           [row,~] = find(targets);
           pos_inds = unique(row);
           if ~isempty(pos_inds)
              pos_counts = pos_counts + length(pos_inds); 
              sums = sums + sum(targets(pos_inds, :), 1);
              squared_sums = squared_sums + sum(targets(pos_inds, :).^2, 1);
           end
        end

        means = bsxfun(@rdivide, sums, pos_counts);
        stds = (bsxfun(@minus, bsxfun(@rdivide, squared_sums, pos_counts), means.^2)).^0.5;
    end
    
    for i = 1:num_images
        targets = image_roidb(i).bbox_targets;
        [row,~] = find(targets);
        pos_inds = unique(row);
        if ~isempty(pos_inds)
            image_roidb(i).bbox_targets(pos_inds, :) = ...
                bsxfun(@minus, image_roidb(i).bbox_targets(pos_inds, :), means);
            image_roidb(i).bbox_targets(pos_inds, :) = ...
                bsxfun(@rdivide, image_roidb(i).bbox_targets(pos_inds, :), stds);
        end
    end
end


function bbox_targets = compute_targets(conf, rois, overlaps)

    % ensure ROIs are floats
    rois = single(rois);
    
    bbox_targets = zeros(size(rois, 1), 4, 'single');
    
    % Indices of ground-truth ROIs
    gt_inds = find(overlaps == 1);
    
    % if no gt in image, every target is 0
    if ~isempty(gt_inds)
        % Indices of examples for which we try to make predictions
        ex_inds = find(overlaps >= conf.fg_thresh);

        % Get IoU overlap between each ex ROI and gt ROI
        ex_gt_overlaps = boxoverlap(rois(ex_inds, :), rois(gt_inds, :));
        assert(all(abs(max(ex_gt_overlaps, [], 2) - overlaps(ex_inds)) < 10^-4));

        % Find which gt ROI each ex ROI has max overlap with:
        % this will be the ex ROI's gt target
        [~, gt_assignment] = max(ex_gt_overlaps, [], 2);
        gt_rois = rois(gt_inds(gt_assignment), :);
        ex_rois = rois(ex_inds, :);
        regression_label = fast_rcnn_bbox_transform(ex_rois, gt_rois);
        % 첫번쨰 열에는 positive bbox임을 표시하기위해 1을 넣는다.
        % negative 혹은 none bbox의 경우, regression이 필요없으므로 모든 행이 0이다.
        % ground truth의 positive bbox는 regression이 모두 0이여서, negative,none bbox와
        % 구분하기위해 열 하나를 더 만들었다.
        bbox_targets(ex_inds, :) = regression_label;
    end
end