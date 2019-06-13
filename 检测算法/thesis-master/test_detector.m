% Load trained SVM detector
init;

% Get test image path
im_dir = [VOC07PATH 'JPEGImages/'];
fid = fopen([VOC07PATH 'ImageSets/Main/test.txt']);
test_imgs = textscan(fid, '%s');
test_imgs = test_imgs{1};
num_test = size(test_imgs, 1);

% Load trained SVM models
load('svm_models/baseline.mat');

for ii=1:num_test
    disp(['Image: ' num2str(ii)]);
    im = imread([im_dir test_imgs{ii} '.jpg']);
    detect(im, models, test_imgs{ii}, VOCCLASS);
end
