function [ bbox_detections ] = demo_object_detection_with_iterative_loc( ...
    img, model_obj_rec, model_obj_loc, conf )
% demo_object_detection_with_iterative_loc given an image, a recognition 
% model for scoring candidate detection boxes and a bounding box regression
% model for refining the bounding box coordinates, it performs the object
% detection task by performing the following steps:
% 1) extracts class agnostic bounding box proposals by using either the
% selective search algorithm or the edge box algorithm.
% 2) It iteratively applies the following steps:
%   2.1) assings a confidense score to the  bounding box proposals using the
%   recognition model. This confidense score represents the likelihood of a
%   candidate box to tightly enclose the object of interest. Note that the
%   pascal dataset contains 20 categories of objects and hence a recognition
%   model trained to this dataset will return 20 scores per candidate boxes.
%   2.2) refines the coordinates of the bounding box coordinates by applying
%   the bounding box regression model on the box proposals 
% 3) performs the post-processing steps of non-maximum-suppression with 
% bounding box voting that will return the final lists of object detections 
% (in form of bounding boxes). Note that the post-processing steps are 
% performed indipendentely on each category type. At the end the function 
% returns as many object detections lists as number of categories.
% 
% For more details we refer to the section 5 of the technical report: 
% http://arxiv.org/abs/1505.01749
% Note that the current implementation it includes some minor modifications
% w.r.t what is described on the technical report.
% 
% INPUT:
% 1) img: a H x W x 3 uint8 matrix that contains the image pixel values
% 2) model_obj_rec: a struct with the object recognition model
% 3) model_obj_loc: a struct with the bounding box regression model
% 4) conf: a struct that must contain the following fields:
%    a) conf.nms_iou_thrs: scalar value with the IoU threshold that will be
%       used during the non-max-suppression step that is applied at post
%       processing time.
%    b) conf.thresh: is a C x 1 array, where C is the number of categories.
%       It must contains the threshold per category that will be used for 
%       removing candidate boxes with low confidence prior to applying the 
%       non-max-suppression step at post processing time.
%    c) conf.box_method: is a string with the box proposals algorithm that
%       will be used in order to generate the set of candidate boxes.
%       Currently it supports the 'edge_boxes' or the 'selective_search'
%       types only.
%    d) conf.num_iterations: scalar value with the number of iterations
%       that the iterative localization scheme is performed. 
%    e) conf.thresh_init  is a C x 1 array, where C is the number of categories.
%       It must contains the threshold per category that will be used in
%       order to prune the candidate boxes with low confidence only at the
%       first iteration of the iterative localization scheme. 
%    f) conf.nms_iou_thrs_init scalar value with the IoU threshold that 
%       will be used during the non-max-suppression step that is applied
%       after the first iteration of the iterative localization scheme only
%       in order to remove near duplicate box proposals (the default value
%       for this parameter is 0.95).
%       
%
% OUTPUT:
% 1) bbox_detections: is a C x 1 cell array with the object detection where
% C is the number of categories. The i-th element of bbox_detections is a
% ND_i x 5 matrix arrray with object detection of the i-th category. Each row
% contains the following values [x0, y0, x1, y1, scr] where the (x0,y0) and 
% (x1,y1) are coorindates of the top-left and bottom-right corners
% correspondingly. scr is the confidence score assigned to the bounding box
% detection and ND_i is the number of detections.
% 
% 
% This file is part of the code that implements the following ICCV2015 accepted paper:
% title: "Object detection via a multi-region & semantic segmentation-aware CNN model"
% authors: Spyros Gidaris, Nikos Komodakis
% institution: Universite Paris Est, Ecole des Ponts ParisTech
% Technical report: http://arxiv.org/abs/1505.01749
% code: https://github.com/gidariss/mrcnn-object-detection
% 
% AUTORIGHTS
% --------------------------------------------------------
% Copyright (c) 2015 Spyros Gidaris
% 
% "Object detection via a multi-region & semantic segmentation-aware CNN model"
% Technical report: http://arxiv.org/abs/1505.01749
% Licensed under The MIT License [see LICENSE for details]
% ---------------------------------------------------------

% extract the edge box proposals of an image
fprintf('Extracting bounding box proposals... '); th = tic;
switch conf.box_method
    case 'edge_boxes'
        bbox_proposals = extract_edge_boxes_from_image(img);
    case 'selective_search'
        bbox_proposals = extract_selective_search_from_image(img); 
    otherwise 
        error('The box proposal type %s is not valid')
end
% bbox_proposals is a NB X 4 array contains the candidate boxes; the i-th
% row contains cordinates [x0, y0, x1, y1] of the i-th candidate box, where 
% the (x0,y0) and (x1,y1) are coorindates of the top-left and 
% bottom-right corners correspondingly. NB is the number of box proposals.
fprintf(' %.3f sec\n', toc(th));

