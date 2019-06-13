function [ bbox_detections ] = demo_object_detection( img, model_obj_rec, conf )
% demo_object_detection given an image and a model for scoring candidate
% boxes it performs the object detection task by performing the following
% steps:
% 1) extracts class agnostic bounding box proposals by using either the
% selective search algorithm or the edge box algorithm.
% 2) assings a confidense score to those proposals using the object
% recognition model. this confidense score represents the likelihood of a
% candidate box to tightly enclose the object of interest. Note that the
% pascal dataset contains 20 categories of objects and hence a recognition
% model trained to this dataset will return 20 scores per candidate boxes.
% 3) performs the post-processing step of non-maximum-suppression that will
% return the final lists of object detections (in form of bounding boxes). 
% Note that the non-max-suppression step is performed indipendentely on 
% each category type. At the end the function returns as many object 
% detections lists as number of categories.
% 
% INPUT:
% 1) img: a H x W x 3 uint8 matrix that contains the image pixel values
% 2) model_obj_rec: a struct with the object recognition model
% 3) conf: a struct that must contain the following fields:
%    a) conf.nms_iou_thrs: scalar value with the IoU threshold that will be
%       used during the non-max-suppression step
%    b) conf.thresh: is a C x 1 array, where C is the number of categories.
%       It must contains the threshold per category that will be used for 
%       removing candidate boxes scores with low confidence prior to
%       applying the non-max-suppression step.
%    c) conf.box_method: is a string with the box proposals algorithm that
%       will be used in order to generate the set of candidate boxes.
%       Currently it supports the 'edge_boxes' or the 'selective_search'
%       types only.
%
% OUTPUT:
% 1) bbox_detections: is a C x 1 cell array with the object detection where
% C is the number of categories. The i-th element of bbox_detections is a
% ND x 5 matrix arrray with object detection of the i-th category. Each row
% contains the following values [x0, y0, x1, y1, scr] where the (x0,y0) and 
% (x1,y1) are coorindates of the top-left and bottom-right corners
% correspondingly. scr is the confidence score assigned to the bounding box
% detection and ND is the number of detections.
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


% score the bounding box proposals with the recognition model;
% bboxes_scores will be a NB x C array, where NB is the number of box 
% proposals and C is the number of categories.
fprintf('scoring the bounding box proposals... '); th = tic;
bboxes_scores   = scores_bboxes_img( model_obj_rec, feat_data.feat, bbox_proposals );
bbox_cand_dets  = single([bbox_proposals(:,1:4), bboxes_scores]);
fprintf(' %.3f sec\n', toc(th));


max_per_image = 100;
fprintf('applying the non-max-suppression step... '); th = tic;
bbox_detections = post_process_candidate_detections( bbox_cand_dets, ...
    conf.thresh, conf.nms_iou_thrs, max_per_image);
fprintf(' %.3f sec\n', toc(th));

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


