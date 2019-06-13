% Prepare testing data to quicken testing
init;

model = exp_params.model;

% Get test image path
im_dir = [VOC07PATH 'JPEGImages/'];
fid = fopen([VOC07PATH 'ImageSets/Main/test.txt']);
test_imgs = textscan(fid, '%s');
test_imgs = test_imgs{1};
num_test = size(test_imgs, 1);

% Network to use
caffe_params.model = exp_params.model;
caffe_params.model_file = exp_params.model_file;
caffe_params.def_file = exp_params.def_file;
caffe_params.device = exp_params.device;

% Load bounding boxes
load('data/SelectiveSearchVOC2007test.mat');
bbox = boxes(:);

% Initialization
max_img = 10;             % maximum number of images in the .mat file
tests = cell(1);
counter = 1;
file_counter = 1;

for ii=1:num_test
    disp(['Image: ' num2str(ii) '/' num2str(num_test)]);
    im_path = [im_dir test_imgs{ii} '.jpg'];
    im = imread(im_path);
    
    %boxes = selective_search(im, 'single');
    index = find(strcmp(images, test_imgs{ii}));
    boxes = bbox{index};
    num_boxes = size(boxes, 1);
    disp(['Number of boxes ' num2str(num_boxes)]);
    
    tic
    test = cell(num_boxes, 1);
    for jj=1:num_boxes
        box = boxes(jj, :);
        region = im(box(1):box(3), box(2):box(4), :);
        rep = extract_caffe_feature(region, caffe_params);
        
        test{jj} = struct;
        test{jj}.feature = mean(rep, 2);
        test{jj}.bbox = box;
    end
    tests{counter} = test;
    counter = counter + 1;
    toc
    
    if counter > max_img
        disp(['Save to file']);
        save(['data/' model '/test_' num2str(file_counter) '.mat'], 'tests', '-v7.3');
        counter = 1;
        file_counter = file_counter + 1;
        clear tests; tests = cell(max_img, 1);
    end
end

save(['data/' model '/test_' num2str(file_counter) '.mat'], 'tests', '-v7.3');
