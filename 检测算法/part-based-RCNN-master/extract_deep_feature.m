%% Extract fc7 layer features using caffe matlab wrapper
%% If boxes is [-1 -1 -1 -1], it means no detected parts, filling in zero value as features.
%% Required preinstalled caffe matlab wrapper and add caffe path in init.m
%% No GPU is required. If GPU is available, change parameters in matcaffe_init
%% Written by Ning Zhang.

function feat = extract_deep_feature(model_file, model_def, imgpath, boxes)

% init rcnn model
clear caffe;
matcaffe_init(0, model_def, model_file);

% get batch
batch_size = 10;
crop_size = 227;
crop_padding = 16;
crop_mode = 'Square';
N = numel(imgpath);
num_batches = ceil(N / batch_size);
batches = cell(num_batches, 1);
batch_padding = batch_size - mod(N, batch_size);
d = load('/u/vis/nzhang/projects/caffe/matlab/caffe/ilsvrc_2012_mean.mat');
image_mean = d.image_mean;
missing_value_idx = find(boxes(:,1) == -1);
parfor batch = 1 : num_batches
  fprintf('preparing batches %d\n',batch);
  batch_start = (batch-1)*batch_size+1;
  batch_end = min(N, batch_start+batch_size-1);
  ims = zeros(crop_size, crop_size, 3, batch_size, 'single');
  for j = batch_start:batch_end
    bbox = boxes(j,:);
    im = imread(imgpath{j});
    if size(im,3) ~= 3
      img = zeros(size(im,1), size(im,2), 3);
      img(:, :, 1) = im;
      img(:, :, 2) = im;
      img(:, :, 3) = im;
      im = img;
    end
    im = single(im(:,:,[3 2 1]));
    if bbox(1) == -1
      bbox = [1 1 size(im,2) size(im,1)];
    end
    crop = rcnn_im_crop(im, bbox, crop_mode, crop_size, ...
        crop_padding, image_mean);
    % swap dims 1 and 2 to make width the fastest dimension (for caffe)
    ims(:,:,:,j-batch_start+1) = permute(crop, [2 1 3]);
  end
  batches{batch} = ims;
end

% compute features for each batch of region images
feat_dim = -1;
feat = [];
curr = 1;
for j = 1:length(batches)
  % forward propagate batch of region images
  fprintf('extract feature batch %d\n', j);
  f = caffe('forward', batches(j));
  f = f{1};
  f = f(:);
  % first batch, init feat_dim and feat
  if j == 1
    feat_dim = length(f)/batch_size;
    feat = zeros(size(boxes, 1), feat_dim, 'single');
  end
    
  f = reshape(f, [feat_dim batch_size]);
  % last batch, trim f to size
  if j == length(batches)
    if batch_padding > 0
      f = f(:, 1:end-batch_padding);
    end
  end
  feat(curr:curr+size(f,2)-1,:) = f';
  curr = curr + batch_size;
end

feat(missing_value_idx,:) = 0;

