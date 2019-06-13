function all_bboxes_out = regress_bboxes_all_imgs(...
    model, image_paths, feature_paths, all_bboxes_in, ...
    dst_directory, image_set_name, varargin)
% regress_bboxes_all_imgs given a bounding box regression model and a set 
% of images with their corresponding convolutional features and their   
% bounding box proposals, for each image it regresses to new the bounding  
% box coordinates such that the new boxes will (ideally) tighter enclose an
% object of interest.
% 
%
% This file is part of the code that implements the following ICCV2015 accepted paper:
% title: "Object detection via a multi-region & semantic segmentation-aware CNN model"
% authors: Spyros Gidaris, Nikos Komodakis
% institution: Universite Paris Est, Ecole des Ponts ParisTech
% Technical report: http://arxiv.org/abs/1505.01749
% code: https://github.com/gidariss/mrcnn-object-detection
% 
% Part of the code in this file comes from the SPP-Net code: 
% https://github.com/ShaoqingRen/SPP_net
% and the R-CNN code: 
% https://github.com/rbgirshick/rcnn
% 
% AUTORIGHTS
% --------------------------------------------------------
% Copyright (c) 2015 Spyros Gidaris
% 
% "Object detection via a multi-region & semantic segmentation-aware CNN model"
% Technical report: http://arxiv.org/abs/1505.01749
% Licensed under The MIT License [see LICENSE for details]
% ---------------------------------------------------------
% Copyright (c) 2014, Shaoqing Ren
% 
% This file is part of the SPP code and is available 
% under the terms of the Simplified BSD License provided in 
% LICENSE. Please retain this notice and LICENSE if you use 
% this file (or any portion of it) in your project.
% --------------------------------------------------------- 
% ---------------------------------------------------------
% Copyright (c) 2014, Ross Girshick
% 
% This file is part of the R-CNN code and is available 
% under the terms of the Simplified BSD License provided in 
% LICENSE. Please retain this notice and LICENSE if you use 
% this file (or any portion of it) in your project.
% ---------------------------------------------------------

ip = inputParser;
ip.addParamValue('force',           false, @islogical);
ip.addParamValue('is_per_class',    true,  @islogical);
ip.addParamValue('suffix',          '',    @ischar);
ip.addParamValue('all_bbox_gt',     {},    @iscell);
ip.addParamValue('checkpoint_step', 500,   @isnumeric);

ip.parse(varargin{:});
opts = ip.Results;

mkdir_if_missing(dst_directory);
filepath_scores           = [dst_directory, filesep, 'reg_boxes_', opts.suffix, image_set_name, '.mat'];
in_progress_filepath      = [dst_directory, filesep, 'reg_boxes_', opts.suffix, image_set_name, '_in_progress.mat'];

timestamp       = datestr(datevec(now()), 'yyyymmdd_HHMMSS');
log_file        = fullfile(dst_directory, 'output', ['log_file_','reg_boxes_',opts.suffix, image_set_name, '_', timestamp, '.txt']);
mkdir_if_missing(fileparts(log_file));

t_start = tic();
try
    assert(~opts.force);
    all_bboxes_out = load_bboxes_scores(filepath_scores);
catch
    diary(log_file);
    all_bboxes_out = regress_bbox_of_all_images(...
        model, image_paths, feature_paths, all_bboxes_in, ...
        opts.all_bbox_gt, opts.is_per_class, in_progress_filepath, ...
        opts.checkpoint_step);
    
    save_bboxes_scores(filepath_scores, all_bboxes_out);
    
    delete(in_progress_filepath);
    diary off;
end
fprintf('Regress bounding box proposals in %.4f minutes.\n', toc(t_start)/60);
end

function save_bboxes_scores(filename, bboxes_scores)
save(filename, 'bboxes_scores', '-v7.3');
end

function bboxes_scores = load_bboxes_scores(filename)
load(filename, 'bboxes_scores');
end

function all_bboxes_out = regress_bbox_of_all_images(...
    model, image_paths, feature_paths, all_bboxes_in, all_bbox_gt, ...
    is_per_class, in_progress_filepath, checkpoint_step)

num_imgs      = length(image_paths);
nms_over_thrs = 0.3;
max_per_set   = 5 * num_imgs;
max_per_image = 100;
num_classes   = length(model.classes);

