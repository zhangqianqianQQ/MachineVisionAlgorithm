function image_db = load_feature_paths(image_db, feat_cache_names)
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
feat_cache_directory = fullfile(pwd,'feat_cache/');

if ischar(feat_cache_names)
    feat_cache_names = {feat_cache_names};
end
assert(iscell(feat_cache_names));
num_feats = length(feat_cache_names);
image_db.feature_paths_all = cell(num_feats,1);
feat_cache_dir = {};
for f = 1:num_feats
    feat_cache_dir{f} = [feat_cache_directory, feat_cache_names{f}, filesep, image_db.image_set_name, filesep];
    feature_paths_all{f} = strcat(feat_cache_dir{f}, getImageIdsFromImagePaths( image_db.image_paths ),'.mat');
end

if num_feats == 1
    image_db.feature_paths = feature_paths_all{1};
else
    image_db.feature_paths = cell(length(feature_paths_all{1}), 1);
    for i = 1:length(image_db.feature_paths)
        image_db.feature_paths{i} = cell(num_feats,1);
        for f = 1:num_feats
            image_db.feature_paths{i}{f} = feature_paths_all{f}{i};
        end
    end
end
image_db.feat_cache_dir = feat_cache_dir;
end

