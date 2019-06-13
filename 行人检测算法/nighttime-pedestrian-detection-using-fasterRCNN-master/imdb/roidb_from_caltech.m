function roidb = roidb_from_caltech(root, imdb, pLoad)
% roidb = roidb_from_caltech(imdb, flip)
%   Package the roi annotations into the imdb. 
%
%   Inspired by Ross Girshick's imdb and roidb code.

% AUTORIGHTS
% ---------------------------------------------------------
% Copyright (c) 2014, Ross Girshick
% 
% This file is part of the R-CNN code and is available 
% under the terms of the Simplified BSD License provided in 
% LICENSE. Please retain this notice and LICENSE if you use 
% this file (or any portion of it) in your project.
% ---------------------------------------------------------

roidb.name = imdb.name;

anno_path = fullfile(root,roidb.name,'caltech','annotations');
% prop_path = ['./datasets/caltech/' roidb.name '/proposals'];

% externel 과 imageset 폴더의 bbGt 함수의 기준이 caltech과 kaist에서 다르므로 주의
% addpath(genpath('./external/code3.2.1/code3.2.1')); 
% addpath(genpath('./external/toolbox'));
% lbls는 gt, ilbls는 ignore, squarify에 맞게 bounding box를 reshape


cache_file = ['./imdb/cache/roidb_caltech_' imdb.name];
%cache_file = [cache_file, '.mat'];

try
  load(cache_file);
catch
  fprintf('Loading region proposals...');
  
  height = imdb.sizes(1,1);
  width = imdb.sizes(1,2);
  %files=bbGt('getFiles',{anno_path});% annotation 파일 이름들을 모두 files에 저장
  
  
  num_gts = 0;
  num_gt_no_ignores = 0;
  
  for i = 1:length(imdb.image_ids)
      id=imdb.image_ids{i};
      if(contains(id,'_flip')), flip=true;
      else, flip=false; end
      
      id=strrep(id,'AtoB_','');
      id=strrep(id,'BtoA_','');
      id=strrep(id,'_flip','');
      
      path=fullfile(anno_path, strcat(id,'.txt'));
      
      tic_toc_print('%d / %d\n', i, length(imdb.image_ids));
      [~,gts]=bbGt('bbLoad',path,pLoad); % gts: [nx5] array containg ground truth bbs [x y w h ignore]
      ignores = gts(:,end);
      num_gts  = num_gts + length(ignores);
      num_gt_no_ignores  = num_gt_no_ignores + (length(ignores)-sum(ignores));
      
      for j=1:size(gts,1)
          gts(j,2)=gts(j,2)/480*512;
          gts(j,4)=gts(j,4)/480*512;
      end
      
      if flip
          % for flip
          x1_flip = width - gts(:,1) - gts(:,3);
          y1_flip = y1;
          x2_flip = width - gts(:,1);
          y2_flip = y2;
          gt_boxes_flip = [x1_flip y1_flip x2_flip y2_flip];
          roidb.rois(i) = attach_rois([],gt_boxes_flip, ignores);
      else
          % for ori
          x1 = gts(:,1);
          y1 = gts(:,2);
          x2 = gts(:,1) + gts(:,3);
          y2 = gts(:,2) + gts(:,4);
          gt_boxes = [x1 y1 x2 y2]; % [xmin, ymin, xmax, ymax]
          roidb.rois(i) = attach_rois([],gt_boxes, ignores); 
      end
  end
  

  fprintf('Saving roidb to cache...');
  save(cache_file, 'roidb', '-v7.3');
  fprintf('done\n');
  
  fprintf('num_gt / num_ignore %d / %d \n', num_gt_no_ignores, num_gts);
end


% ------------------------------------------------------------------------
function rec = attach_rois(boxes, gt_boxes, ignores)
% ------------------------------------------------------------------------

%           gt: [2108x1 double]
%      overlap: [2108x20 single]
%      dataset: 'voc_2007_trainval'
%        boxes: [2108x4 single]
%         feat: [2108x9216 single]
%        class: [2108x1 uint8]


all_boxes = cat(1, gt_boxes, boxes);
gt_classes = ones(size(gt_boxes, 1), 1); % set pedestrian label as 1
num_gt_boxes = size(gt_boxes, 1);

num_boxes = size(boxes, 1);

rec.gt = cat(1, true(num_gt_boxes, 1), false(num_boxes, 1));
rec.overlap = zeros(num_gt_boxes+num_boxes, 1, 'single');
for i = 1:num_gt_boxes
  rec.overlap(:, gt_classes(i)) = ...
      max(rec.overlap(:, gt_classes(i)), boxoverlap(all_boxes, gt_boxes(i, :)));
end
rec.boxes = single(all_boxes);
rec.feat = [];
rec.class = uint8(cat(1, gt_classes, zeros(num_boxes, 1)));

rec.ignores = ignores;
