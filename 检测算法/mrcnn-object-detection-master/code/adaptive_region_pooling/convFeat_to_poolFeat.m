function [region_feat, regions] = convFeat_to_poolFeat(region_params, conv_feat, boxes, random_scale)
% convFeat_to_poolFeat given the convolutional features of an image, it 
% adaptively pools fixed size region features for each bounding 
% box and for a single type of region. 
% 
% INPUTS:
% 1) region_params: (type struct) the region pooling parameters. Some of 
% its fields are:
%   a) scale_inner: scalar value with the scaling factor of the inner
%   rectangle of the region. In case this value is 0 then actually no inner
%   rectangle is used
%   b) scale_outer: scalar value with the scaling factor of the outer
%   rectangle of the region. 
%   c) half_bbox: intiger value in the range [1,2,3,4]. If this parameter 
%   is set to 1, 2, 3, or 4 then each bounding box will be reshaped to its
%   left, right, top, or bottom half part correspondingly. This action is
%   performed prior to scaling the box according to the scale_inner and
%   scale_outer params. If this parameter is missing or it is empty then 
%   the action of taking the half part of bounding box is NOT performed.
%   d) spm_divs: a P x 1 vector with the number of divisions of a region on 
%   each of the P levels of the pyramid during the adaptively region max
%   pooling step. Mostly, there is only one P=1 pyramid level. 
%   For example, in the case of the region adaptive modules of section 3 of 
%   the technical report spm_divs = [7] and of the region adaptive module
%   for the semantic segmentation aware CNN features (section 4) 
%   spm_divs = [9].
% 2) conv_feats: (type struct) the convolutional features of an image
% 3) boxes: a N x 4 array with the bounding box coordinates in the form of
% [x0,y0,x1,y1] (where (x0,y0) is the top-left corner and (x1,y1) the 
% bottom left corner)
% 4) random_scale: a boolean value that if set to true then each bounding
% box is projected to the convolutional features of a random scale of the
% image.
% 
% OUTPUTS: 
% 1) region_feats: is a N x F array with the region features of each of 
% the N bounding boxes. F is the number of features for the given type of region.
% 2) regions: is a N x 8 array that contains the region coordinates of each 
% of the N bounding boxes. Note that each region is represented by 8 values 
% [xo0, yo0, xo1, yo1, xi0, yi0, xi1, yi1] that correspond to its outer 
% rectangle [xo0, yo0, xo1, yo1] and its inner rectangle 
% [xi0, yi0, xi1, yi1]. 
% 
%
% This file is part of the code that implements the following ICCV2015 accepted paper:
% title: "Object detection via a multi-region & semantic segmentation-aware CNN model"
% authors: Spyros Gidaris, Nikos Komodakis
% institution: Universite Paris Est, Ecole des Ponts ParisTech
% Technical report: http://arxiv.org/abs/1505.01749
% code: https://github.com/gidariss/mrcnn-object-detection
% 
% This file is part of the code that implements the following ICCV2015 accepted paper:
% title: "Object detection via a multi-region & semantic segmentation-aware CNN model"
% authors: Spyros Gidaris, Nikos Komodakis
% institution: Universite Paris Est, Ecole des Ponts ParisTech
% Technical report: http://arxiv.org/abs/1505.01749
% code: https://github.com/gidariss/mrcnn-object-detection
% 
% Part of the code in this file come from the SPP-Net code: 
% https://github.com/ShaoqingRen/SPP_net
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

if ~exist('random_scale', 'var'), random_scale = false; end

% 
assert(all(region_params.scale_outer >= region_params.scale_inner));

assert(isfield(conv_feat, 'rsp') && ~isempty(conv_feat.rsp));
available_scales = conv_feat.scale(:)'; 
assert(length(conv_feat.rsp) == length(available_scales)); 

min_img_sz = min(conv_feat.im_height, conv_feat.im_width);

if isempty(boxes)
    region_feat = single([]);
    regions  = single([]);
    return;
end

image_size = [conv_feat.im_height, conv_feat.im_width];

%******************* EXTRACT BOUNDING BOX REGIONS *************************
boxes      = transform_bboxes(region_params, boxes);

% use default region scaling parameters if they are not specified
if isempty(region_params.scale_outer), region_params.scale_outer = 1.0; end
if isempty(region_params.scale_inner), region_params.scale_inner = 0.0; end

boxes_outer = scale_bboxes(boxes, region_params.scale_outer);
boxes_inner = scale_bboxes(boxes, region_params.scale_inner);
regions = single([boxes_outer,boxes_inner]);
%**************************************************************************

