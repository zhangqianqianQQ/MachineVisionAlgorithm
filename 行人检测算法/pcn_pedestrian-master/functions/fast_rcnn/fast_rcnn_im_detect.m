function [pred_boxes, scores, ps1, ps2, ps3, ps_lstm] = fast_rcnn_im_detect(conf, caffe_net, im, boxes, max_rois_num_in_gpu, stage)
% [pred_boxes, scores] = fast_rcnn_im_detect(conf, caffe_net, im, boxes, max_rois_num_in_gpu)
% --------------------------------------------------------
% Fast R-CNN
% Reimplementation based on Python Fast R-CNN (https://github.com/rbgirshick/fast-rcnn)
% Copyright (c) 2015, Shaoqing Ren
% Licensed under The MIT License [see LICENSE for details]
% --------------------------------------------------------
    ps1 = []; ps2 = []; ps3 = []; ps_lstm = [];
    [im_blob, rois_blob, ~] = get_blobs(conf, im, boxes);
    
    % When mapping from image ROIs to feature map ROIs, there's some aliasing
    % (some distinct image ROIs get mapped to the same feature ROI).
    % Here, we identify duplicate feature ROIs, so we only compute features
    % on the unique subset.
    [~, index, inv_index] = unique(rois_blob, 'rows');
    rois_blob = rois_blob(index, :);
    boxes = boxes(index, :);
    
    % permute data into caffe c++ memory, thus [num, channels, height, width]
    im_blob = im_blob(:, :, [3, 2, 1], :); % from rgb to brg
    im_blob = permute(im_blob, [2, 1, 3, 4]);
    im_blob = single(im_blob);
    rois_blob = rois_blob - 1; % to c's index (start from 0)
    rois_blob = permute(rois_blob, [3, 4, 2, 1]);
    rois_blob = single(rois_blob);
    
    total_rois = size(rois_blob, 4);    
    lstm_markers_blob = ones(total_rois, 16, 'single');% 
    lstm_markers_blob(:,1) = 0;
    
    total_rois = size(rois_blob, 4);
    total_scores = cell(ceil(total_rois / max_rois_num_in_gpu), 1);
    total_box_deltas = cell(ceil(total_rois / max_rois_num_in_gpu), 1);
    for i = 1:ceil(total_rois / max_rois_num_in_gpu)
        
        sub_ind_start = 1 + (i-1) * max_rois_num_in_gpu;
        sub_ind_end = min(total_rois, i * max_rois_num_in_gpu);
        sub_rois_blob = rois_blob(:, :, :, sub_ind_start:sub_ind_end);
        if stage==3
            sub_lstm_markers_blob = lstm_markers_blob(sub_ind_start:sub_ind_end, :);
            net_inputs = {im_blob, sub_rois_blob, sub_lstm_markers_blob};
        else
            net_inputs = {im_blob, sub_rois_blob};
        end

        % Reshape net's input blobs
        caffe_net.reshape_as_input(net_inputs);
        output_blobs = caffe_net.forward(net_inputs);

        if conf.test_binary
            % simulate binary logistic regression
            scores = caffe_net.blobs('cls_score').get_data();
            scores = squeeze(scores)';
            % Return scores as fg - bg
            scores = bsxfun(@minus, scores, scores(:, 1));
        else
            % use softmax estimated probabilities
            scores = output_blobs{2};
            scores = squeeze(scores)';
        end

        % Apply bounding-box regression deltas
        box_deltas = output_blobs{1};
        box_deltas = squeeze(box_deltas)';
        
        total_scores{i} = scores;
        total_box_deltas{i} = box_deltas;
        
        if stage==3
            %average over T sequences
%             lstm_scores = mean(output_blobs{3}, 3);
%             lstm_scores = squeeze(lstm_scores)';
%             total_lstm_scores{i} = lstm_scores;
%             lstm_scores = lstm_scores(inv_index, :);
            % permute [2, n, 9] to [9, n, 2]
            lstm_scores = permute(output_blobs{3}, [3,2,1]);
            total_lstm_scores{i} = lstm_scores(:,:,2);
        elseif stage==2
            %reshape from [3, 3, 2, n] to [9, 2, n] and permute to [9, n,2] 
            %so it could fit the formate of lstm [T,N,C]
            part_scores_conv3 = permute(reshape(output_blobs{3}, 9, 2, []), [1,3,2]);
            total_part_scores_conv3{i} = part_scores_conv3(:,:,2);
            part_scores_conv4 = permute(reshape(output_blobs{4}, 9, 2, []), [1,3,2]);
            total_part_scores_conv4{i} = part_scores_conv4(:,:,2);  
            part_scores_conv5 = permute(reshape(output_blobs{5}, 9, 2, []), [1,3,2]);
            total_part_scores_conv5{i} = part_scores_conv5(:,:,2);
        end
    end 
    
    scores = cell2mat(total_scores);
    box_deltas = cell2mat(total_box_deltas);
    
    pred_boxes = fast_rcnn_bbox_transform_inv(boxes, box_deltas);
    pred_boxes = clip_boxes(pred_boxes, size(im, 2), size(im, 1));

    % Map scores and predictions back to the original set of boxes
    scores = scores(inv_index, :);
    pred_boxes = pred_boxes(inv_index, :);
    
    % remove scores and boxes for back-ground
    pred_boxes = pred_boxes(:, 5:end);
    scores = scores(:, 2:end);
    
    if stage==3
        lstm_scores = cell2mat(total_lstm_scores);
        ps_lstm = lstm_scores(:, inv_index);
    elseif stage==2
        part_scores1 = cell2mat(total_part_scores_conv3);
        part_scores2 = cell2mat(total_part_scores_conv4);
        part_scores3 = cell2mat(total_part_scores_conv5);
        ps1 = part_scores1(:, inv_index);
        ps2 = part_scores2(:, inv_index);
        ps3 = part_scores3(:, inv_index);
    end
end

function [data_blob, rois_blob, im_scale_factors] = get_blobs(conf, im, rois)
    [data_blob, im_scale_factors] = get_image_blob(conf, im);
    rois_blob = get_rois_blob(conf, rois, im_scale_factors);
end

function [blob, im_scales] = get_image_blob(conf, im)
    [ims, im_scales] = arrayfun(@(x) prep_im_for_blob(im, conf.image_means, x, conf.test_max_size), conf.test_scales, 'UniformOutput', false);
    im_scales = cell2mat(im_scales);
    blob = im_list_to_blob(ims);    
end

function [rois_blob] = get_rois_blob(conf, im_rois, im_scale_factors)
    [feat_rois, levels] = map_im_rois_to_feat_rois(conf, im_rois, im_scale_factors);
    rois_blob = single([levels, feat_rois]);
end

function [feat_rois, levels] = map_im_rois_to_feat_rois(conf, im_rois, scales)
    im_rois = single(im_rois);
    
    if length(scales) > 1
        widths = im_rois(:, 3) - im_rois(:, 1) + 1;
        heights = im_rois(:, 4) - im_rois(:, 2) + 1;
        
        areas = widths .* heights;
        scaled_areas = bsxfun(@times, areas(:), scales(:)'.^2);
        [~, levels] = min(abs(scaled_areas - 224.^2), [], 2); 
    else
        levels = ones(size(im_rois, 1), 1);
    end
    
    feat_rois = round(bsxfun(@times, im_rois-1, scales(levels))) + 1;
end

function boxes = clip_boxes(boxes, im_width, im_height)
    % x1 >= 1 & <= im_width
    boxes(:, 1:4:end) = max(min(boxes(:, 1:4:end), im_width), 1);
    % y1 >= 1 & <= im_height
    boxes(:, 2:4:end) = max(min(boxes(:, 2:4:end), im_height), 1);
    % x2 >= 1 & <= im_width
    boxes(:, 3:4:end) = max(min(boxes(:, 3:4:end), im_width), 1);
    % y2 >= 1 & <= im_height
    boxes(:, 4:4:end) = max(min(boxes(:, 4:4:end), im_height), 1);
end
    