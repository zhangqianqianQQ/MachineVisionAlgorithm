function [pred_boxes, scores, feature] = proposal_im_detect2(conf, feature_net, rpn_net, im_path, multi_frame, weight)
% [pred_boxes, scores, box_deltas_, anchors_, scores_] = proposal_im_detect(conf, im, net_idx)
% --------------------------------------------------------
% Faster R-CNN
% Copyright (c) 2015, Shaoqing Ren
% Licensed under The MIT License [see LICENSE for details]
% --------------------------------------------------------    
    [im_blob, im_scales, org_size]=my_image_blob(conf,im_path,multi_frame);
    
    scaled_im_size = round(org_size(1:2) * im_scales);
    
    % permute data into caffe c++ memory, thus [num, channels, height, width]
    im_blob = im_blob(:, :, [3, 2, 1], :); % from rgb to brg
    im_blob = permute(im_blob, [2, 1, 3, 4]);
    im_blob = single(im_blob);
    
    
    for i=1:size(im_blob,4)
        net_inputs={im_blob(:,:,:,i)};
        feature_net.reshape_as_input(net_inputs);
        output_blobs = feature_net.forward(net_inputs);
        if(i==1), feature=zeros(size(output_blobs{1})); end
        feature=feature+weight(i)*output_blobs{1};
    end
    
%     for i=1:size(im_blob,4)
%         net_inputs={im_blob(:,:,:,i)};
%         feature_net.reshape_as_input(net_inputs);
%         output_blobs = feature_net.forward(net_inputs);
%         if(i==1), features=zeros([size(output_blobs{1}),size(im_blob,4)]); end
%         features(:,:,:,i)=output_blobs{1};
%     end
%     feature=max(features,[],4);
    
    net_inputs={feature};
    rpn_net.reshape_as_input(net_inputs);
    output_blobs = rpn_net.forward(net_inputs);
    % Apply bounding-box regression deltas
    box_deltas = output_blobs{1};
    featuremap_size = [size(box_deltas, 2), size(box_deltas, 1)];
    % permute from [width, height, channel] to [channel, height, width], where channel is the
        % fastest dimension
    box_deltas = permute(box_deltas, [3, 2, 1]);
    box_deltas = reshape(box_deltas, 4, [])';
    
    anchors = proposal_locate_anchors(conf, org_size, conf.test_scales, featuremap_size);
    pred_boxes = fast_rcnn_bbox_transform_inv(anchors, box_deltas);% anchor과 forward를 통해 구한 target(delta)를 통해 pred_boxes를 구함
      % scale back
    pred_boxes = bsxfun(@times, pred_boxes - 1, ...
        ([org_size(2), org_size(1), org_size(2), org_size(1)] - 1) ./ ([scaled_im_size(2), scaled_im_size(1), scaled_im_size(2), scaled_im_size(1)] - 1)) + 1;
    pred_boxes = clip_boxes(pred_boxes, org_size(2), org_size(1));% 이미지 바깥으로 삐져나온 부분을 clip
    
    assert(conf.test_binary == false);
    % use softmax estimated probabilities
    scores = output_blobs{2}(:, :, end);
    scores = reshape(scores, size(output_blobs{1}, 1), size(output_blobs{1}, 2), []);
    % permute from [width, height, channel] to [channel, height, width], where channel is the
        % fastest dimension
    scores = permute(scores, [3, 2, 1]);
    scores = scores(:);
    
    box_deltas_ = box_deltas;
    anchors_ = anchors;
    scores_ = scores;
    
    if conf.test_drop_boxes_runoff_image% anchor가 이미지 밖으로 나간것은 제외
        contained_in_image = is_contain_in_image(anchors, scaled_im_size);
        pred_boxes = pred_boxes(contained_in_image, :);
        scores = scores(contained_in_image, :);
    end
    
    % drop too small boxes
    [pred_boxes, scores] = filter_boxes(conf.test_min_box_size, conf.test_min_box_height, pred_boxes, scores);
    
    % sort
    [scores, scores_ind] = sort(scores, 'descend');
    pred_boxes = pred_boxes(scores_ind, :);
end

function [data_blob, rois_blob, im_scale_factors] = get_blobs(conf, im, rois)
    [data_blob, im_scale_factors] = get_image_blob(conf, im);
    rois_blob = get_rois_blob(conf, rois, im_scale_factors);
end

function [blob, im_scales] = get_image_blob(conf, im)
    if length(conf.test_scales) == 1
        [blob, im_scales] = prep_im_for_blob(im, conf.image_means, conf.test_scales, conf.test_max_size);
    else
        [ims, im_scales] = arrayfun(@(x) prep_im_for_blob(im, conf.image_means, x, conf.test_max_size), conf.test_scales, 'UniformOutput', false);
        im_scales = cell2mat(im_scales);
        blob = im_list_to_blob(ims);    
    end
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
        levels = max(abs(scaled_areas - 224.^2), 2); 
    else
        levels = ones(size(im_rois, 1), 1);
    end
    
    feat_rois = round(bsxfun(@times, im_rois-1, scales(levels)) / conf.feat_stride) + 1;
end

function [boxes, scores] = filter_boxes(min_box_size, min_box_height, boxes, scores)
    widths = boxes(:, 3) - boxes(:, 1) + 1;
    heights = boxes(:, 4) - boxes(:, 2) + 1;
    
    valid_ind = widths >= min_box_size & heights >= min_box_size & heights >= min_box_height;
    boxes = boxes(valid_ind, :);
    scores = scores(valid_ind, :);
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

function contained = is_contain_in_image(boxes, im_size)
    contained = boxes >= 1 & bsxfun(@le, boxes, [im_size(2), im_size(1), im_size(2), im_size(1)]);
    
    contained = all(contained, 2);
end
    