%************ PROJECT EACH REGION TO ONE OF THE IMAGE SCALES **************
expected_scale = spm_expected_scale(min_img_sz, boxes_outer, region_params);

[~, best_scale_ids] = min(abs(bsxfun(@minus, available_scales, expected_scale(:))), [], 2);   
if random_scale
    best_scale_ids      = best_scale_ids + randi([-2,2], size(best_scale_ids));
    best_scale_ids      = max(1,min(length(available_scales), best_scale_ids));
end

boxes_scales       = available_scales(best_scale_ids(:));
scaled_boxes_outer = bsxfun(@times, (boxes_outer - 1), (boxes_scales(:) - 1)) / (min_img_sz - 1) + 1;
scaled_boxes_inner = bsxfun(@times, (boxes_inner - 1), (boxes_scales(:) - 1)) / (min_img_sz - 1) + 1;
scaled_regions = [scaled_boxes_outer, scaled_boxes_inner];
%**************************************************************************

% perform the adaptive region max pooling operation on the region of each
% bounding box in order to extract the region features of them
region_feat = adaptive_region_pooling(...
    conv_feat.rsp, region_params.spm_divs, scaled_regions, best_scale_ids, ...
    region_params.offset0, region_params.offset, region_params.step_standard); 

end

function [ bboxes ] = scale_bboxes( bboxes, scale_ratio )

if numel(scale_ratio) == 1, scale_ratio(2) = scale_ratio(1); end
assert(numel(scale_ratio) == 2);
scale_ratio = single(scale_ratio);


bboxes_center      = [(bboxes(:,1)+bboxes(:,3)), (bboxes(:,2)+bboxes(:,4))]/2;
bboxes_width_half  = (bboxes(:,3) - bboxes(:,1))/2;
bboxes_width_half  = bboxes_width_half * scale_ratio(2);

bboxes_height_half = (bboxes(:,4) - bboxes(:,2))/2;
bboxes_height_half = bboxes_height_half * scale_ratio(1);

bboxes = round([bboxes_center(:,1) - bboxes_width_half, ...
                bboxes_center(:,2) - bboxes_height_half, ...
                bboxes_center(:,1) + bboxes_width_half, ...
                bboxes_center(:,2) + bboxes_height_half]);
end

function boxes = transform_bboxes(region_params, boxes)
if isfield(region_params, 'half_bbox') && ~isempty(region_params.half_bbox) && region_params.half_bbox > 0
    % take the half part each bounding box
    boxes = get_half_bbox( boxes, region_params.half_bbox );
end
end

function [ bboxes ] = get_half_bbox( bboxes, half_bbox )

assert(half_bbox >= 1 && half_bbox <= 4);

switch half_bbox
    case 1 % left half 
        bboxes_half_width = floor((bboxes(:,3) - bboxes(:,1)+1)/2);
        bboxes(:,3) = bboxes(:,1) + bboxes_half_width;
    case 2 % right half
        bboxes_half_width = floor((bboxes(:,3) - bboxes(:,1)+1)/2);
        bboxes(:,1) = bboxes(:,3) - bboxes_half_width;
    case 3 % up half
        bboxes_half_height = floor((bboxes(:,4) - bboxes(:,2)+1)/2);
        bboxes(:,4) = bboxes(:,2) + bboxes_half_height;
    case 4 % bottom half
        bboxes_half_height = floor((bboxes(:,4) - bboxes(:,2)+1)/2);
        bboxes(:,2) = bboxes(:,4) - bboxes_half_height;
end
bboxes = round(bboxes);
end

function feats_pooled = adaptive_region_pooling(feats, spm_divs, ...
    scaled_regions, best_scale_ids, offset0, offset, min_times)

feats = cellfun(@(x) single(x), feats, 'UniformOutput', false);
scaled_regions = double(scaled_regions);
boxes_outer    = scaled_regions(:,1:4)';
boxes_inner    = scaled_regions(:,5:8)';

% trans from (height, width, channel) to (channel, width, height)
feats = cellfun(@(x) permute(x, [3, 2, 1]), feats, 'UniformOutput', false);
best_scale_ids = int32(best_scale_ids);

offset0   = double(offset0);
offset    = double(offset);
min_times = double(min_times);
spm_divs  = double(spm_divs);

feats_pooled = adaptive_region_pooling_mex(...
	feats, spm_divs, boxes_outer, boxes_inner, best_scale_ids, ...
    [offset0, offset, min_times]);
end
