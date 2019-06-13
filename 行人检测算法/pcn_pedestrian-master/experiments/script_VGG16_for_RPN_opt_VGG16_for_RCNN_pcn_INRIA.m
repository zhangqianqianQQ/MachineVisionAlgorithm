function script_VGG16_for_RPN_opt_VGG16_for_RCNN_pcn_INRIA()
% script_VGG16_for_RPN_opt_VGG16_for_RCNN_pcn_Caltech()
% RPN training and testing with VGG16 model
% PCN training and testing with VGG16 model
% Model training and testing on Caltech Pedestrian Dataset
% --------------------------------------------------------
% PCN
% Copyright (c) 2017, Wang Shiguang
% Licensed under The MIT License [see LICENSE for details]
% --------------------------------------------------------

clc;
clear mex;
clear is_valid_handle; % to clear init_key
run(fullfile(fileparts(fileparts(mfilename('fullpath'))), 'startup'));
%% -------------------- CONFIG --------------------
% opts.caffe_version          = 'caffe';
% opts.gpu_id                 = auto_select_gpu;
% active_caffe_mex(opts.gpu_id, opts.caffe_version);

% do validation, or not 
opts.do_val                 = false; 
opts.test_after_nms_topN    = 100;

% model
model                       = Model.VGG16_for_RPN_opt_VGG16_for_RCNN_pcn;


% cache base
cache_base_proposal         = 'INRIA_VGG16_opt';
cache_base_pcn        = 'INRIA_VGG16_';
% train/test data
dataset                     = [];
use_flipped                 = true;
dataset                     = Dataset.pedestrian_trainval(dataset, 'train', use_flipped);
dataset                     = Dataset.pedestrian_test(dataset, 'test', false);

%% -------------------- TRAIN --------------------
% conf
conf_proposal               = proposal_opt_config('image_means', model.mean_image, 'feat_stride', model.feat_stride);
conf_fast_rcnn              = fast_rcnn_config('image_means', model.mean_image);
% set cache folder for each stage
model                       = Faster_RCNN_Train.set_cache_folder(cache_base_proposal, cache_base_pcn, model,dataset.imdb_train{1}.name);
% % generate anchors and pre-calculate output size of rpn network 
% [conf_proposal.anchors, conf_proposal.output_width_map, conf_proposal.output_height_map] ...
%     = proposal_prepare_anchors(conf_proposal, model.rpn.cache_name, model.rpn.test_net_def_file);
% 
% %%  proposal
% fprintf('\n***************\nproposal \n***************\n');
% % train
% model.rpn            = Faster_RCNN_Train.do_proposal_train(conf_proposal, dataset, model.rpn, opts.do_val);
% % test
% dataset.roidb_train         = cellfun(@(x, y) Faster_RCNN_Train.do_proposal_test(conf_proposal, model.rpn, x, y), dataset.imdb_train, dataset.roidb_train, 'UniformOutput', false);
% dataset.roidb_test       	= Faster_RCNN_Train.do_proposal_test(conf_proposal, model.rpn, dataset.imdb_test, dataset.roidb_test);
% save('dataset-INRIA-opt-trainval', 'dataset');
ld = load('dataset-INRIA-opt-trainval');
dataset = ld.dataset;
clear ld;
%% fast rcnn
fprintf('\n***************\nfast rcnn\n***************\n');
% stage1: train
fprintf('\n***************\nstage1\n***************\n');
model.fast_rcnn.stage1 = Faster_RCNN_Train.do_fast_rcnn_train(conf_fast_rcnn, dataset, model.fast_rcnn.stage1, opts.do_val, 1);
% stage2: train
fprintf('\n***************\nstage2\n***************\n');
model.fast_rcnn.stage2 = Faster_RCNN_Train.do_fast_rcnn_train(conf_fast_rcnn, dataset, model.fast_rcnn.stage2, opts.do_val, 2);
% % stage3: train
fprintf('\n***************\nstage3\n***************\n');
model.fast_rcnn.stage3 = Faster_RCNN_Train.do_fast_rcnn_train(conf_fast_rcnn, dataset, model.fast_rcnn.stage3, opts.do_val, 3);

