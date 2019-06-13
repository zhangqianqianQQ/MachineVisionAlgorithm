function scores = scores_bboxes_img( model, conv_feat, bboxes )
% scores_bboxes_img given a recongiotion model, the convolutional features
% of an image and a set bounding boxes it returns the classification scores 
% of each bounding box w.r.t. each of the C categories of the recognition model.
% Those classification scores represent the likelihood of each bounding box
% to tightly enclose an object for each of the C cateogies.
%
% INPUTS:
% model: (type struct) the bounding box recognition model
% conv_feat: the convolutional features of an image
% bboxes: a N x 4 array with the bounding box coordinates in the form of
% [x0,y0,x1,y1] where (x0,y0) is tot-left corner and (x1,y1) is the
% bottom-right corner. N is the number of boundin boxes
% 
% OUTPUT:
% scores: N x C array with the classification scores of each bounding box
% for each of the C categories.
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

num_classes = length(model.classes);

if ~isempty(bboxes)
    % given the convolutional features of an image, adaptively pool fixed
    % size region features for each bounding box and multiple type of
    % regions
    region_feats = convFeat_to_poolFeat_multi_region(model.pooler, conv_feat, bboxes(:,1:4));
    % fed the region features to the fully connected layers in order to
    % score the bounding box proposals
    outputs = caffe_forward_net(model.net, region_feats);
    scores  = outputs{1}';
else
    scores  = zeros(0,num_classes,'single');
end

% in the case that there is an exra column than the number of categories, 
% then the first column represents the confidence score of each bounding 
% box to belong on the background category and it is removed before the
% score array is returned.
if size(scores,2) == (num_classes + 1), scores = scores(:,2:end); end
end
