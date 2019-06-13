function bboxes_out = regress_bboxes_img( model, conv_feat, bboxes_in, img_size)
% regress_bboxes_img given a bounding box regression model, the
% convolutional features of an image and a set bounding boxes with the 
% category id of each of them, it regresses to new the bounding box 
% coordinates such that the new boxes will (ideally) tighter enclose an
% object of the given category
%
% INPUTS:
% 1) model: (type struct) the bounding box regression model
% 2) conv_feat: the convolutional features of an image
% 3) bboxes_in: a N x 5 array with the bounding box coordinates conv_feat 
% the form of [x0,y0,x1,y1,c] where (x0,y0) is tot-left corner, (x1,y1) is 
% the bottom-right corner, and c is the category id of the bounding box. 
% N is the number of bounding boxes
% 4) img_size: a 1 x 2 vector with image size
% 
% OUTPUT:
% 1) bboxes_out : a N x 5 array with the refined bounding boxes. It has the
% same format as bboxes_in
% 
% This file is part of the code that implements the following ICCV2015 accepted paper:
% title: "Object detection via a multi-region & semantic segmentation-aware CNN model"
% authors: Spyros Gidaris, Nikos Komodakis
% institution: Universite Paris Est, Ecole des Ponts ParisTech
% Technical report: http://arxiv.org/abs/1505.01749
% code: https://github.com/gidariss/mrcnn-object-detection
% 
% 
% AUTORIGHTS
% --------------------------------------------------------
% Copyright (c) 2015 Spyros Gidaris
% 
% "Object detection via a multi-region & semantic segmentation-aware CNN model"
% Technical report: http://arxiv.org/abs/1505.01749
% Licensed under The MIT License [see LICENSE for details]
% ---------------------------------------------------------

num_classes = length(model.classes);
if ~isempty(bboxes_in)
    % given the convolutional features of an image, adaptively pool fixed
    % size region features for each bounding box and multiple type of
    % regions
    region_feats = convFeat_to_poolFeat_multi_region(model.pooler, conv_feat, bboxes_in(:,1:4));
    % fed the region features to the fully connected layers in order to
    % predict the new bounding box regression values. Specifically, for
    % each bounding box 4*C values are predicted; 4 for each category type
    outputs     = caffe_forward_net(model.net, region_feats);
    pred_vals   = outputs{1}'; % array of size N x (4*C)
    assert(size(pred_vals,1) == size(bboxes_in,1));
    assert(size(pred_vals,2) == 4*num_classes);
    pred_vals = reshape(pred_vals, [size(pred_vals,1),4,num_classes]); % tensor of size N x 4 x C
    class_indices = bboxes_in(:,5);
    
    % for each bounding box keep the 4 regression values that correspond 
    % to the catogory to which this bounding box belongs
    bboxes_out = zeros(size(pred_vals,1),4,'single');
    for i = 1:size(bboxes_in,1)
        bboxes_out(i,:) = pred_vals(i,:,class_indices(i));
    end
    
    % given the the initial bounding boxes coordinates and the regression 
    % values return the new bounding box coordinates
    bboxes_out = decode_reg_vals_to_bbox_targets(bboxes_in(:,1:4), bboxes_out);
    bboxes_out = clip_bbox_inside_the_img(bboxes_out, img_size);
    bboxes_out = [bboxes_out, class_indices];
else
    bboxes_out = zeros(0,5,'single');
end
end

function bboxes = clip_bbox_inside_the_img(bboxes, img_size)
bboxes(:,1) = max(1,           bboxes(:,1));
bboxes(:,2) = max(1,           bboxes(:,2));
bboxes(:,3) = min(img_size(2), bboxes(:,3));
bboxes(:,4) = min(img_size(1), bboxes(:,4));
end