try
    [fist_img_idx, aboxes, all_bboxes_out, thresh] = load_progress(in_progress_filepath);
    mAP = check_progress_on_mAP(aboxes, all_bbox_gt, fist_img_idx-1, model.classes);
    mAP_i = fist_img_idx-1;
catch exception
    fprintf('Exception message %s\n', getReport(exception));
    aboxes = cell(num_classes, 1);
    for i = 1:num_classes, aboxes{i} = cell(num_imgs, 1); end
    if is_per_class
        all_bboxes_out = cell(num_classes,1);
        for i = 1:num_classes, all_bboxes_out{i} = cell(num_imgs, 1); end
    else
        all_bboxes_out = cell(num_imgs,1);
    end
    
    thresh       = -2.5 * ones(num_classes, 1);
    fist_img_idx = 1;
    mAP = 0;
    mAP_i = 0;
end

total_el_time = 0;
for i = fist_img_idx:num_imgs
    fprintf('%s: bbox reg %d/%d ', procid(), i, num_imgs); th = tic;

    feat_data = read_feat_conv_data(feature_paths{i});
    
    [bbox_proposals, bbox_scores] = get_bbox_proposals(all_bboxes_in, i, is_per_class);
    image_size   = get_image_size(image_paths{i});
    bbox_refined = regress_bboxes_img(model, feat_data.feat, bbox_proposals, image_size);
    
    bbox_cand_dets  = prepare_bbox_cand_dets(bbox_refined, bbox_scores, num_classes, is_per_class);
    all_bboxes_out  = prepare_this_img_output(all_bboxes_out, i, is_per_class, bbox_cand_dets);
    
    % not necessary 
    bbox_detections = postprocess_bboxes_scored(bbox_cand_dets, is_per_class, thresh, nms_over_thrs, max_per_image);
    for j = 1:num_classes, aboxes{j}{i} = bbox_detections{j}; end
    
    if mod(i, checkpoint_step) == 0
        save_progress(aboxes, all_bboxes_out, thresh, i, in_progress_filepath);
        mAP = check_progress_on_mAP(aboxes, all_bbox_gt, i, model.classes);
        mAP_i = i;
        diary; diary; % flush diary
    end
    
    if mod(i, checkpoint_step) == 0
        for j = 1:num_classes, [aboxes{j}, thresh(j)] = keep_top_k(aboxes{j}, i, max_per_set, thresh(j)); end
        disp(thresh(:)');
    end
    
    elapsed_time    = toc(th);
    [total_el_time, ave_time, est_rem_time] = timing_process(elapsed_time, total_el_time, fist_img_idx, i, num_imgs);
    fprintf(' avg time: %.2fs | total time %.2fmin | est. remaining time %.2fmin | mAP[%d/%d] = %.4f\n', ...
        ave_time, total_el_time/60, est_rem_time/60, mAP_i, num_imgs, mAP);
end
end

function [total_el_time, ave_time, est_rem_time] = timing_process(...
    elapsed_time, total_el_time, fist_img_idx, i, num_imgs)

total_el_time   = total_el_time + elapsed_time;
ave_time        = total_el_time / (i-fist_img_idx+1);
est_rem_time    = ave_time * (num_imgs - i);
end

function image_size = get_image_size(image_path)
im_info = imfinfo(image_path);
image_size = [im_info.Height, im_info.Width];
end

function [bbox_proposals, bbox_scores] = get_bbox_proposals(all_bboxes_in, img_id, is_per_class)
if is_per_class
    bbox_proposals_per_class = cellfun(@(x) x{img_id}(:,1:4), all_bboxes_in, 'UniformOutput', false);
    class_indices = [];
    for c = 1:length(all_bboxes_in)
        class_indices = [class_indices; ones(size(all_bboxes_in{c}{img_id},1),1,'single')*c];
    end
    bbox_scores_per_class = cellfun(@(x) x{img_id}(:,5:end), all_bboxes_in, 'UniformOutput', false);

    
    num_bbox_per_class  = cellfun(@(x) size(x,1), bbox_proposals_per_class,  'UniformOutput', true);
    bbox_proposals      = cell2mat(bbox_proposals_per_class(num_bbox_per_class>0));
    bbox_scores         = cell2mat(bbox_scores_per_class(num_bbox_per_class>0));
    bbox_proposals      = [bbox_proposals, class_indices];
else
    class_indices  = ones(size(all_bboxes_in{img_id},1),1,'single');
    bbox_proposals = [all_bboxes_in{img_id}(:,1:4),class_indices];
    bbox_scores    = all_bboxes_in{img_id}(:,5:end);
end
end

function bbox_cand_dets = prepare_bbox_cand_dets(bbox_refined, bbox_scores, num_classes, is_per_class)
if is_per_class
    class_indices      = bbox_refined(:,5);
    bbox_cand_dets_tmp = single([bbox_refined(:,1:4),bbox_scores]);
    bbox_cand_dets     = cell(num_classes,1);
    for c = 1:num_classes
        bbox_cand_dets{c} = bbox_cand_dets_tmp(class_indices==c,:);
        if isempty(bbox_cand_dets{c}), bbox_cand_dets{c} = zeros(0,5,'single'); end
    end
else
    assert(size(bbox_refined,2)==5);
    assert(all(bbox_refined(:,5) == 1));
    bbox_cand_dets = single([bbox_refined(:,1:4), bbox_scores]);
end
end

function bbox_detections = postprocess_bboxes_scored(bbox_scored, is_per_class, thresh, nms_over_thrs, max_per_image)

if is_per_class
    num_classes     = length(bbox_scored);
    bbox_detections = cell(num_classes,1);
    for j = 1:num_classes
        bbox_detections{j} = post_process_bboxes(bbox_scored{j}(:,1:4), bbox_scored{j}(:,5), ...
            thresh(j), nms_over_thrs, max_per_image);
    end
else
    num_classes = size(bbox_scored,2) - 4;
    for j = 1:num_classes
        bbox_detections{j} = post_process_bboxes(bbox_scored(:,1:4), bbox_scored(:,4+j), ...
            thresh(j), nms_over_thrs, max_per_image);
    end    
end

end

function all_bboxes_out = prepare_this_img_output(all_bboxes_out, img_idx, is_per_class, bbox_this_img)
if is_per_class
    for j = 1:length(bbox_this_img), all_bboxes_out{j}{img_idx} = bbox_this_img{j}; end
else
    all_bboxes_out{img_idx} = bbox_this_img;
end
end

function [fist_img_idx, aboxes, abbox_scores, thresh] = load_progress(in_progress_filepath)
ld = load(in_progress_filepath); 
fist_img_idx = ld.progress_state.img_idx + 1;
aboxes       = ld.progress_state.aboxes;
abbox_scores = ld.progress_state.abbox_scores;
thresh       = ld.progress_state.thresh;  
end

function save_progress(aboxes, abbox_scores, thresh, img_idx, in_progress_filepath)
progress_state              = struct;
progress_state.img_idx      = img_idx;
progress_state.aboxes       = aboxes;
progress_state.abbox_scores = abbox_scores;
progress_state.thresh       = thresh;

in_progress_filepath_prev = [in_progress_filepath, '.prev'];
if exist(in_progress_filepath, 'file')
    % in case it crash during updating the in_progress_filepath file
    copyfile(in_progress_filepath, in_progress_filepath_prev);  
end
save(in_progress_filepath, 'progress_state', '-v7.3');
delete(in_progress_filepath_prev);
end

function mAP = check_progress_on_mAP(aboxes, all_bbox_gt, img_idx, classes)
mAP = 0;
if ~isempty(all_bbox_gt)
    num_classes = length(classes);
    aboxes      = cellfun(@(x) x(1:img_idx), aboxes, 'UniformOutput', false);
    mAP_result  = evaluate_average_precision_pascal( all_bbox_gt(1:img_idx), aboxes, classes );
    printAPResults(classes, mAP_result);
    mAP = mean([mAP_result(:).ap]');
end
end

function [boxes, thresh] = keep_top_k(boxes, end_at, top_k, thresh)
% ------------------------------------------------------------------------
% Keep top K
X = cat(1, boxes{1:end_at});
if isempty(X), return; end

scores = sort(X(:,end), 'descend');
thresh = scores(min(length(scores), top_k));
for image_index = 1:end_at
    bbox = boxes{image_index};
    keep = find(bbox(:,end) >= thresh);
    boxes{image_index} = bbox(keep,:);
end

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
    bbox_dets  = cat(2, single(boxes), single(scores));
else
    bbox_dets   = zeros(0, 5, 'single');
end
end
