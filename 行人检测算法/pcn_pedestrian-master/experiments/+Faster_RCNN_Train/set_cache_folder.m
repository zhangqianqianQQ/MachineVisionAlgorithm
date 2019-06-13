function model = set_cache_folder(cache_base_proposal, cache_base_fast_rcnn, model, cache_dataset)
% model = set_cache_folder(cache_base_proposal, cache_base_fast_rcnn, model)
% --------------------------------------------------------
% Faster R-CNN
% Copyright (c) 2015, Shaoqing Ren
% Licensed under The MIT License [see LICENSE for details]
% --------------------------------------------------------

    model.rpn.cache_name = cache_base_proposal;

    model.fast_rcnn.stage1.cache_name = [cache_base_fast_rcnn 'stage1'];
    
    model.fast_rcnn.stage2.cache_name = [cache_base_fast_rcnn 'stage2'];
    model.fast_rcnn.stage2.init_net_file = sprintf(model.fast_rcnn.stage2.init_net_file,...
                                           model.fast_rcnn.stage1.cache_name, cache_dataset);

    model.fast_rcnn.stage3.cache_name = [cache_base_fast_rcnn 'stage3'];
    model.fast_rcnn.stage3.init_net_file = sprintf(model.fast_rcnn.stage3.init_net_file,...
                                         model.fast_rcnn.stage2.cache_name, cache_dataset);

end