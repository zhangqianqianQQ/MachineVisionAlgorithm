%% 
%----------------SSD_Net-----------------
%作  者：杨帆
%公  司：BJTU
%功  能：SSD网络结构声明。
%输  入：
%       net         -----> 网络参数。
%       img         -----> 输入图像(BGR, -mean)。
%       class       -----> 类别数。
%       description -----> Prior Box 参数结构体。
%输  出：
%       feature_maps -----> 输出特征图。
%备  注：Matlab 2016a。
%----------------------------------------

%%

function roi_table = SSD_Net(net, img, class, description)
   
    % 输入层
    im = Transform_Input(img, '2BGR', true, 'mean', [104, 117, 123], 'resize', [300,300]);

    % layer1
    conv1_1 = Conv3d(im, net.conv1_1_w, net.conv1_1_b, 1, 1, 1);
    conv1_1 = RELU(conv1_1);
    
    conv1_2 = Conv3d(conv1_1, net.conv1_2_w, net.conv1_2_b, 1, 1, 1);
    conv1_2 = RELU(conv1_2);
    
    pool1 = Max_Pooling(conv1_2, 2, 2, 0);
    
%     disp('layer: conv1 done.');

    % layer2
    conv2_1 = Conv3d(pool1, net.conv2_1_w, net.conv2_1_b, 1, 1, 1);
    conv2_1 = RELU(conv2_1);
    
    conv2_2 = Conv3d(conv2_1, net.conv2_2_w, net.conv2_2_b, 1, 1, 1);
    conv2_2 = RELU(conv2_2);
    
    pool2 = Max_Pooling(conv2_2, 2, 2, 0);

%     disp('layer: conv2 done.');
    
    % layer3
    conv3_1 = Conv3d(pool2, net.conv3_1_w, net.conv3_1_b, 1, 1, 1);
    conv3_1 = RELU(conv3_1);
    
    conv3_2 = Conv3d(conv3_1, net.conv3_2_w, net.conv3_2_b, 1, 1, 1);
    conv3_2 = RELU(conv3_2);
    
    conv3_3 = Conv3d(conv3_2, net.conv3_3_w, net.conv3_3_b, 1, 1, 1);
    conv3_3 = RELU(conv3_3);
    
    pool3 = Max_Pooling(conv3_3, 2, 2, 0);
    
%     disp('layer: conv3 done.');
    
    % layer4
    conv4_1 = Conv3d(pool3, net.conv4_1_w, net.conv4_1_b, 1, 1, 1);
    conv4_1 = RELU(conv4_1);
    
    conv4_2 = Conv3d(conv4_1, net.conv4_2_w, net.conv4_2_b, 1, 1, 1);
    conv4_2 = RELU(conv4_2);
    
    conv4_3 = Conv3d(conv4_2, net.conv4_3_w, net.conv4_3_b, 1, 1, 1);
    conv4_3 = RELU(conv4_3);
    
    pool4 = Max_Pooling(conv4_3, 2, 2, 0);  
    
%     disp('layer: conv4 done.');
    
    % layer5
    conv5_1 = Conv3d(pool4, net.conv5_1_w, net.conv5_1_b, 1, 1, 1);
    conv5_1 = RELU(conv5_1);
    
    conv5_2 = Conv3d(conv5_1, net.conv5_2_w, net.conv5_2_b, 1, 1, 1);
    conv5_2 = RELU(conv5_2);
    
    conv5_3 = Conv3d(conv5_2, net.conv5_3_w, net.conv5_3_b, 1, 1, 1);
    conv5_3 = RELU(conv5_3);
    
    pool5 = Max_Pooling(conv5_3, 3, 1, 1);
    
%     disp('layer: conv5 done.');
    
    % layer6
    fc6 = Conv3d(pool5, net.fc6_w, net.fc6_b, 1, 6, 6);
    fc6 = RELU(fc6);
    
%     disp('layer: fc6 done.');
    
    % layer7
    fc7 = Conv3d(fc6, net.fc7_w, net.fc7_b, 1, 0, 1);
    fc7 = RELU(fc7);
    
%     disp('layer: fc7 done.');
    
    % layer8
    conv6_1 = Conv3d(fc7, net.conv6_1_w, net.conv6_1_b, 1, 0, 1);
    conv6_1 = RELU(conv6_1);
    
    conv6_2 = Conv3d(conv6_1, net.conv6_2_w, net.conv6_2_b, 2, 1, 1);
    conv6_2 = RELU(conv6_2);
    
%     disp('layer: conv6 done.');
    
    % layer9
    conv7_1 = Conv3d(conv6_2, net.conv7_1_w, net.conv7_1_b, 1, 0, 1);
    conv7_1 = RELU(conv7_1);
    
    conv7_2 = Conv3d(conv7_1, net.conv7_2_w, net.conv7_2_b, 2, 1, 1);
    conv7_2 = RELU(conv7_2);
    
%     disp('layer: conv7 done.');
    
    % layer10
    conv8_1 = Conv3d(conv7_2, net.conv8_1_w, net.conv8_1_b, 1, 0, 1);
    conv8_1 = RELU(conv8_1);
    
    conv8_2 = Conv3d(conv8_1, net.conv8_2_w, net.conv8_2_b, 1, 0, 1);
    conv8_2 = RELU(conv8_2);  
    
%     disp('layer: conv8 done.');
    
    % layer11
    conv9_1 = Conv3d(conv8_2, net.conv9_1_w, net.conv9_1_b, 1, 0, 1);
    conv9_1 = RELU(conv9_1);
    
    conv9_2 = Conv3d(conv9_1, net.conv9_2_w, net.conv9_2_b, 1, 0, 1);
    conv9_2 = RELU(conv9_2);
    
