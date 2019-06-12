%script to reverse the entire network
s = size(original_img);
im_size = [s(1), s(2)];
contrib_cls_person_score = 1;

cls_ind = 3; %16 is person, 1 is background, 3 bike
[val, roi_ind] = max(squeeze(cls_prob(:,cls_ind)));
roi_ind = 73; % 1,9,13,14,19,26,60,102 for 0002.jpg % 83 person, 73 bike for out_0_7

fc7_roi = squeeze(fc7(roi_ind,:));
fc6_roi = squeeze(fc6(roi_ind,:));
pool_5_roi = squeeze(pool_5(roi_ind,:,:,:));
roi = rois(roi_ind,:);

disp('---start reversing the entire network')
contrib_fc7 = reverse_fc(fc7_roi,contrib_cls_person_score,cls_score_weights(:,cls_ind));
contrib_fc6 = reverse_fc(fc6_roi,contrib_fc7,fc7_weights);
contrib_roipool = reverse_fc(flat_reshape(pool_5_roi),contrib_fc6,fc6_weights);
contrib_roipool = reverse_flat_reshape(contrib_roipool, size(pool_5_roi));
disp('---completed contrib_roipool')

contrib_conv5_3 = reverse_roipool(conv5_3, pool_5_roi, contrib_roipool);
disp('---completed reverse roi_pool')

contrib_conv5_2 = reverse_conv(conv5_2, contrib_conv5_3, conv5_3_weights);
contrib_conv5_1 = reverse_conv(conv5_1, contrib_conv5_2, conv5_2_weights);
contrib_pool4 = reverse_conv(pool4, contrib_conv5_1, conv5_1_weights);
disp('---completed reverse conv5')

contrib_conv4_3 = reverse_max_vl(conv4_3, contrib_pool4);
contrib_conv4_2 = reverse_conv(conv4_2, contrib_conv4_3, conv4_3_weights);
contrib_conv4_1 = reverse_conv(conv4_1, contrib_conv4_2, conv4_2_weights);
contrib_pool3 = reverse_conv(pool3, contrib_conv4_1, conv4_1_weights);
disp('---completed reverse conv4')

contrib_conv3_3 = reverse_max_vl(conv3_3, contrib_pool3);
contrib_conv3_2 = reverse_conv(conv3_2, contrib_conv3_3, conv3_3_weights);
contrib_conv3_1 = reverse_conv(conv3_1, contrib_conv3_2, conv3_2_weights);
contrib_pool2 = reverse_conv(pool2, contrib_conv3_1, conv3_1_weights);
disp('---completed reverse conv3')

contrib_conv2_2 = reverse_max_vl(conv2_2, contrib_pool2);
contrib_conv2_1 = reverse_conv(conv2_1, contrib_conv2_2, conv2_2_weights);
contrib_pool1 = reverse_conv(pool1, contrib_conv2_1, conv2_1_weights);
disp('---completed reverse conv2')

contrib_conv1_2 = reverse_max_vl(conv1_2, contrib_pool1);
contrib_conv1_1 = reverse_conv(conv1_1, contrib_conv1_2, conv1_2_weights);
%contrib_img = reverse_conv_original_img(original_img, contrib_conv1_1, conv1_1_weights);
%disp('completed reverse conv1')

%disp('completed contrib of img')
disp('---all completed')

