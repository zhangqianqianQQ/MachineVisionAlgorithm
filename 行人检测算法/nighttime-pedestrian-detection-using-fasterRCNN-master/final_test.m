function final_test(imdb,roidb)

active_caffe_mex(auto_select_gpu, 'caffe_faster_rcnn');
addpath(genpath('./external/toolbox(kaist)'));

if ~exist('imdb', 'var'), load(fullfile(pwd,'imdb','cache','imdb_kaist_test')); end
if ~exist('roidb', 'var'), load(fullfile(pwd,'imdb','cache','roidb_kaist_test')); end

model_path='./output/faster_rcnn_final';
load(fullfile(model_path,'model'));

caffe.init_log(fullfile(model_path,'caffe_log'));

feature_net = caffe.Net(fullfile(model_path,'feature_extractor.prototxt'), 'test');
feature_net.copy_from  (fullfile(model_path,proposal_detection_model.proposal_net));

rpn_net = caffe.Net(fullfile(model_path,proposal_detection_model.proposal_net_def), 'test');
rpn_net.copy_from  (fullfile(model_path,proposal_detection_model.proposal_net));

caffe.set_mode_gpu();

dt_boxes=cell(length(imdb.image_ids),1);
gt_boxes=cell(length(imdb.image_ids),1);
rpn_boxes=cell(length(imdb.image_ids),1);

for i=1:length(imdb.image_ids)
    boxes=[roidb.rois(i).boxes, roidb.rois(i).ignores];
    boxes=[boxes(:,1),boxes(:,2),boxes(:,3)-boxes(:,1),boxes(:,4)-boxes(:,2),boxes(:,5)];
    gt_boxes{i}=boxes;
end

cache_name=fullfile(pwd,'test','faster-rcnn-test3-');
% weight=[0.06136 0.24477	0.38774	0.24477	0.06136]; % sigma1
weight=[0.25,0.5,0.25];
% weight=1;
multi_frame=1;

for i=1:length(imdb.image_ids)
    th1 = tic;
    im=imread(imdb.image_at(i));
    [boxes, scores, feature] = proposal_im_detect2(proposal_detection_model.conf_proposal, feature_net, rpn_net, ...
                                                  imdb.image_at(i),multi_frame,weight);%true
    a=toc(th1);
    th2 = tic;
    rpn_box = boxes_filter([boxes, scores], 10000, 0.5, 100, false);
    rpn_boxes{i}=rpn_box;
end

caffe.reset_all(); 

feature_net = caffe.Net(fullfile(model_path,'feature_extractor.prototxt'), 'test');
feature_net.copy_from  (fullfile(model_path,proposal_detection_model.proposal_net));

fast_rcnn_net = caffe.Net(fullfile(model_path,proposal_detection_model.detection_net_def), 'test');
fast_rcnn_net.copy_from(fullfile(model_path,proposal_detection_model.detection_net));

caffe.set_mode_gpu();

for i=1:length(imdb.image_ids)
    [boxes, scores] = fast_rcnn_conv_feat_detect(proposal_detection_model.conf_detection, fast_rcnn_net, im, ...
        feature,... % 21 for pool4 removed
        rpn_boxes{i}(:,1:4));

    rcnn_boxes = boxes_filter([boxes, scores(:,2)], 100, 0.5, 10, false);
    dt_boxes{i} = rcnn_boxes;
    b=toc(th2);
    fprintf('%d, time: %.3fs, %.3fs\n', i, a, b);
end

wh_boxes=dt_boxes;
for i=1:length(imdb.image_ids)
    boxes=wh_boxes{i};
    boxes=[boxes(:,1),boxes(:,2),boxes(:,3)-boxes(:,1),boxes(:,4)-boxes(:,2),boxes(:,5)];
    wh_boxes{i}=boxes;
end

save([cache_name 'dt'],'dt_boxes');
thr=0.5; % overlap>thr�̸� TP��
mul=0;
ref=10.^(-2:.25:0);
[gt,dt] = bbGt('evalRes',gt_boxes,wh_boxes,thr,mul);
[fp,tp,score,miss] = bbGt('compRoc',gt,dt,1,ref);
miss=exp(mean(log(max(1e-10,1-miss))));

plotRoc([fp tp],'logx',1,'logy',1,'xLbl','False positives per image',...
  'lims',[3.1e-3 1e1 .05 1],'color','g','lineSt', '-','smooth',1,'fpTarget',ref);
title(sprintf('log-average miss rate = %.2f%%',miss*100));

caffe.reset_all(); 
end

function aboxes = boxes_filter(aboxes, per_nms_topN, nms_overlap_thres, after_nms_topN, use_gpu)
    % to speed up nms
    if per_nms_topN > 0
        aboxes = aboxes(1:min(length(aboxes), per_nms_topN), :);
    end
    % do nms
    if nms_overlap_thres > 0 && nms_overlap_thres < 1
        aboxes = aboxes(nms(aboxes, nms_overlap_thres, use_gpu), :);       
    end
    if after_nms_topN > 0
        aboxes = aboxes(1:min(length(aboxes), after_nms_topN), :);
    end
end

function visualizer(img,boxes)
    imshow(img); hold on;
    for i=1:size(boxes,1)
        box=boxes(i,:);
        if(box(5)<0.3), continue; end
        rectangle('Position',[box(1),box(2),box(3)-box(1),box(4)-box(2)],'EdgeColor',[1 0 0]);
        text(double(box(1)),double(box(2)),sprintf('%f',box(5)),'BackgroundColor', 'w');
    end
    hold off;
end