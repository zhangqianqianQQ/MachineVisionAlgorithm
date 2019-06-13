function fast_rcnn_rst_path = do_fast_rcnn_test(conf, model_stage, imdb, roidb, test_topN,stage)
    rois = roidb.rois;
    for i=1:length(rois)
        is_gt = rois(i).gt;
        rois(i).gt = rois(i).gt(~is_gt, :);
        rois(i).overlap = rois(i).overlap(~is_gt, :);
        rois(i).boxes = rois(i).boxes(~is_gt, :);
        rois(i).class = rois(i).class(~is_gt, :);
    end
    roidb.rois = arrayfun(@(x) struct('gt', x.gt(1:test_topN), 'overlap', x.overlap(1:test_topN), ...
            'boxes', x.boxes(1:test_topN,:), 'feat', [], 'class',x.class(1:test_topN,:) ), rois, 'UniformOutput', false);
    roidb.rois = cell2mat(roidb.rois);
    
    fast_rcnn_rst_path              = fast_rcnn_test(conf, imdb, roidb, ...
                                    'net_def_file',     model_stage.test_net_def_file, ...
                                    'net_file',         model_stage.output_model_file, ...
                                    'cache_name',       model_stage.cache_name, ...
                                    'stage',            stage);
end
