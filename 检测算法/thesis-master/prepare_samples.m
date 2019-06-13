% Extract ConvNet features from PASCAL VOC 2007 dataset
% Each image will have its features, labels, and bounding boxes
% saved into its own .mat file
init;

% Get image file path
dataset = exp_params.dataset;
im_dir = [VOC07PATH 'JPEGImages/'];
anno_dir = [VOC07PATH 'Annotations/'];
fid = fopen([VOC07PATH 'ImageSets/Main/' dataset '.txt']);
imgs = textscan(fid, '%s');
imgs = imgs{1};     % because textscan return 1x1 cell
num_imgs = length(imgs);

caffe_params.model = exp_params.net_model;
caffe_params.model_file = exp_params.model_file;
caffe_params.def_file = exp_params.def_file;
caffe_params.device = exp_params.device;
caffe_params.oversample = exp_params.oversample;

disp(['Processing dataset: ' dataset]);
disp(['Number of images: ' num2str(num_imgs)]);

% Prepare positive samples
% based on RCNN paper only ground truth bounding boxes
% specially allocated for faster loading times
disp('Preparing positive samples');
labels = cell(1);
features = cell(1);
regions = cell(1);
ids = cell(1);
counter = 1;
tic
for ii=1:num_imgs
    disp(['Images: ' imgs{ii} ', ' num2str(ii) '/' num2str(num_imgs)]);
    im_path = [im_dir imgs{ii} '.jpg'];
    im = imread(im_path);
    rec = PASreadrecord([anno_dir imgs{ii} '.xml']);
    
    num_object = size(rec.objects, 2);
    for jj=1:num_object
        % Get object label and its index
        label = rec.objects(jj).class;
        index = strfind(VOCCLASS, label);
        index = find(not(cellfun('isempty', index)));
        
        box = rec.objects(jj).bndbox;
        patch = im(box.ymin:box.ymax, box.xmin:box.xmax, :);
        
        % The important things to save, features, labels, image name, and
        % and the region bounding boxes
        rep = extract_caffe_feature(patch, caffe_params);
        labels{counter} = index;
        features{counter} = mean(rep, 2);
        regions{counter} = [box.ymin box.xmin box.ymax, box.xmax];
        ids{counter} = imgs{ii};
        counter = counter + 1;
    end
end
time = toc;
disp('Saving...');
save(['data/' caffe_params.model '/' dataset '/positive.mat'], 'features', ...
    'labels', 'ids', 'regions', '-v7.3');
disp(['Time: ' num2str(time)]);


% Prepare negative samples
% As indicated in RCNN paper, regions with less than 0.3 overlap with all
% classes bounding boxes
% This will be labeled as 0, to indicate background
% Other regions is marked as -1
threshold = 0.3;

% Use precomputed selective search boxes, directly from the author website
% RCNN also used the same boxes to get the result
if exp_params.precomputed_boxes
    ss = load(['data/selectivesearch/SelectiveSearchVOC2007' dataset]);
end

disp('Preparing negative samples');
for ii=1:num_imgs
    disp(['Images: ' imgs{ii} ', ' num2str(ii) '/' num2str(num_imgs)]);
    im_path = [im_dir imgs{ii} '.jpg'];
    im = imread(im_path);
    rec = PASreadrecord([anno_dir imgs{ii} '.xml']);
    
    % Check if the features of this image has been extracted
    if exist(['data/' caffe_params.model '/' dataset '/' imgs{ii} '.mat'], 'file')
        disp('The features has been extracted')
        continue;
    end
    
    % Use precomputed selective search boxes, or compute it with single
    % strategy
    if exp_params.precomputed_boxes
        index = find(strcmp(ss.images, imgs{ii}));
        bbox = ss.boxes{index};
    else
        bbox = selective_search(im, 'single');
    end
    
    tic
    num_boxes = size(bbox, 1);
    features = cell(1);
    labels = cell(1);
    regions = cell(1);
    counter = 1;
    for jj=1:num_boxes
        num_object = size(rec.objects, 2);
        reg_box = bbox(jj, :);
        is_background = 1;
        for kk=1:num_object
            obj = rec.objects(kk).bndbox;
            obj_box = [obj.ymin obj.xmin obj.ymax obj.xmax];
            overlap_ratio = compute_overlap(reg_box, obj_box);
            
            if overlap_ratio > threshold
                is_background = 0;
                break;
            end
        end
        
        region = im(reg_box(1):reg_box(3), reg_box(2):reg_box(4), :);
        rep = extract_caffe_feature(region, caffe_params);
        features{counter} = mean(rep, 2);
        regions{counter} = reg_box(:);
        if is_background
            labels{counter} = 0;
        else
            labels{counter} = -1;
        end
        counter = counter + 1;
    end
    save(['data/' caffe_params.model '/' dataset '/' imgs{ii} '.mat'], ...
        'features', 'regions', 'labels', '-v7.3');
    time = toc;
    disp(['Number of boxes: ' num2str(num_boxes) ' time: ' num2str(time)]);
end

disp('Finish...');
