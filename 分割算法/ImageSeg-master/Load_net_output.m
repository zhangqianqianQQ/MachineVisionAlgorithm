load('net_weights.mat');
load('out_0_7layer_out.mat');
original_img = squeeze(original_img);
conv1_1 = squeeze(conv1_1);
conv1_2 = squeeze(conv1_2);
conv2_1 = squeeze(conv2_1);
conv2_2 = squeeze(conv2_2);
conv3_1 = squeeze(conv3_1);
conv3_2 = squeeze(conv3_2);
conv3_3 = squeeze(conv3_3);
conv4_1 = squeeze(conv4_1);
conv4_2 = squeeze(conv4_2);
conv4_3 = squeeze(conv4_3);
conv5_1 = squeeze(conv5_1);
conv5_2 = squeeze(conv5_2);
conv5_3 = squeeze(conv5_3);
img_gradient = squeeze(img_gradient);
pool1 = squeeze(pool1);
pool2 = squeeze(pool2);
pool3 = squeeze(pool3);
pool4 = squeeze(pool4);
pool_5 = squeeze(pool_5);
rpn_bbox_pred = squeeze(rpn_bbox_pred);
rpn_cls_prob = squeeze(rpn_cls_prob);
rpn_cls_prob_reshape = squeeze(rpn_cls_prob_reshape);
rpn_cls_score = squeeze(rpn_cls_score);
rpn_cls_score_reshape = squeeze(rpn_cls_score_reshape);
rpn_conv_3x3 = squeeze(rpn_conv_3x3);

%setup matconvnet
run /home/spc-public/Yixuan/matconvnet/matconvnet-1.0-beta24/matlab/vl_setupnn;