category_names = model_obj_rec.classes; % a C x 1 cell array with the name 
% of the categories that the detection system looks for. C is the number of
% categories.
num_categories = length(category_names);


% extract the activation maps of the image
fprintf('Extracting the image actication maps... '); th = tic;
if isfield(model_obj_rec,'use_sem_seg_feats') && model_obj_rec.use_sem_seg_feats
    feat_data = extract_image_activation_maps(model_obj_rec.act_maps_net, img, ...
        model_obj_rec.scales, model_obj_rec.mean_pix, ...
        model_obj_rec.sem_act_maps_net, model_obj_rec.semantic_scales);     
else
    feat_data = extract_image_activation_maps(model_obj_rec.act_maps_net, img, ...
        model_obj_rec.scales, model_obj_rec.mean_pix); 
end
fprintf(' %.3f sec\n', toc(th));


image_size = [size(img,1), size(img,2)];

max_per_image = 100;
fprintf('Iterative object localization... '); th = tic;
bbox_cand_dets_per_iter = cell(conf.num_iterations,1);
for iter = 1:conf.num_iterations
    % score the bounding box proposals with the recognition model;
    % bboxes_scores will be a NB x C array, where NB is the number of box 
    % proposals and C is the number of categories.
    bboxes_scores  = scores_bboxes_img( model_obj_rec, feat_data.feat, bbox_proposals );
    if (iter == 1)
        % For each category prune the candidate detection boxes that have
        % low confidence score or near duplicate candidate boxes
        [bbox_proposals, bboxes_scores] = prune_candidate_boxes_with_low_confidence(...
            bbox_proposals, bboxes_scores, conf.thresh_init, conf.nms_iou_thrs_init, max_per_image);  
        % After the above operation there will be a different set of 
        % candidate detection boxes per category. Hence, at this point 
        % bbox_proposals will be a NBB x 5 array where the first 4 columns 
        % contain the coordinates of the bounding boxes that survived the above 
        % pruning operation and the 5-th contains the category ids of the bounding boxes.
        % bboxes_scores will a NBB x 1 array with the confidence score of each
        % bounding box w.r.t. its category.
    else % iter > 1
        % Note that for iter > 1 there is a different set of box proposals
        % per category
        category_indices = bbox_proposals(:,5); % the category id of each box proposal
        
        % get the confidence score of each box proposal w.r.t. its category
        bboxes_scores_per_class = cell(num_categories,1);
        for c = 1:num_categories
            bboxes_scores_per_class{c} = bboxes_scores(category_indices==c,c);
        end
        bboxes_scores = cell2mat(bboxes_scores_per_class); 
        % bboxes_scores is a NBB x 1 array with the confidence score of 
        % each box proposal w.r.t. its category.
    end
    % predict a new bounding box for each box proposal that ideally it will
    % be better localized on a object of the same category as the box proposal.
    bbox_refined = regress_bboxes_img(model_obj_loc, feat_data.feat, bbox_proposals, image_size);
    % bbox_refined is a NBB x 5 array where the first 4 columns contain the
    % refined bounding box coordinates and the 5-th column contains the
    % category id of each bounding box.

    bbox_proposals = bbox_refined;
    
    bbox_cand_dets_per_iter{iter} = prepare_bbox_cand_dets(bbox_refined, bboxes_scores, num_categories);
    % bbox_cand_dets_per_iter{iter} is a C x 1 cell array with the candidate detection
    % boxes of each of the C categories that were generated during the
    % iter-th iteration. The i-th element of this cell array is NBB_i x 5
    % array with the candidate detections of the i-th category; the first 4 
    % columns contain the bouding box coordinates and the 5-th column
    % contains the confidence score of each bounding box with respect to
    % the i-th category. NBB_i is the number of candidate detections that
    % were generated during the iter-th iteration for the i-th category.
end
fprintf(' %.3f sec\n', toc(th));

fprintf('applying the non-max-suppression with box voting step... '); th = tic;
% for each category merge the candidate bounding box detections of each 
% iteration to a single set
bbox_cand_dets  = merge_bbox_cand_dets(bbox_cand_dets_per_iter);
conf.do_bbox_voting     = true; % do bounding box voting
conf.box_ave_iou_thresh = 0.5; % the IoU threshold for the neighboring bounding boxes
conf.add_val            = 1.5; % this value is added to the bounding box scores 
                               % before they are used as weight during the box voting step
bbox_detections = post_process_candidate_detections( bbox_cand_dets, ...
    conf.thresh, conf.nms_iou_thrs, max_per_image, conf.do_bbox_voting, ...
    conf.box_ave_iou_thresh, conf.add_val);
fprintf(' %.3f sec\n', toc(th));

end

function [bbox_proposals, bboxes_scores] = prune_candidate_boxes_with_low_confidence(...
    bbox_proposals, bboxes_scores, thresh_init, nms_over_thrs_init, max_per_image)
