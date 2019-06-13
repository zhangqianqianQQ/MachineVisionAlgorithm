%% function to get bird images and boxes 
%% Change BIRD_DIR path to your path
%% Written by Ning Zhang

function config = get_bird_data
BIRD_DIR = '/u/vis/x1/common/CUB_200_2011/';
img_base = [BIRD_DIR 'images/'];
config.img_base = img_base;
imdir = [BIRD_DIR 'images.txt'];
[img_id img_path] = textread(imdir,'%d %s');
traintest_dir = [BIRD_DIR 'train_test_split.txt'];
[img_id train_flag] = textread(traintest_dir, '%d %d');
label_dir = [BIRD_DIR 'image_class_labels.txt'];
[img_id img_labels] = textread(label_dir,'%d %d');
part_dir = [BIRD_DIR '/parts/part_locs.txt'];
[img_id part part_x part_y visible] = textread(part_dir, '%d %d %f %f %d');
boundingbox_dir = [BIRD_DIR 'bounding_boxes.txt'];
[img_id left top width height] = textread(boundingbox_dir, '%d %f %f %f %f');
trainindex = find(train_flag == 1);
testindex = find(train_flag == 0);
config.trainlabel = img_labels(trainindex);
config.testlabel = img_labels(testindex);
config.impathtrain = strcat(img_base,img_path(trainindex));
config.impathtest = strcat(img_base, img_path(testindex));
for j = 1:length(config.impathtrain)
    i = trainindex(j);
    train_bb(j,:) = [left(i) top(i) left(i)+width(i) top(i)+height(i)];
end
for j = 1:length(config.impathtest)
    i = testindex(j);
    test_bb(j,:) = [left(i) top(i) left(i)+width(i) top(i)+height(i)];
end

q = load('annotations/bird_train.mat');
for i = 1 : length(config.impathtrain)
    train_head(i,:) = q.data(i).head;
    train_body(i,:) = q.data(i).body;
end

q = load('annotations/bird_test.mat');
for i = 1 : length(config.impathtest)
    test_head(i,:) = q.data(i).head;
    test_body(i,:) = q.data(i).body;
end

% The current code supports two parts now. 
% Change the following if you want to add more parts.
config.N_parts = 3; % bbox + head + body
config.N_methods = 3; % three different geometric constaints
config.methods = {'box', 'prior', 'neighbor'};
config.train_box{1} = train_bb;
config.train_box{2} = train_head;
config.train_box{3} = train_body;
config.test_box{1} = test_bb;
config.test_box{2} = test_head;
config.test_box{3} = test_body;
end


