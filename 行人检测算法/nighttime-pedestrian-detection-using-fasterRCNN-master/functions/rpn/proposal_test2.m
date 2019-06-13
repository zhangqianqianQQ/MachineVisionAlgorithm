function roidb_new = proposal_test2(conf, imdb, roidb, model, str)
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
        num_images = length(imdb.image_ids);
        % all detections are collected into:
        %    all_boxes[image] = N x 5 array of detections in
        %    (x1, y1, x2, y2, score)
        aboxes = cell(num_images, 1);
        abox_deltas = cell(num_images, 1);
        aanchors = cell(num_images, 1);
        ascores = cell(num_images, 1);
        
        count = 0;
        for i = 1:num_images
            count = count + 1;
            fprintf('%s: test %d/%d ', procid(), count, num_images);
            th = tic;
            im1 = imread(imdb.image_at(i));
            [set, prev_img_path, next_img_path]=adjacent_path(imdb.image_at(i), conf.skip1_img_path);
            
            im2 = imread(prev_img_path);
            if (~exist(next_img_path, 'file'))% prev frame always exist
                im3 = im1;
            else
                im3 = imread(next_img_path);
            end
            
            if(set>=0 && set<=2 || set>=6 && set<=8) % only for day-time images
                level=randi(5);
                im1=manipulator(im1,level);
                im2=manipulator(im2,level);
                im3=manipulator(im3,level);
            end
            im1=myhisteq(im1);
            im2=myhisteq(im2);
            im3=myhisteq(im3);
            
            [boxes, scores, abox_deltas{i}, aanchors{i}, ascores{i}] = proposal_im_detect2(conf, caffe_net, im1, im2, im3);
            
            fprintf(' time: %.3fs\n', toc(th));  
            
            aboxes{i} = [boxes, scores];
        end    
        save(fullfile(cache_dir, name), 'aboxes', '-v7.3');
        
        diary off;
        caffe.reset_all(); 
        rng(prev_rng);
    end
    aboxes = boxes_filter(aboxes, model.nms.per_nms_topN, model.nms.nms_overlap_thres, model.nms.after_nms_topN, conf.use_gpu);    
    % fast r-cnn training에 쓰일 박스(ground truth box + RPN proposal box)를 합친다.
    roidb_new = roidb_from_proposal(roidb, aboxes, conf); 
end

function aboxes = boxes_filter(aboxes, per_nms_topN, nms_overlap_thres, after_nms_topN, use_gpu)
    % to speed up nms
    if per_nms_topN > 0 % score 상위 N개의 박스만 남김(속도를 위해 우선적으로 선별)
        aboxes = cellfun(@(x) x(1:min(length(x), per_nms_topN), :), aboxes, 'UniformOutput', false);
    end
    % do nms( IoU > nms_overlap_thres 인 box 집합중에 score가 가장 큰것만
    % 남김(non-maximum suppression)
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
    aver_boxes_num = mean(cellfun(@(x) size(x, 1), aboxes, 'UniformOutput', true));% 모든 이미지의 평균 box 개수
    fprintf('aver_boxes_num = %d, select top %d\n', round(aver_boxes_num), after_nms_topN);
    if after_nms_topN > 0 % 최종적으로 N개의 박스만 남김
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

% add new proposal boxes (새로운 RPN proposal box를 추가한다)
% ground truth와 IoU > 0.5 이면 positive sample for fast r-cnn training
% ground truth와 0.1 < IoU < 0.5 이면 hard negative sample
% ignore 제외한 proposal만 사용
for i = 1:length(roidb.rois)  
    boxes = aboxes{i}(:, 1:4);
    ig_ind=roidb.rois(i).ignores;
    ignore_boxes=roidb.rois(i).boxes(ig_ind==1,:);
    gt_boxes=roidb.rois(i).boxes(ig_ind==0,:);
    
    if(~isempty(ignore_boxes))
        overlap = max( boxoverlap(boxes, ignore_boxes) ,[],2);
        ind=find(overlap < conf.bg_thresh_hi & overlap >= conf.bg_thresh_lo);
        boxes=boxes(ind,:);% ignore box과 겹치는 proposal은 negative or positive가 될수없으므로 버린다.
    end
    
    if(~isempty(gt_boxes))
        overlap = max( boxoverlap(boxes, gt_boxes) ,[],2);
    else
        overlap = zeros(size(boxes,1),1);% 어떤 이미지에서 gt_box가 없으면 overlap은 모두 0이다.
    end
    
    
    boxes = [[gt_boxes, ones(size(gt_boxes,1),1)]; [boxes, overlap]];
    
    roidb.rois(i).proposals=boxes; % proposals 속성이 없다면 새로만들고, 이미 있다면 boxes로 덮어쓴다.
end

end