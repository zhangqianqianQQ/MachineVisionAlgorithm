function res = imdb_eval_caltech(cls, dt_boxes, imnames)

conf.network = 'VGG16';
conf.scale = 1; %[0.5,1,2]
if conf.scale<1
    part = 'SP-';
elseif conf.scale==1
    part = '';
else
    part = 'LP-';
end
conf.base_dir = './datasets/VOCdevkit2007/VOCcode/code3.2.1/data-USA/';
% conf.cache_dir = [conf.base_dir 'res/' part 'Faster-RCNN-' conf.network];%VGG16';
conf.cache_dir = [conf.base_dir 'res/' 'PCN[Ours]'];%VGG16';

if exist(conf.cache_dir, 'dir')
    rmdir(conf.cache_dir, 's');
end
mkdir(conf.cache_dir);

set_at = [conf.cache_dir '/%s'];
vid_at = [set_at '/%s.txt'];

% write out detections in Caltech format and score
for i = 1:length(dt_boxes); 
  image_path = imnames{i};
  image_path_split = strsplit(image_path, '/');
  image_id = image_path_split{end};
  deli_str = strsplit(image_id, {'_','.'});
  set_dir = sprintf(set_at, deli_str{1});
  mkdir_if_missing(set_dir);
  vid_path = sprintf(vid_at, deli_str{1}, deli_str{2});
  fid = fopen(vid_path, 'a'); 
  
  bbox = dt_boxes{i};
  if ~isempty(bbox)
      w = bbox(:,3); h = bbox(:,4);
      center_xy = [(w-1)/2+bbox(:,1), (h-1)/2+bbox(:,2)];
      scale_bbox = [center_xy(:,1)-(w-1)/2/conf.scale, center_xy(:,2)-(h-1)/2/conf.scale,...
                    w/conf.scale, h/conf.scale, bbox(:,5)];

      for j = 1:size(scale_bbox,1)
            fprintf(fid, '%d,%.3f,%.3f,%.3f,%.3f,%.9f\n', str2num(deli_str{3}(2:end))+1, scale_bbox(j,:));
      end
  end
      
  fclose(fid);
  
  %visualize
%   img_path = imdb.image_at(i);
%   im = imread(img_path);
%   use_gpu = 1;
%   if use_gpu
%         im = gpuArray(im);
%   end
%   thresh = 0.6;
%   bbox_ = scale_bbox(find(scale_bbox(:,5)>thresh), :);
%   aboxes = {bbox_};
%   legends ={cls};
%   showboxes(im, aboxes, legends);
%   pause(0.1);
%   bbox_ = bbox(find(bbox(:,5)>thresh), :);
%   aboxes = {bbox_};
%   showboxes(im, aboxes, legends);
%   pause(0.1);
  
end
%用Catech数据集自带的评测包code3.2.1进行评测
evapkg_path = './datasets/VOCdevkit2007/VOCcode/code3.2.1';
fprintf('use evaluate package :%s\n',evapkg_path);
addpath(genpath(evapkg_path));
dbEval;
% % evaluate miss rate
% my_dbEval('mr');
% % evaluate recall per iou(.5-.9) if cache_name = 'rpn'
% if strcmp(cache_name, 'rpn');
%    my_dbEval('recall');
% end
rmpath(genpath(evapkg_path)); 