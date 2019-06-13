function conv_feat_data = extract_image_activation_maps(CNN, image, scales, mean_pix, ...
    Semantic_Aware_CNN, semantic_scales)
% extract_image_activation_maps(CNN, image, scales, mean_pix): extract the 
% activation maps of one image (section 3 of technical report) for the 
% specified scales using the convolutional neural network CNN. 
% extract_image_activation_maps(CNN, image, scales, mean_pix, Semantic_Aware_CNN, semantic_scales):
% In this case the current function it also extracts the semantic
% segmentation aware activation maps (see section 4 of the technical
% report). 
% 
% INPUTS:
% 1) CNN: the caffe net struct with the convolutional neural network that
% implements the activation mas module (section 3)
% 2) image: a Height x Width x 3 uint8 array that represents the image
% pixels
% 3) scales: NumScales x 1 or 1 x NumScales vector with the images scales
% that will be used. The i-th value should be the size in pixels of the
% smallest dimension of the image in the i-th scale.
% 4) mean_pix: is a 3 x 1 or 1 x 3 vector with the mean pixel value per 
% color channel that is subtracted from the scaled image before is being 
% fed to the CNN
% 5) Semantic_Aware_CNN (OPTIONAL): the caffe net struct with the 
% convolutional neural that implements the activation mas module for the 
% semantic segmentation aware CNN features (section 4). The Semantic_Aware_CNN
% network gets as input the convolutional feature maps that the CNN network
% yields and outputs semantic segmentation aware activation maps.
% 6) semantic_scales: a NumScales2 x 1 or 1 x NumScales2 vector with the 
% images scales that will be used for the semantic segmentation aware
% features. The elements of this vector should be a subset of the scales vector.
%
% OUTPUTS:
% 1) conv_feat_data: a struct that includes the activation maps of the
% image. Its field is:
%    conv_feat_data.feat: 
%    1.a) In case the function is called with the arguments:
%    extract_image_activation_maps(CNN, image, scales, mean_pix)
%    then conv_feat_data.feat is a struct that includes 1) the convolutional 
%    feature maps (field rsp) that the CNN network yields, 2) the image scales 
%    from which they were extracted (field scale), and 3) the original size 
%    of the image (fields im_height and im_width)
%    1.b) In case the function is called with the arguments:
%    extract_image_activation_maps(CNN, image, scales, mean_pix, Semantic_Aware_CNN, semantic_scales):
%    then it is a 1 x 2 cell array where 1st element is a struct with the
%    convolutional feature maps of the CNN network (like in the 1.a case)
%    and the 2nd element is a struct with the convolutional feature maps of 
%    the Semantic_Aware_CNN network (like in the 1.a case).
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

conv_feat_data = init_feat_data();
conv_feat_data.feat.im_height = size(image,1);
conv_feat_data.feat.im_width  = size(image,2);
% extract the activation maps of an image for a given set of scales
[conv_feat_data.feat.rsp, conv_feat_data.feat.scale] = extract_conv_features(...
    CNN, image, scales, mean_pix);

if exist('Semantic_Aware_CNN','var')>0
    assert(exist('semantic_scales','var')>0)
    % extract the semantic segmentation aware activation maps of an image
    % of a given set of scales and the convolutional feature maps (activation 
    % maps) that were previously extracted from the image using the CNN
    % network
    semantic_conv_feat_data      = conv_feat_data;
    semantic_conv_feat_data.feat = pick_scales_if_there(...
        semantic_conv_feat_data.feat, semantic_scales);    
    conf.do_interleave        = true; % if set to true then the
    % resolution augmentation technique described on the OverFeat paper: http://arxiv.org/abs/1312.6229
    % (section 3.3 of OverFeat technical report) is being used
    conf.interleave_num_steps = 2; % a scalar value for the number of steps 
    % that are being using on the above resolution augmentation technique 
    
    % extract the semantic segmentation aware activation maps
    semantic_conv_feat_data.feat.rsp = extract_semantic_seg_features_from_conv5(...
        Semantic_Aware_CNN, semantic_conv_feat_data.feat.rsp, conf);
    conv_feat_data.feat = {conv_feat_data.feat, semantic_conv_feat_data.feat};
end

end

function d = init_feat_data() 
d.feat     = [];
end

function feat = pick_scales_if_there(feat, scales)
num_scales = length(scales);

found_scales = zeros(size(scales));
found_rsp = {};
c = 0;
for s = 1:num_scales
    scale_index = find(feat.scale == scales(s));
    if ~isempty(scale_index)
        assert(numel(scale_index) == 1);
        c = c + 1;
        found_scales(c) = scales(s);
        found_rsp{c}    = feat.rsp{scale_index}; 
    end
end
feat.scale = found_scales(1:c);
feat.rsp   = found_rsp;

end

