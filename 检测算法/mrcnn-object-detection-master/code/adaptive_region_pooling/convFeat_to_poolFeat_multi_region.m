function [region_feats, regions] = convFeat_to_poolFeat_multi_region(...
    multiple_region_params, conv_feats, boxes, random_scale)
% convFeat_to_poolFeat_multi_region given the convolutional features of an 
% image, it adaptively pools fixed size region features for each bounding 
% box and for multiple type of regions. 
% 
% INPUTS:
% 1) multiple_region_params: is a M x 1 vector of objects of type struct that 
% specify the region pooling parameters for each of the M types of regions
% 2) conv_feats: is a K x 1 cell vector or vector of objects, with K >=1 
% different type of convolutional features.
% 3) boxes: a N x 4 array with the bounding box coordinates in the form of
% [x0,y0,x1,y1] (where (x0,y0) is the top-left corner and (x1,y1) the 
% bottom left corner)
% 4) random_scale: a boolean value that if set to true then each bounding
% box is projected to the convolutional features of a random scale of the
% image.
% 
% OUTPUTS: 
% 1) region_feats: is a M x 1 cell array where region_feats{i} is a N x F_i
% array with the region features of each of the N bounding boxes for the 
% i-th type of region. F_i is the number of features of the i-th type of
% region.
% 2) regions: is a M x 1 cell array with the region coordinates of each 
% bounding box and for each type of region. Specifically, regions{i} is a
% N x 8 array that contains the region coordinates of each of the N bounding
% boxes for the i-th type of region. Note that each region is represented 
% by 8 values [xo0, yo0, xo1, yo1, xi0, yi0, xi1, yi1] that correspond to
% its outer rectangle [xo0, yo0, xo1, yo1] and its inner rectangle 
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
% Part of the code in this file comes from the SPP-Net code: 
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

num_regions  = length(multiple_region_params);
region_feats = cell(num_regions,1);
regions      = cell(num_regions,1);

for p = 1:num_regions, region_feats{p} = single([]); end
for p = 1:num_regions, regions{p}   = single([]); end

if isempty(boxes), return; end

% pool the region features the bounding boxes for each type of region
if length(conv_feats) == 1
    for p = 1:num_regions 
        [region_feats{p}, regions{p}] = convFeat_to_poolFeat(...
            multiple_region_params(p), conv_feats, boxes, random_scale);
    end
else
    if iscell(conv_feats)
        for p = 1:num_regions 
            [region_feats{p}, regions{p}]  = convFeat_to_poolFeat(...
                multiple_region_params(p), conv_feats{multiple_region_params(p).feat_id}, ...
                boxes, random_scale);
        end         
    elseif isstruct(conv_feats)
        for p = 1:num_regions 
            [region_feats{p}, regions{p}]  = convFeat_to_poolFeat(...
                multiple_region_params(p), conv_feats(multiple_region_params(p).feat_id), ...
                boxes, random_scale);
        end        
    end
end
end
