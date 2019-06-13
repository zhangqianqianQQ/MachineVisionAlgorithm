function model = set_cache_folder(model)
% model = set_cache_folder(cache_base_proposal, cache_base_fast_rcnn, model)
% --------------------------------------------------------
% Faster R-CNN
% Copyright (c) 2015, Shaoqing Ren
% Licensed under The MIT License [see LICENSE for details]
% --------------------------------------------------------
    
    model.stage1_rpn.cache_name = fullfile(pwd,'output','rpn','stage1');

    model.stage1_fast_rcnn.cache_name = fullfile(pwd,'output','fast_rcnn','stage1');

    model.stage2_rpn.cache_name = fullfile(pwd,'output','rpn','stage2');

    model.stage2_fast_rcnn.cache_name = fullfile(pwd,'output','fast_rcnn','stage2');

    model.final_model.cache_name = fullfile(pwd,'output','final');
end