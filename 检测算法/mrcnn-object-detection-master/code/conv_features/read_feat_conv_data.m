function feat_data = read_feat_conv_data( feature_path, to_cell )
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


if iscell(feature_path)
    if ~exist('to_cell','var')
        to_cell = true;
    end
    if  to_cell
        feat_data = load(feature_path{1});
        tmp = feat_data.feat;
        feat_data.feat(1) = [];
        feat_data = rmfield(feat_data,'feat');
        feat_data.feat{1} = tmp;
        for i = 2:length(feature_path)
            tmp  = load(feature_path{i});
            feat_data.feat{i} = tmp.feat;
        end
    else
        feat_data = load(feature_path{1});
        for i = 2:length(feature_path)
            tmp  = load(feature_path{i});
            feat_data.feat(i) = tmp.feat;
        end
    end
else
    feat_data = load(feature_path);
end
end
