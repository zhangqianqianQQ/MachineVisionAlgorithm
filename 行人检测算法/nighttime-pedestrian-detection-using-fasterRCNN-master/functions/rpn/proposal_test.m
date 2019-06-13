function roidb_new = proposal_test(conf, imdb, roidb, model, str)
% aboxes = proposal_test(conf, imdb, varargin)
% --------------------------------------------------------
% Faster R-CNN
% Copyright (c) 2015, Shaoqing Ren
% Licensed under The MIT License [see LICENSE for details]
% --------------------------------------------------------   

%% inputs
    cache_dir = fullfile(model.cache_name,'test');
    name = strcat('proposal_boxes_',str);
    try
        
        % try to load cache
        ld = load(fullfile(cache_dir, name));
        aboxes = ld.aboxes;
        clear ld;
    catch    
%% init net
        % init caffe net
        mkdir_if_missing(cache_dir);
        caffe_log_file_base = fullfile(cache_dir, 'caffe_log');
        caffe.init_log(caffe_log_file_base);
        caffe_net = caffe.Net(model.test_net_def_file, 'test');
        caffe_net.copy_from(model.output_model_file);

        % init log
        timestamp = datestr(datevec(now()), 'yyyymmdd_HHMMSS');
        mkdir_if_missing(fullfile(cache_dir, 'log'));
        log_file = fullfile(cache_dir, 'log', [str, timestamp, '.txt']);
        diary(log_file);

        % set random seed
        prev_rng = seed_rand(conf.rng_seed);
        caffe.set_random_seed(conf.rng_seed);

        % set gpu/cpu
        if conf.use_gpu
            caffe.set_mode_gpu();
        else
            caffe.set_mode_cpu();
        end             
        
        disp('conf:');
        disp(conf);
    
%% testing
        num_images=0;
        for i=1:length(imdb)
            num_images = num_images+length(imdb(i).image_ids);
        end
        % all detections are collected into:
        %    all_boxes[image] = N x 5 array of detections in
        %    (x1, y1, x2, y2, score)
        aboxes = cell(num_images, 1);
        
        count = 0;
        for i=1:length(imdb)
        for j=1:length(imdb(i).image_ids)
            count = count + 1;
            fprintf('%s: test %d/%d ', procid(), count, num_images);
            th = tic;
            [boxes, scores, ~, ~, ~] = proposal_im_detect(conf, caffe_net, imdb(i).image_at(j), model.multi_frame);
            
            fprintf(' time: %.3fs\n', toc(th));  
            
            aboxes{count} = [boxes, scores];
        end    
        end
        save(fullfile(cache_dir, name), 'aboxes', '-v7.3');
        
        diary off;
        caffe.reset_all(); 
        rng(prev_rng);
    end
    aboxes = boxes_filter(aboxes, model.nms.per_nms_topN, model.nms.nms_overlap_thres, model.nms.after_nms_topN, conf.use_gpu);    
    % ground truth box + RPN proposal box
    roidb_new = roidb_from_proposal(roidb, aboxes, conf); 
end

function aboxes = boxes_filter(aboxes, per_nms_topN, nms_overlap_thres, after_nms_topN, use_gpu)
    % to speed up nms
    if per_nms_topN > 0
        aboxes = cellfun(@(x) x(1:min(length(x), per_nms_topN), :), aboxes, 'UniformOutput', false);
    end

    if nms_overlap_thres > 0 && nms_overlap_thres < 1
        if use_gpu
            for i = 1:length(aboxes)
                aboxes{i} = aboxes{i}(nms(aboxes{i}, nms_overlap_thres, use_gpu), :);
            end 
        else
            parfor i = 1:length(aboxes)
                aboxes{i} = aboxes{i}(nms(aboxes{i}, nms_overlap_thres), :);
            end       
        end
    end
    aver_boxes_num = mean(cellfun(@(x) size(x, 1), aboxes, 'UniformOutput', true));
    fprintf('aver_boxes_num = %d, select top %d\n', round(aver_boxes_num), after_nms_topN);
    if after_nms_topN > 0
        aboxes = cellfun(@(x) x(1:min(length(x), after_nms_topN), :), aboxes, 'UniformOutput', false);
    end
end

function roidb = roidb_from_proposal(roidb, aboxes, conf)
% roidb = roidb_from_proposal(imdb, roidb, regions, varargin)s
% --------------------------------------------------------
% Faster R-CNN
% Copyright (c) 2015, Shaoqing Ren
% Licensed under The MIT License [see LICENSE for details]
% --------------------------------------------------------

% add new proposal boxes
count=0;
for i = 1:length(roidb)
for j = 1:length(roidb(i).rois)  
    count=count+1;
    boxes = aboxes{count}(:, 1:4);
    ig_ind=roidb(i).rois(j).ignores;
    ignore_boxes=roidb(i).rois(j).boxes(ig_ind==1,:);
    gt_boxes=roidb(i).rois(j).boxes(ig_ind==0,:);
    
    % proposal boxes that overlapped with ignore box are discarded
    % because they cannot be either positive or negative
    if(~isempty(ignore_boxes))
        overlap = max( boxoverlap(boxes, ignore_boxes) ,[],2);
        ind=find(overlap < conf.bg_thresh_hi & overlap >= conf.bg_thresh_lo);
        boxes=boxes(ind,:);
    end
    if(~isempty(gt_boxes))
        overlap = max( boxoverlap(boxes, gt_boxes) ,[],2);
    else
        overlap = zeros(size(boxes,1),1);
    end
    
    boxes = [[gt_boxes, ones(size(gt_boxes,1),1)]; [boxes, overlap]];
    
    roidb(i).rois(j).proposals=boxes;
end
end
end