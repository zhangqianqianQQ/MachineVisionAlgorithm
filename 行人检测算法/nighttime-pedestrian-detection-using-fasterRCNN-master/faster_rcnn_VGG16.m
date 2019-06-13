function faster_rcnn_VGG16()
% script_faster_rcnn_VOC2007_ZF()
% Faster rcnn training and testing with Zeiler & Fergus model
% --------------------------------------------------------
% Faster R-CNN
% Copyright (c) 2015, Shaoqing Ren
% Licensed under The MIT License [see LICENSE for details]
% --------------------------------------------------------

clc;
clear mex;
clear is_valid_handle; % to clear init_key
run('startup');
%% -------------------- CONFIG --------------------
active_caffe_mex(auto_select_gpu, 'caffe_faster_rcnn'); 
opts.val_interval = 8;
opts.fg_image_ratio = 1; 
img_path = './datasets';
% this path is used only when fusing features in test time.
skip1_img_path='./datasets/skip1'; 

dataset = Dataset.KAIST_DB(img_path);
% caltech images were resized from 640x480 to 640x512 to fit to KAIST images
% ,so ground truth coordinates are modified correspondingly
dataset = Dataset.Caltech_DB(img_path,dataset);
% extract images that contain at least one reasonable pedestrian
dataset = extract_pos_train_dataset(dataset);

model = Model.VGG_for_Faster_RCNN_KAIST;
model = Faster_RCNN_Train.set_cache_folder(model);

[conf_proposal, conf_fast_rcnn] = set_configurations(model, skip1_img_path);

%%  stage one proposal
fprintf('\n***************\nstage one proposal \n***************\n');
model.stage1_rpn = proposal_train(conf_proposal, dataset, model.stage1_rpn, opts);
dataset.roidb_train   = proposal_test(conf_proposal, dataset.imdb_train, dataset.roidb_train, model.stage1_rpn, 'train');
save('stage1_dataset','dataset');
%%  stage one fast rcnn (use proposal boxes from RPN test)
fprintf('\n***************\nstage one fast rcnn\n***************\n');
model.stage1_fast_rcnn = fast_rcnn_train(conf_fast_rcnn, dataset, model.stage1_fast_rcnn, opts);
%%  stage two proposal
fprintf('\n***************\nstage two proposal\n***************\n');
model.stage2_rpn.init_net_file = model.stage1_fast_rcnn.output_model_file;
model.stage2_rpn = proposal_train(conf_proposal, dataset, model.stage2_rpn, opts);
dataset.roidb_train = proposal_test(conf_proposal, dataset.imdb_train, dataset.roidb_train, model.stage2_rpn, 'train');
%%  stage two fast rcnn
fprintf('\n***************\nstage two fast rcnn\n***************\n');
model.stage2_fast_rcnn.init_net_file = model.stage1_fast_rcnn.output_model_file;
model.stage2_fast_rcnn = fast_rcnn_train(conf_fast_rcnn, dataset, model.stage2_fast_rcnn, opts);
save('stage2_dataset','dataset');
%% save final models, for outside tester
Faster_RCNN_Train.gather_rpn_fast_rcnn_models(conf_proposal, conf_fast_rcnn, model);
end

function [conf_proposal, conf_fast_rcnn] = set_configurations(model, path)
    
    conf_fast_rcnn = fast_rcnn_config('image_means', model.mean_image);
    conf_fast_rcnn.skip1_img_path=path;
    
    conf_proposal  = proposal_config_kaist('image_means', model.mean_image, 'feat_stride', model.feat_stride);
    conf_proposal.skip1_img_path=path;
    
    input = [conf_proposal.max_size conf_proposal.scales];
    output = ceil(input/model.feat_stride);
    conf_proposal.output_width_map = containers.Map(input, output);
    conf_proposal.output_height_map = containers.Map(input, output);
    
    conf_proposal.anchors = proposal_generate_anchors_kaist(model.stage1_rpn.cache_name,...
                            'scales',  2.6*(1.3.^(0:8)), 'ratios', [1 / 0.41]);
end

function dataset = extract_pos_train_dataset(dataset)
    for db=1:2
        id=[];
        for i=1:length(dataset.roidb_train(db).rois)
            if(sum(dataset.roidb_train(db).rois(i).ignores==0)>0)
                id=[id,i];
            end
        end
        dataset.imdb_train(db).image_ids = dataset.imdb_train(db).image_ids(id);
        dataset.imdb_train(db).sizes = dataset.imdb_train(db).sizes(id,:);
        dataset.roidb_train(db).rois=dataset.roidb_train(db).rois(id);
        dataset.imdb_train(db).image_at = @(i) fullfile(dataset.imdb_train(db).image_dir, ...
                                                [dataset.imdb_train(db).image_ids{i} dataset.imdb_train(db).extension]);
    end
end