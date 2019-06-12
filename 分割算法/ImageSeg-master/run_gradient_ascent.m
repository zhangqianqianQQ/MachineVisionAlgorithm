% run gradient ascent
close all;

roi_ind = 83;
cls_ind = 16;

t_rois(1,:) = rois(roi_ind,:);
img = imread('out_0_7.jpg');
img = single(preprocess_img(img));
ori = img;
W = load('net_weights.mat');

num_iter = 100;
step_scale = 0.2;
figure;

for i=1:1
    disp(i);
    tic;
    res = net_forward_pass(img, W, t_rois, false);
    contrib = net_reverse_contrib(res, W, cls_ind);
    contrib_bg = net_reverse_contrib(res, W, 1);
    img = img + squeeze(contrib - contrib_bg) * step_scale;
    imshow((img-ori)/i);
    toc
end