%     disp('layer: conv9 done.');
    
    % layer4-norm
    conv4_3_norm = Norm3d(conv4_3);

    % conv4-mbox-conf & conv4-mbox-loc
    conv4_3_norm_mbox_conf = Conv3d(conv4_3_norm, net.conv4_3_norm_mbox_conf_w,...
        net.conv4_3_norm_mbox_conf_b, 1, 1, 1);
    conv4_3_norm_mbox_conf = Softmax_Mbox(conv4_3_norm_mbox_conf, class);
    conv4_3_norm_mbox_loc = Conv3d(conv4_3_norm, net.conv4_3_norm_mbox_loc_w,...
        net.conv4_3_norm_mbox_loc_b, 1, 1, 1);
    
    feature_maps(1).conf = conv4_3_norm_mbox_conf;
    feature_maps(1).loc = conv4_3_norm_mbox_loc;
    
%     disp('layer: conv4_3_norm_mbox done.');
    
    % fc7-mbox-conf & fc7-mbox-loc
    fc7_mbox_conf = Conv3d(fc7, net.fc7_mbox_conf_w, net.fc7_mbox_conf_b, 1, 1, 1);
    fc7_mbox_conf = Softmax_Mbox(fc7_mbox_conf, class);
    fc7_mbox_loc = Conv3d(fc7, net.fc7_mbox_loc_w, net.fc7_mbox_loc_b, 1, 1, 1);
    
    feature_maps(2).conf = fc7_mbox_conf;
    feature_maps(2).loc = fc7_mbox_loc;
    
%     disp('layer: fc7_mbox done.');
    
    % conv6_2-mbox-conf & conv6_2-mbox-loc
    conv6_2_mbox_conf = Conv3d(conv6_2, net.conv6_2_mbox_conf_w, ...
        net.conv6_2_mbox_conf_b, 1, 1, 1);
    conv6_2_mbox_conf = Softmax_Mbox(conv6_2_mbox_conf, class);
    conv6_2_mbox_loc = Conv3d(conv6_2, net.conv6_2_mbox_loc_w,...
        net.conv6_2_mbox_loc_b, 1, 1, 1);
    
    feature_maps(3).conf = conv6_2_mbox_conf;
    feature_maps(3).loc = conv6_2_mbox_loc;
    
%     disp('layer: conv6_2_mbox done.');
    
    % conv7_2-mbox-conf & conv7_2-mbox-loc
    conv7_2_mbox_conf = Conv3d(conv7_2, net.conv7_2_mbox_conf_w,...
        net.conv7_2_mbox_conf_b, 1, 1, 1);
    conv7_2_mbox_conf = Softmax_Mbox(conv7_2_mbox_conf, class);
    conv7_2_mbox_loc = Conv3d(conv7_2, net.conv7_2_mbox_loc_w,...
        net.conv7_2_mbox_loc_b, 1, 1, 1);
    
    feature_maps(4).conf = conv7_2_mbox_conf;
    feature_maps(4).loc = conv7_2_mbox_loc;
    
%     disp('layer: conv7_2_mbox done.');
    
    % conv8_2-mbox-conf & conv8_2-mbox-loc
    conv8_2_mbox_conf = Conv3d(conv8_2, net.conv8_2_mbox_conf_w,...
        net.conv8_2_mbox_conf_b, 1, 1, 1);
    conv8_2_mbox_conf = Softmax_Mbox(conv8_2_mbox_conf, class);
    conv8_2_mbox_loc = Conv3d(conv8_2, net.conv8_2_mbox_loc_w,...
        net.conv8_2_mbox_loc_b, 1, 1, 1);
    
    feature_maps(5).conf = conv8_2_mbox_conf;
    feature_maps(5).loc = conv8_2_mbox_loc;
    
%     disp('layer: conv8_2_mbox done.');
    
    % conv9_2-mbox-conf & conv9_2-mbox-loc
    conv9_2_mbox_conf = Conv3d(conv9_2, net.conv9_2_mbox_conf_w,...
        net.conv9_2_mbox_conf_b, 1, 1, 1);
    conv9_2_mbox_conf = Softmax_Mbox(conv9_2_mbox_conf, class);
    conv9_2_mbox_loc = Conv3d(conv9_2, net.conv9_2_mbox_loc_w,...
        net.conv9_2_mbox_loc_b, 1, 1, 1);
    
    feature_maps(6).conf = conv9_2_mbox_conf;
    feature_maps(6).loc = conv9_2_mbox_loc;
    
%     disp('layer: conv9_2_mbox done.');
    
    % 建立Prior Box
    aspect_ratio = description.aspect_ratio;
    feature_size = description.feature_size;
    scale = description.scale;
    
    priorbox = Gen_PriorBox(scale, aspect_ratio, feature_size);
    
    roi_table = [];
    roi_num = 0;
%     disp('generate prior box.');
    
    % 调整Prior Box
    for n = 1: 6 
        truing_box(n).loc = Truing_Box(priorbox(n).p, feature_maps(n).loc);
        truing_box(n).loc = reshape(permute(truing_box(n).loc, [3, 1, 2]), 4, []);
        prob = reshape(permute(feature_maps(n).conf, [3, 1, 2]), 21, []);
        truing_box(n).prob = max(prob);
        
        for j = 1: size(prob, 2)
            class = find(prob(:, j) == truing_box(n).prob(j));
            truing_box(n).class(j) = class;
            if(class ~= 1 && truing_box(n).prob(j) > 0.6)
                roi_num = roi_num + 1;
                roi_table(roi_num, 1) = class;
                roi_table(roi_num, 2) = truing_box(n).prob(j);
                roi_table(roi_num, 3: 6) = truing_box(n).loc(:, j)';
            end
        end
    end
%     disp('truing prior box, done.');
end