%% -------------------TEST-------------------
% 
% Faster_RCNN_Train.do_fast_rcnn_test(conf_fast_rcnn, model.fast_rcnn.stage3, ...
%                                 dataset.imdb_test, dataset.roidb_test,opts.test_after_nms_topN, 3);
opts.overlap = 0.4;
opts.thresh = 0.000001;
final_test(model, dataset.imdb_test, opts);

end

function [anchors, output_width_map, output_height_map] = proposal_prepare_anchors(conf, cache_name, test_net_def_file)
    [output_width_map, output_height_map] ...                           
                                = proposal_calc_output_size(conf, test_net_def_file);
    anchors                = proposal_generate_anchors_opt(cache_name);% ...
                                    %'scales',  2.^[3:5]);
end

function final_test(model, imdb, opts)
    ld = load(fullfile(pwd, 'imdb', 'cache', ['roidb_' imdb.name '_easy']));
    rois = ld.roidb.rois;
    rpn_cache_dir = fullfile(pwd, 'output', 'rpn_cachedir', model.rpn.cache_name, imdb.name);
    ld = load(fullfile(rpn_cache_dir, ['proposal_boxes_afterNMS_' imdb.name]));
    test_box_rpn = ld.aboxes;
    test_box_rpn = cellfun(@(x) x(1:opts.test_after_nms_topN,:), test_box_rpn,'UniformOutput', false);
    pcn_stage1_cache_dir = fullfile(pwd, 'output', 'fast_rcnn_cachedir', model.fast_rcnn.stage1.cache_name, imdb.name);
    pcn_stage2_cache_dir = fullfile(pwd, 'output', 'fast_rcnn_cachedir', model.fast_rcnn.stage2.cache_name, imdb.name);
    pcn_stage3_cache_dir = fullfile(pwd, 'output', 'fast_rcnn_cachedir', model.fast_rcnn.stage3.cache_name, imdb.name);
    ld = load(fullfile(pcn_stage3_cache_dir, [imdb.name '_boxes_']));
    test_box_rcnn = ld.aboxes;
%     ld = load(fullfile(pcn_stage2_cache_dir, [imdb.name '_boxes_ps1']));
%     part_scores1_rcnn = ld.boxes_ps1;
%     ld = load(fullfile(pcn_stage2_cache_dir, [imdb.name '_boxes_ps2']));
%     part_scores2_rcnn = ld.boxes_ps2;
%     ld = load(fullfile(pcn_stage2_cache_dir, [imdb.name '_boxes_ps3']));
%     part_scores3_rcnn = ld.boxes_ps3;
    ld = load(fullfile(pcn_stage3_cache_dir, [imdb.name '_boxes_ps_lstm']));
    lstm_scores_rcnn = ld.boxes_ps_lstm;
    evaluate_box = cell(length(imdb.image_ids),1);
    
    % frame_to_video configureation
    frame_to_video = 0;
    if frame_to_video     
        videoName = 'output/ped-pcn.avi';
        fps = 6; 
        startFrame = 1050; endFrame = 1500;
        if(exist('videoName','file'))  
            delete videoName
        end  
      
        %生成视频的参数设定  
        aviobj=VideoWriter(videoName);  %创建一个avi视频文件对象，开始时其为空  
        aviobj.FrameRate=fps;  
      
        open(aviobj);%Open file for writing video data  
    end
    
    for i=1:length(imdb.image_ids)
%        evaluate_box{i}(:, 5) = 0.5*test_box_rcnn{i}(:, 5)+0.3*test_box_rpn{i}(:,5)+0.2*lstm_scores_rcnn{i};              
       evaluate_box{i}(:, 1:4) = 1.0*test_box_rcnn{i}(:, 1:4)+0.0*test_box_rpn{i}(:,1:4);
       evaluate_box{i}(:, 5) = 0.9999*test_box_rcnn{i}(:,5) + 0.0009*test_box_rpn{i}(:,5);              
%        evaluate_box{i} = test_box_rcnn{i};

       % this part code was used to evaluate part scores
       if 1
           visible_th = 0.0;
