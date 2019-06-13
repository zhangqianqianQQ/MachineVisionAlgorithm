function all_box_proposals = load_box_proposals( image_db, method )
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


base_directory = fullfile(pwd,'data/');
mkdir_if_missing(base_directory);

selective_search_path       = fullfile(base_directory, 'selective_search_data/');
edge_boxes_path             = fullfile(base_directory, 'edge_boxes_data/');
voc_path                    = [pwd, '/datasets/VOC%s/'];

if ischar(method), method = {method}; end
assert(iscell(method));
num_methods = numel(method);
all_box_proposals_methods = cell(num_methods,1);

image_set_name = image_db.image_set_name;

for m = 1:num_methods
    switch method{m}
        case 'selective_search'
            mkdir_if_missing(selective_search_path);
            proposals_path = sprintf('%s/%s.mat', selective_search_path, image_set_name);
            all_box_proposals = extract_selective_search_boxes_from_dataset(...
                image_db, proposals_path);    
        case 'edge_boxes'
            mkdir_if_missing(edge_boxes_path);
            proposals_path = sprintf('%s/%s.mat', edge_boxes_path, image_set_name);
            all_box_proposals = extract_edge_boxes_from_dataset(image_db, proposals_path);             
        otherwise
            error('not supported option')
    end
    all_box_proposals_methods{m} = all_box_proposals;
end
all_box_proposals = merge_bboxes(all_box_proposals_methods);
end

function all_box_proposals = merge_bboxes(all_box_proposals_methods)

num_methods  = length(all_box_proposals_methods);
num_imgs     = length(all_box_proposals_methods{1});

if num_methods == 1
    all_box_proposals = all_box_proposals_methods{1};
    return;
end
all_box_proposals   = cell(num_imgs, 1);

for i = 1:num_imgs
    aboxes_this_img_this = cell(num_methods, 1);
    for d = 1:num_methods
        aboxes_this_img_this{d} = all_box_proposals_methods{d}{i};
    end
    all_box_proposals{i} = cell2mat(aboxes_this_img_this);
end

end
