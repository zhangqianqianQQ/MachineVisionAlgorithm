% run network forward pass

img = imread('out_0_7.jpg');
W = load('net_weights.mat');

tic;
res = net_forward_pass(img, W, rois, false);
toc

%X = res.conv5_3(:,:,1);    Y = conv5_3(:,:,1);

%X = res.pool_5(:,:,1,1);    Y = squeeze(pool_5(1,:,:,1));

X = res.cls_score(83,:);   Y = cls_score(83,:);