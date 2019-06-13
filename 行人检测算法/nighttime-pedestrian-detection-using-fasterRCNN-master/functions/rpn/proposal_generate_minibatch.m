function [input_blobs, random_scale_inds] = proposal_generate_minibatch(conf, image_roidb, randomness, multi_frame)
% [input_blobs, random_scale_inds] = proposal_generate_minibatch_caltech(conf, image_roidb)
% --------------------------------------------------------
% RPN_BF
% Copyright (c) 2016, Liliang Zhang
% Licensed under The MIT License [see LICENSE for details]
% --------------------------------------------------------

    num_images = length(image_roidb);
    assert(num_images == 2 || num_images == 1, 'proposal_generate_minibatch_caltech only support num_images == 2 or 1');

    % Sample random scales to use for each image in this batch
    random_scale_inds = randi(length(conf.scales), num_images, 1);

    assert(mod(conf.batch_size, num_images) == 0, ...
        sprintf('num_images %d must divide BATCH_SIZE %d', num_images, conf.batch_size));
    
    rois_per_image = conf.batch_size / num_images;
    fg_rois_per_image = round(conf.batch_size * conf.fg_fraction);
    
    % Get the input image blob
    [im_blob, im_scales, ~]=my_image_blob(conf,image_roidb.image_path,multi_frame);
    
    img_size = round(image_roidb.im_size * im_scales);
    output_size = cell2mat([conf.output_height_map.values({img_size(1)}), conf.output_width_map.values({img_size(2)})]);
    
    [labels, label_weights, bbox_targets, bbox_loss] = ...
        sample_rois(conf, image_roidb, fg_rois_per_image, rois_per_image, im_scales, random_scale_inds, randomness);

    assert(img_size(1) == size(im_blob, 1) && img_size(2) == size(im_blob, 2));

    labels_blob = reshape(labels, size(conf.anchors, 1), output_size(1), output_size(2));
    label_weights_blob = reshape(label_weights, size(conf.anchors, 1), output_size(1), output_size(2));
    bbox_targets_blob = reshape(bbox_targets', size(conf.anchors, 1)*4, output_size(1), output_size(2));
    bbox_loss_blob = reshape(bbox_loss', size(conf.anchors, 1)*4, output_size(1), output_size(2));

    % permute from [channel, height, width], where channel is the
    % fastest dimension to [width, height, channel]
    labels_blob = permute(labels_blob, [3, 2, 1]);
    label_weights_blob = permute(label_weights_blob, [3, 2, 1]);
    bbox_targets_blob = permute(bbox_targets_blob, [3, 2, 1]);
    bbox_loss_blob = permute(bbox_loss_blob, [3, 2, 1]);
        
    % permute data into caffe c++ memory, thus [num, channels, height, width]
    im_blob = im_blob(:, :, [3, 2, 1], :); % from rgb to brg
    im_blob = single(permute(im_blob, [2, 1, 3, 4]));
    labels_blob = single(labels_blob);
    labels_blob(labels_blob > 0) = 1; %to binary lable (fg and bg)
    label_weights_blob = single(label_weights_blob);
    bbox_targets_blob = single(bbox_targets_blob); 
    bbox_loss_blob = single(bbox_loss_blob);
    
    assert(~isempty(im_blob));
    assert(~isempty(labels_blob));
    assert(~isempty(label_weights_blob));
    assert(~isempty(bbox_targets_blob));
    assert(~isempty(bbox_loss_blob));
    
    input_blobs = {im_blob, labels_blob, label_weights_blob, bbox_targets_blob, bbox_loss_blob};
end

%% Generate a random sample of ROIs comprising foreground and background examples.
function [labels, label_weights, bbox_targets, bbox_loss_weights] = ...
    sample_rois(conf, image_roidb, fg_rois_per_image, rois_per_image, im_scale, im_scale_ind, randomness)

    bbox_targets = image_roidb.bbox_targets{im_scale_ind};
    ex_asign_labels = bbox_targets(:, 1);
    
    % Select foreground ROIs as those with >= FG_THRESH overlap
    fg_inds = find(bbox_targets(:, 1) > 0);
    
    % Select background ROIs as those within [BG_THRESH_LO, BG_THRESH_HI)
    bg_inds = find(bbox_targets(:, 1) < 0);
    
    % bbox_targets(:,1)==0 : ignore_inds
    
    % select foreground
    fg_num = min(fg_rois_per_image, length(fg_inds));
    if(randomness)
        fg_inds = fg_inds(randperm(length(fg_inds), fg_num));
    end
%     bg_num = min(rois_per_image - fg_num, length(bg_inds));
    bg_num = min(rois_per_image - fg_rois_per_image, length(bg_inds));
    if(randomness)
        bg_inds = bg_inds(randperm(length(bg_inds), bg_num));
    end
    labels = zeros(size(bbox_targets, 1), 1);
    % set foreground labels
    labels(fg_inds) = ex_asign_labels(fg_inds);
    assert(all(ex_asign_labels(fg_inds) > 0));
    
    label_weights = zeros(size(bbox_targets, 1), 1);
    
    % assign weight a bigger value 
    % when the number of fg is lesser than expected
    label_weights(fg_inds) = fg_rois_per_image / fg_num; 
    % set background labels weights
    label_weights(bg_inds) = conf.bg_weight;

    bbox_targets = single(full(bbox_targets(:, 2:end)));
    
    bbox_loss_weights = bbox_targets * 0;
%     bbox_loss_weights(fg_inds, :) = 1;
    bbox_loss_weights(fg_inds, :) = fg_rois_per_image / fg_num;
end

