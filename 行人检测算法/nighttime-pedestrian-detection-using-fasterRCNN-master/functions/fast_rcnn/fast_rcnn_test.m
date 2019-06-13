function mAP = fast_rcnn_test(conf, model, imdb, roidb)
% mAP = fast_rcnn_test(conf, imdb, roidb, varargin)
% --------------------------------------------------------
% Fast R-CNN
% Reimplementation based on Python Fast R-CNN (https://github.com/rbgirshick/fast-rcnn)
% Copyright (c) 2015, Shaoqing Ren
% Licensed under The MIT License [see LICENSE for details]
% --------------------------------------------------------   

%%  set cache dir
    cache_dir = fullfile(model.cache_name,'test');
    mkdir_if_missing(cache_dir);

%%  init log
    timestamp = datestr(datevec(now()), 'yyyymmdd_HHMMSS');
    mkdir_if_missing(fullfile(cache_dir, 'log'));
    log_file = fullfile(cache_dir, 'log', ['test', timestamp, '.txt']);
    diary(log_file);
    
    num_images = length(imdb.imgs);
    
    try
        load(fullfile(cache_dir, 'pred_boxes'));
    catch    
%%      testing 
        % fast r_cnn 결과로 나온 box들중 overlap이 threshold 이상인 box들은 non-maximum suppression 처리
        nmsOverlap = 0.3; 
        % init caffe net
        caffe_log_file_base = fullfile(cache_dir, 'caffe_log');
        caffe.init_log(caffe_log_file_base);
        caffe_net = caffe.Net(model.test_net_def_file, 'test');
        caffe_net.copy_from(model.output_model_file);

        % set random seed
        prev_rng = seed_rand(conf.rng_seed);
        caffe.set_random_seed(conf.rng_seed);

        % set gpu/cpu
        if conf.use_gpu
            caffe.set_mode_gpu();
        else
            caffe.set_mode_cpu();
        end             

        % determine the maximum number of rois in testing 
        max_rois_num_in_gpu = check_gpu_memory(conf, caffe_net);

        disp('conf:');
        disp(conf);

        pred_boxes = cell(length(imdb.imgs),1);
        
    
        count = 0;
        t_start = tic;
        for i = 1:num_images
            count = count + 1;
            fprintf('%s: test %d/%d ', procid(), count, num_images);
            th = tic;
            % d의 5번째 열에는 ground truth와의 overlap 정도가 저장되있다.
            % overlap=1인 경우는 ground truth roi 
            % ground truth roi는 fast_rcnn training시에는 사용될수 있지만,
            % test를 할때는 사용하지 않아야 한다.
            roi = roidb{i};
            gt_ind = roi(:,5)==1;
            roi = roi(~gt_ind,1:4);
            im = imread(imdb.imgs{i});

            [boxes, scores] = fast_rcnn_im_detect(conf, caffe_net, im, roi, max_rois_num_in_gpu);
            % scores(:,1)은 non-human일 확률, scores(:,2)는 human일 확률이므로,
            % scores(:,2)>0.5 인 경우만 저장
            % ind = find(scores(:,2)>0.5);
            % pred_box = [boxes(ind,:), scores(ind,2)];
            pred_box = [boxes, scores(:,2)];
            % 0.3 의 overlap된 score box들중 non-maximum box는 reject
            keep = nms(pred_box, nmsOverlap);
            pred_box = pred_box(keep,:);
            
            % 각 이미지에서 ground truth box와 predict box를 저장한다.
            
            pred_boxes{i} = pred_box;
            fprintf(' time: %.3fs\n', toc(th)); 
        end
        
        save_file = fullfile(cache_dir,'pred_boxes');
        save(save_file,'pred_boxes');
        fprintf('test all images in %f seconds.\n', toc(t_start));
        
        caffe.reset_all(); 
        rng(prev_rng);
    end

    % ------------------------------------------------------------------------
    % Peform AP evaluation
    % ------------------------------------------------------------------------
    gt_boxes = cell(length(imdb.imgs),1);
    for i = 1:num_images
        roi = roidb{i};
        gt_ind = roi(:,5)==1; % overlap=1인 경우 ground truth이다.
        gt_boxes{i} = roi(gt_ind,1:4);
    end
    
    ap = compute_AP(pred_boxes, gt_boxes);

    if ~isempty(ap)
        fprintf('\n~~~~~~~~~~~~~~~~~~~~\n');
        fprintf('mAP:\n');
        %aps = [res(:).ap]' * 100;
        mAP = ap * 100; % 1 class 이기때문에 하나의 스칼라 값을 갖음
        disp(mAP);
        fprintf('~~~~~~~~~~~~~~~~~~~~\n');
    else
        mAP = nan;
    end

    diary off;
    
end

function ap=compute_AP(pred_boxes, gt_boxes)
    
    MinOverlap = 0.5;
    im_num = length(pred_boxes);
    pred_vec = [];
    for i=1:im_num
        boxes = pred_boxes{i};
        box_num = size(boxes,1);
        % boxes_vec(i,:) = [BB, score, im_id], 여기서 i는 i번째 이미지
        pred_vec = [pred_vec; [boxes, ones(box_num,1)*i]];
    end
    
    [~, inds] = sort(-pred_vec(:,5)); % score가 큰 순서대로 정렬
    pred_vec = pred_vec(inds,:);
    
    npos=0;
    for i=1:im_num
        gt_num = size(gt_boxes{i},1);
        % 0을 5번째 열에 넣음으로써 pred_box와 아직 matching되지 않았음을 표시
        gt_boxes{i} = [gt_boxes{i}, zeros(gt_num,1)];
        npos=npos+gt_num;% number of positive bbox(tp+fn)
    end

    npred=size(pred_vec,1);
    tp=zeros(npred,1);
    fp=zeros(npred,1);
    for d=1:npred % 모든 pred_box들에 대해서
        pred_box=pred_vec(d,1:4);
        img_id=pred_vec(d,6);
        im_gts=gt_boxes{img_id};% 한 이미지내의 ground truth
        ovmax=-inf;
        for j=1:size(im_gts,1)% 현재 pred_box가 속한 이미지 내의 ground truth box들에 대해서
            gt_box=im_gts(j,1:4);
            
            bi=[max(pred_box(1),gt_box(1)) ; max(pred_box(2),gt_box(2)) ;...
                min(pred_box(3),gt_box(3)) ; min(pred_box(4),gt_box(4))];
            iw=bi(3)-bi(1)+1;
            ih=bi(4)-bi(2)+1;
            if iw>0 && ih>0                
                % compute overlap as area of intersection / area of union
                pred_area = (pred_box(3)-pred_box(1)+1)*(pred_box(4)-pred_box(2)+1);
                gt_area = (gt_box(3)-gt_box(1)+1)*(gt_box(4)-gt_box(2)+1);
                intersection = iw*ih;
                union = pred_area + gt_area - intersection;
                
                ov=intersection/union;
                if ov>ovmax
                    ovmax=ov;
                    jmax=j;
                end
            end
        end
        
        if ovmax>=MinOverlap
            if ~im_gts(jmax,5)
                tp(d)=1;% pred_box와 ground truth box가 매칭되었으므로 true positive 
                gt_boxes{img_id}(jmax,5)=1;% true값을 넣음으로써, pred_box와 이미 matching된 ground truth임을 표시
            else
                fp(d)=1; % false positive (multiple detection)
            end
        else
            fp(d)=1; % false positive
        end
    end
    % predict box를 confidence의 크기에 따라 정렬했다.
    % 그리고 predict box 각각이 tp인지 혹은 fp인지를 정했다.
    % 그리고 cumsum을 통해 누적하여 recall(rec), precision(prec)의 배열을 구했으므로,
    % 각 배열의 요소은 confidence의 크기에 따라 reject 되고 남은 predict box들의
    % recall,precision 값들(점들)으로 생각할수 있다.
    % compute precision/recall
    fp=cumsum(fp);
    tp=cumsum(tp);
    rec=tp/npos; % recall = tp/(tp+fn) = tp/npos, npos:모든 이미지의 ground truth 개수
    prec=tp./(fp+tp); % precision = tp/(fp+tp)

    % compute average precision
    % recall, precision 점들을 평면에 뿌리고, recall=0:0.1:1로 나눠서,
    % 각 부분에서의 max precision 값을 평균하여 average precision을 구했다.
    ap=0;
    for t=0:0.1:1
        p=max(prec(rec>=t));
        if isempty(p)
            p=0;
        end
        ap=ap+p/11;
    end
end

function max_rois_num = check_gpu_memory(conf, caffe_net)
%%  try to determine the maximum number of rois

    max_rois_num = 0;
    for rois_num = 500:500:5000
        % generate pseudo testing data with max size
        im_blob = single(zeros(conf.max_size, conf.max_size, 3, 1));
        rois_blob = single(repmat([0; 0; 0; conf.max_size-1; conf.max_size-1], 1, rois_num));
        rois_blob = permute(rois_blob, [3, 4, 1, 2]);

        net_inputs = {im_blob, rois_blob};

        % Reshape net's input blobs
        caffe_net.reshape_as_input(net_inputs);

        caffe_net.forward(net_inputs);
        gpuInfo = gpuDevice();

        max_rois_num = rois_num;
            
        if gpuInfo.FreeMemory < 2 * 10^9  % 2GB for safety
            break;
        end
    end

end


% ------------------------------------------------------------------------
function [boxes, box_inds, thresh] = keep_top_k(boxes, box_inds, end_at, top_k, thresh)
% ------------------------------------------------------------------------
    % Keep top K
    X = cat(1, boxes{1:end_at});
    if isempty(X)
        return;
    end
    scores = sort(X(:,end), 'descend');
    thresh = scores(min(length(scores), top_k));
    for image_index = 1:end_at
        if ~isempty(boxes{image_index})
            bbox = boxes{image_index};
            keep = find(bbox(:,end) >= thresh);
            boxes{image_index} = bbox(keep,:);
            box_inds{image_index} = box_inds{image_index}(keep);
        end
    end
end