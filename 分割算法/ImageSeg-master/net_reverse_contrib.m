function contrib = net_reverse_contrib(res, W, cls_ind, FLAG)
%script to reverse the entire network
disp('net_reverse_contrib...');

    contrib_cls_person_score = 1;
    
    s = size(res.pool_5);
    contrib.roipool = zeros(size(res.rois, 1), s(1), s(2), s(3));
    s = size(res.conv1_1);
    contrib.conv1_1 = zeros(size(res.rois, 1), s(1), s(2), s(3));
    s = size(res.img);
    contrib.img = zeros(size(res.rois, 1), s(1), s(2), s(3));
    
    for roi_ind = 1:size(res.rois,1)
        fc7_roi = squeeze(res.fc7(roi_ind,:));
        fc6_roi = squeeze(res.fc6(roi_ind,:));
        pool_5_roi = squeeze(res.pool_5(:,:,:,roi_ind));

        contrib_fc7 = reverse_fc(fc7_roi,contrib_cls_person_score,W.cls_score_weights(:,cls_ind));
        contrib_fc6 = reverse_fc(fc6_roi,contrib_fc7,W.fc7_weights);
        contrib_roipool = reverse_fc(flat_reshape(pool_5_roi),contrib_fc6,W.fc6_weights);
        contrib_roipool = reverse_flat_reshape(contrib_roipool, size(pool_5_roi));
        contrib.roipool(roi_ind, :,:,:) = contrib_roipool;
        
        if strcmp(FLAG, 'roipool')           
            continue;
        end
        
        if strcmp(FLAG, 'img')
            contrib_conv5_3 = reverse_roipool(res.conv5_3, pool_5_roi, contrib_roipool);
            contrib_conv5_2 = reverse_conv(res.conv5_2, contrib_conv5_3, W.conv5_3_weights);
            contrib_conv5_1 = reverse_conv(res.conv5_1, contrib_conv5_2, W.conv5_2_weights);
            contrib_pool4 = reverse_conv(res.pool4, contrib_conv5_1, W.conv5_1_weights);

            contrib_conv4_3 = reverse_max_vl(res.conv4_3, contrib_pool4);
            contrib_conv4_2 = reverse_conv(res.conv4_2, contrib_conv4_3, W.conv4_3_weights);
            contrib_conv4_1 = reverse_conv(res.conv4_1, contrib_conv4_2, W.conv4_2_weights);
            contrib_pool3 = reverse_conv(res.pool3, contrib_conv4_1, W.conv4_1_weights);

            contrib_conv3_3 = reverse_max_vl(res.conv3_3, contrib_pool3);
            contrib_conv3_2 = reverse_conv(res.conv3_2, contrib_conv3_3, W.conv3_3_weights);
            contrib_conv3_1 = reverse_conv(res.conv3_1, contrib_conv3_2, W.conv3_2_weights);
            contrib_pool2 = reverse_conv(res.pool2, contrib_conv3_1, W.conv3_1_weights);

            contrib_conv2_2 = reverse_max_vl(res.conv2_2, contrib_pool2);
            contrib_conv2_1 = reverse_conv(res.conv2_1, contrib_conv2_2, W.conv2_2_weights);
            contrib_pool1 = reverse_conv(res.pool1, contrib_conv2_1, W.conv2_1_weights);

            contrib_conv1_2 = reverse_max_vl(res.conv1_2, contrib_pool1);
            contrib_conv1_1 = reverse_conv(res.conv1_1, contrib_conv1_2, W.conv1_2_weights);
            
            contrib_img = reverse_conv_original_img(res.img, contrib_conv1_1, W.conv1_1_weights);

            contrib.conv1_1(roi_ind, :,:,:) = contrib_conv1_1;
            contrib.img(roi_ind, :,:,:) = contrib_img;
            
            continue;
        end
        
    end
    
end