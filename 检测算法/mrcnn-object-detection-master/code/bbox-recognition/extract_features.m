function [ feats, feats_pool ] = extract_features( model, in, bboxes, feat_blob_name )
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

if ~isempty(bboxes)
    feats_pool = convFeat_to_poolFeat_multi_region(model.pooler, in, bboxes(:,1:4));
    [outputs, out_blob_names_total] = caffe_forward_net(model.net, feats_pool, feat_blob_name);
    idx = find(strcmp(out_blob_names_total,feat_blob_name));
    assert(numel(idx) == 1);
    feats = outputs{idx};
else
    feats_pool = {};
    feats = single([]);
end

end