%            part_scores1_rcnn{i}(part_scores1_rcnn{i}<visible_th) = 0;
%            part_scores2_rcnn{i}(part_scores2_rcnn{i}<visible_th) = 0;
%            part_scores3_rcnn{i}(part_scores3_rcnn{i}<visible_th) = 0;
%            avg_part_score = mean([part_scores1_rcnn{i}(:,:);part_scores2_rcnn{i}(:,:);part_scores3_rcnn{i}], 1)';
           lstm_scores_rcnn{i}(lstm_scores_rcnn{i}<visible_th) = 0;
           avg_part_score = mean(lstm_scores_rcnn{i}, 1)';
           
           evaluate_box{i}(:,5) = 0.0001*avg_part_score + 1.0*evaluate_box{i}(:,5);
           % evaluate_box{i}(:,1:4) = test_box_rcnn1{i}(:,1:4);
       end
       % nms and thresh
       evaluate_box{i} = evaluate_box{i}(nms(evaluate_box{i},opts.overlap), :);
       evaluate_box{i} = evaluate_box{i}(evaluate_box{i}(:,5)>opts.thresh, :);
       %　visualization
       if 0
           figure(1); %title('UESTC-CVMI');
           im = imread(imdb.image_at(i));
           imshow(im); hold on;
                % gt boxes
           box_temp = rois(i).boxes;
%            if isempty(box_temp)
%                continue;
%            end
           for j=1:size(box_temp,1)
               x = box_temp(j,1);
               y = box_temp(j,2);
               w = box_temp(j,3) - box_temp(j,1) + 1;
               h = box_temp(j,4) - box_temp(j,2) + 1;
               rectangle('Position',[x y w h],'EdgeColor','r', 'LineWidth', 2);
           end
                % evaluate_box
           box_temp = evaluate_box{i}(evaluate_box{i}(:,end)>0.3,:);
           for j=1:size(box_temp,1)
               x = box_temp(j,1);
               y = box_temp(j,2);
               w = box_temp(j,3) - box_temp(j,1) + 1;
               h = box_temp(j,4) - box_temp(j,2) + 1;
               rectangle('Position',[x y w h],'EdgeColor','g', 'LineWidth', 2);
           end
           hold off;
       end
       % test_box_to_dt
       if strcmp('calte', imdb.name(5:9)) || strcmp('inria', imdb.name(5:9))
            evaluate_box{i}(:,1:4) = [evaluate_box{i}(:,1:2),evaluate_box{i}(:,3)-evaluate_box{i}(:,1)+1,...
                                evaluate_box{i}(:,4)-evaluate_box{i}(:,2)+1];
       end
       if strcmp('kitti', imdb.name(5:9))
           kitti_writeLabels(evaluate_box{i}, 'imdb/PCN[Ours]', imdb.image_ids{i});
       end
       % frame_to_video
       if frame_to_video
           if startFrame <= i && i <= endFrame
                text(50,50,'UESTC-CVMI', 'FontSize', 20, 'Color', 'green');
                frame_path = sprintf('output/res_show/%s.jpg', imdb.image_ids{i});
                saveas(gcf, frame_path);
                frame = imread(frame_path);
                writeVideo(aviobj, frame);  
           end
       end
    end
    try 
        close(aviobj);
    catch
        
    end
    %evaluate the miss rate or pr-recall
    if strcmp('calte', imdb.name(5:9)) || strcmp('inria', imdb.name(5:9))
        imdb_eval_caltech('pedestrian', evaluate_box, imdb.image_ids);
    end
    if strcmp('kitti', imdb.name(5:9))
        imdb_eval_voc('Pedestrian', evaluate_box , imdb, model.fast_rcnn.stage2.cache_name);
    end
end

function dt_boxes = select_boxes(dt_boxes)
    for i = 1:length(dt_boxes)
        boxes = dt_boxes{i};   
        if(isempty(boxes))               
            continue
        end
        aspect_ratio = boxes(:, 4)./boxes(:, 3);
        indx1 = find(aspect_ratio>5);
        if(~isempty(indx1))
            boxes(indx1,:) = [];
        end
        indx2 = find(boxes(:,4)<46);
        if(~isempty(indx2))
            boxes(indx2,:) = [];
        end
%         indx3 = find(boxes(:,4)>300);
%         if(~isempty(indx3))
%             boxes(indx3,:) = [];
%         end
        dt_boxes{i} = boxes;
    end
end