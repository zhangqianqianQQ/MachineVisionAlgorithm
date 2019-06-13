function all_bbox_proposals = extract_edge_boxes_from_dataset(image_db, edge_boxes_dst_file)
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

try 
    ld = load(edge_boxes_dst_file);
    all_bbox_proposals = ld.all_bbox_proposals;
catch
    edge_boxes_path = fullfile(pwd, 'external', 'edges');
    model=load(fullfile(edge_boxes_path,'models/forest/modelBsds')); model=model.model;
    model.opts.multiscale=0; model.opts.sharpen=2; model.opts.nThreads=4;

    % set up opts for edgeBoxes
    opts          = edgeBoxes;
    opts.alpha    = .65;     % step size of sliding window search
    opts.beta     = .70;     % nms threshold for object proposals
    opts.minScore = .01;     % min score of boxes to detect
    opts.maxBoxes = 2000;    % max number of boxes to detect

    chunk_size = 1000;
    num_imgs   = numel(image_db.image_paths);
    num_chunks = ceil(num_imgs/chunk_size);
    all_bbox_proposals = cell(num_imgs,1);
    
    total_num_elems = 0;
    total_time = 0;
    for chunk = 1:num_chunks
        start_idx = (chunk-1) * chunk_size + 1;
        stop_idx  = min(chunk * chunk_size, num_imgs);
        th = tic;
        all_bbox_proposals(start_idx:stop_idx) = edgeBoxes(image_db.image_paths(start_idx:stop_idx),model,opts);
        for i = start_idx:stop_idx
            boxes = single(all_bbox_proposals{i}(:,1:4));
            all_bbox_proposals{i} = [boxes(:,1:2), boxes(:,1:2) + boxes(:,3:4)-1];
            total_num_elems = total_num_elems + numel(all_bbox_proposals{i});
        end
        elapsed_time = toc(th);
        total_time = total_time + elapsed_time;
        est_rem_time = (total_time / stop_idx) * (num_imgs - stop_idx);
        est_num_bytes = (total_num_elems / stop_idx) * num_imgs * 4 / (1024*1024*1024);
        fprintf('Extract edge boxes %s %d/%d: ET %.2fmin | ETA %.2fmin | EST. NUM BYTES %.2f giga\n', ...
            image_db.image_set_name, stop_idx, num_imgs, ...
            total_time/60, est_rem_time/60, est_num_bytes);
    end
    
    save(edge_boxes_dst_file, 'all_bbox_proposals', '-v7.3');
end
end