bbox_cand_dets = single([bbox_proposals(:,1:4), bboxes_scores]);
% For each category prune the candidate detection boxes with low 
% confidence score or near duplicate detection boxes (IoU > nms_over_thrs_init)
bbox_cand_dets = post_process_candidate_detections( bbox_cand_dets, ...
    thresh_init, nms_over_thrs_init, max_per_image);   
% After the above operation there will be a different set of 
% candidate detection boxes per category. Hence, bbox_cand_dets
% will be a C x 1 cell array with the candidate detection boxes of 
% each of the C categories.

% reformulate the bbox_cand_dets cell array
[bbox_proposals, bboxes_scores] = get_bbox_proposals(bbox_cand_dets);
% bbox_proposals is a NB x 5 array with the candidate detection
% boxes of all the categories together. The first 4 columns contain 
% the coordinates of the bounding boxes and the 5-th column contains
% the category id of each bounding box. 
% bboxes_scores is a NB x 1 array with the confidence score of each
% bounding box w.r.t. its category id.
end

function bbox_cand_dets = merge_bbox_cand_dets(bbox_cand_dets_per_iter)
num_iterations = length(bbox_cand_dets_per_iter);
num_categories = length(bbox_cand_dets_per_iter{1});
bbox_cand_dets = cell(num_categories,1);
for j = 1:num_categories
    bbox_cand_dets_per_iter_this_cls = cell(num_iterations, 1);
    for iter = 1:num_iterations
        bbox_cand_dets_per_iter_this_cls{iter} = bbox_cand_dets_per_iter{iter}{j};
    end
    bbox_cand_dets{j} = cell2mat(bbox_cand_dets_per_iter_this_cls);
end
end

function [bbox_proposals, bbox_scores] = get_bbox_proposals(bbox_cand_dets)
bbox_cand_dets = bbox_cand_dets(:);
bbox_proposals_per_class = cellfun(@(x) x(:,1:4), bbox_cand_dets, 'UniformOutput', false);
class_indices = [];
for c = 1:length(bbox_cand_dets)
    class_indices = [class_indices; ones(size(bbox_cand_dets{c},1),1,'single')*c];
end
bbox_scores_per_class = cellfun(@(x) x(:,5:end), bbox_cand_dets, 'UniformOutput', false);


num_bbox_per_class  = cellfun(@(x) size(x,1), bbox_proposals_per_class,  'UniformOutput', true);
bbox_proposals      = cell2mat(bbox_proposals_per_class(num_bbox_per_class>0));
bbox_scores         = cell2mat(bbox_scores_per_class(num_bbox_per_class>0));
bbox_proposals      = [bbox_proposals, class_indices];
end

function bbox_cand_dets = prepare_bbox_cand_dets(bbox_coordinates, bbox_scores, num_classes)
class_indices      = bbox_coordinates(:,5);
bbox_cand_dets_tmp = single([bbox_coordinates(:,1:4), bbox_scores]);
bbox_cand_dets     = cell(num_classes,1);
for c = 1:num_classes
    bbox_cand_dets{c} = bbox_cand_dets_tmp(class_indices==c,:);
    if isempty(bbox_cand_dets{c}), bbox_cand_dets{c} = zeros(0,5,'single'); end
end
end

function bbox_proposals = extract_edge_boxes_from_image(img)
% bbox_proposals is a NB X 4 array contains the candidate boxes; the i-th
% row contains cordinates [x0, y0, x1, y1] of the i-th candidate box, where 
% the (x0,y0) and (x1,y1) are coorindates of the top-left and 
% bottom-right corners correspondingly.

edge_boxes_path = fullfile(pwd, 'external', 'edges');
model=load(fullfile(edge_boxes_path,'models/forest/modelBsds')); 
model=model.model;
model.opts.multiscale=0; model.opts.sharpen=2; model.opts.nThreads=4;

% set up opts for edgeBoxes
opts          = edgeBoxes;
opts.alpha    = .65;     % step size of sliding window search
opts.beta     = .70;     % nms threshold for object proposals
opts.minScore = .01;     % min score of boxes to detect
opts.maxBoxes = 2000;    % max number of boxes to detect
    
boxes = edgeBoxes(img,model,opts);

bbox_proposals = [boxes(:,1:2), boxes(:,1:2) + boxes(:,3:4)-1];
end

function bbox_proposals = extract_selective_search_from_image(img)
% bbox_proposals is a NB X 4 array contains the candidate boxes; the i-th
% row contains cordinates [x0, y0, x1, y1] of the i-th candidate box, where 
% the (x0,y0) and (x1,y1) are coorindates of the top-left and 
% bottom-right corners correspondingly.
fast_mode = true;
boxes = selective_search_boxes(img, fast_mode);
bbox_proposals = single(boxes(:,[2 1 4 3]));
end