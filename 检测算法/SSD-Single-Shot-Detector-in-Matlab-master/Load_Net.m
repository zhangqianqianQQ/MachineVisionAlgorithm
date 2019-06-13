%% 
%----------------Load_Net----------------
%作  者：杨帆
%公  司：BJTU
%功  能：加载网络。
%输  入：
%       无
%输  出：
%       net     -----> 加载好的网络。
%备  注：Matlab 2016a。
%----------------------------------------

%%

function net = Load_Net()

    % 各层权重，偏置加载。
    load('./ssd_weights_mat/conv1_1_w');
    load('./ssd_weights_mat/conv1_1_b');
    load('./ssd_weights_mat/conv1_2_w');
    load('./ssd_weights_mat/conv1_2_b');
    
    net.conv1_1_w = conv1_1_w;
    net.conv1_1_b = conv1_1_b;
    net.conv1_2_w = conv1_2_w;
    net.conv1_2_b = conv1_2_b;

    load('./ssd_weights_mat/conv2_1_w');
    load('./ssd_weights_mat/conv2_1_b');
    load('./ssd_weights_mat/conv2_2_w');
    load('./ssd_weights_mat/conv2_2_b');
    
    net.conv2_1_w = conv2_1_w;
    net.conv2_1_b = conv2_1_b;
    net.conv2_2_w = conv2_2_w;
    net.conv2_2_b = conv2_2_b;

    load('./ssd_weights_mat/conv3_1_w');
    load('./ssd_weights_mat/conv3_1_b');
    load('./ssd_weights_mat/conv3_2_w');
    load('./ssd_weights_mat/conv3_2_b');
    load('./ssd_weights_mat/conv3_3_w');
    load('./ssd_weights_mat/conv3_3_b');
    
    net.conv3_1_w = conv3_1_w;
    net.conv3_1_b = conv3_1_b;
    net.conv3_2_w = conv3_2_w;
    net.conv3_2_b = conv3_2_b;
    net.conv3_3_w = conv3_3_w;
    net.conv3_3_b = conv3_3_b;
    
    load('./ssd_weights_mat/conv4_1_w');
    load('./ssd_weights_mat/conv4_1_b');
    load('./ssd_weights_mat/conv4_2_w');
    load('./ssd_weights_mat/conv4_2_b');
    load('./ssd_weights_mat/conv4_3_w');
    load('./ssd_weights_mat/conv4_3_b');
    
    net.conv4_1_w = conv4_1_w;
    net.conv4_1_b = conv4_1_b;
    net.conv4_2_w = conv4_2_w;
    net.conv4_2_b = conv4_2_b;
    net.conv4_3_w = conv4_3_w;
    net.conv4_3_b = conv4_3_b;

    load('./ssd_weights_mat/conv5_1_w');
    load('./ssd_weights_mat/conv5_1_b');
    load('./ssd_weights_mat/conv5_2_w');
    load('./ssd_weights_mat/conv5_2_b');
    load('./ssd_weights_mat/conv5_3_w');
    load('./ssd_weights_mat/conv5_3_b');
    
    net.conv5_1_w = conv5_1_w;
    net.conv5_1_b = conv5_1_b;
    net.conv5_2_w = conv5_2_w;
    net.conv5_2_b = conv5_2_b;
    net.conv5_3_w = conv5_3_w;
    net.conv5_3_b = conv5_3_b;

    load('./ssd_weights_mat/fc6_w');
    load('./ssd_weights_mat/fc6_b');    
    
    net.fc6_w = fc6_w;
    net.fc6_b = fc6_b;

    load('./ssd_weights_mat/fc7_w');
    load('./ssd_weights_mat/fc7_b');
    
    net.fc7_w = fc7_w;
    net.fc7_b = fc7_b;

    load('./ssd_weights_mat/conv6_1_w');
    load('./ssd_weights_mat/conv6_1_b');
    load('./ssd_weights_mat/conv6_2_w');
    load('./ssd_weights_mat/conv6_2_b');  
    
    net.conv6_1_w = conv6_1_w;
    net.conv6_1_b = conv6_1_b;
    net.conv6_2_w = conv6_2_w;
    net.conv6_2_b = conv6_2_b;

    load('./ssd_weights_mat/conv7_1_w');
    load('./ssd_weights_mat/conv7_1_b');
    load('./ssd_weights_mat/conv7_2_w');
    load('./ssd_weights_mat/conv7_2_b'); 
        
    net.conv7_1_w = conv7_1_w;
    net.conv7_1_b = conv7_1_b;
    net.conv7_2_w = conv7_2_w;
    net.conv7_2_b = conv7_2_b;

    load('./ssd_weights_mat/conv8_1_w');
    load('./ssd_weights_mat/conv8_1_b');
    load('./ssd_weights_mat/conv8_2_w');
    load('./ssd_weights_mat/conv8_2_b');
        
    net.conv8_1_w = conv8_1_w;
    net.conv8_1_b = conv8_1_b;
    net.conv8_2_w = conv8_2_w;
    net.conv8_2_b = conv8_2_b;

    load('./ssd_weights_mat/conv9_1_w');
    load('./ssd_weights_mat/conv9_1_b');
    load('./ssd_weights_mat/conv9_2_w');
    load('./ssd_weights_mat/conv9_2_b');  
        
    net.conv9_1_w = conv9_1_w;
    net.conv9_1_b = conv9_1_b;
    net.conv9_2_w = conv9_2_w;
    net.conv9_2_b = conv9_2_b;

    load('./ssd_weights_mat/conv4_3_norm_mbox_conf_w');
    load('./ssd_weights_mat/conv4_3_norm_mbox_conf_b');
    load('./ssd_weights_mat/conv4_3_norm_mbox_loc_w');
    load('./ssd_weights_mat/conv4_3_norm_mbox_loc_b');
        
    net.conv4_3_norm_mbox_conf_w = conv4_3_norm_mbox_conf_w;
    net.conv4_3_norm_mbox_conf_b = conv4_3_norm_mbox_conf_b;
    net.conv4_3_norm_mbox_loc_w = conv4_3_norm_mbox_loc_w;
    net.conv4_3_norm_mbox_loc_b = conv4_3_norm_mbox_loc_b;

    load('./ssd_weights_mat/fc7_mbox_conf_w');
    load('./ssd_weights_mat/fc7_mbox_conf_b');
    load('./ssd_weights_mat/fc7_mbox_loc_w');
    load('./ssd_weights_mat/fc7_mbox_loc_b');
    
    net.fc7_mbox_conf_w = fc7_mbox_conf_w;
    net.fc7_mbox_conf_b = fc7_mbox_conf_b;
    net.fc7_mbox_loc_w = fc7_mbox_loc_w;
    net.fc7_mbox_loc_b = fc7_mbox_loc_b;

    load('./ssd_weights_mat/conv6_2_mbox_conf_w');
    load('./ssd_weights_mat/conv6_2_mbox_conf_b');
    load('./ssd_weights_mat/conv6_2_mbox_loc_w');
    load('./ssd_weights_mat/conv6_2_mbox_loc_b');
    
    net.conv6_2_mbox_conf_w = conv6_2_mbox_conf_w;
    net.conv6_2_mbox_conf_b = conv6_2_mbox_conf_b;
    net.conv6_2_mbox_loc_w = conv6_2_mbox_loc_w;
    net.conv6_2_mbox_loc_b = conv6_2_mbox_loc_b;

    load('./ssd_weights_mat/conv7_2_mbox_conf_w');
    load('./ssd_weights_mat/conv7_2_mbox_conf_b');
    load('./ssd_weights_mat/conv7_2_mbox_loc_w');
    load('./ssd_weights_mat/conv7_2_mbox_loc_b');    
    
    net.conv7_2_mbox_conf_w = conv7_2_mbox_conf_w;
    net.conv7_2_mbox_conf_b = conv7_2_mbox_conf_b;
    net.conv7_2_mbox_loc_w = conv7_2_mbox_loc_w;
    net.conv7_2_mbox_loc_b = conv7_2_mbox_loc_b;
    
    load('./ssd_weights_mat/conv8_2_mbox_conf_w');
    load('./ssd_weights_mat/conv8_2_mbox_conf_b');
    load('./ssd_weights_mat/conv8_2_mbox_loc_w');
    load('./ssd_weights_mat/conv8_2_mbox_loc_b'); 
        
    net.conv8_2_mbox_conf_w = conv8_2_mbox_conf_w;
    net.conv8_2_mbox_conf_b = conv8_2_mbox_conf_b;
    net.conv8_2_mbox_loc_w = conv8_2_mbox_loc_w;
    net.conv8_2_mbox_loc_b = conv8_2_mbox_loc_b;

    load('./ssd_weights_mat/conv9_2_mbox_conf_w');
    load('./ssd_weights_mat/conv9_2_mbox_conf_b');
    load('./ssd_weights_mat/conv9_2_mbox_loc_w');
    load('./ssd_weights_mat/conv9_2_mbox_loc_b');
    
    net.conv9_2_mbox_conf_w = conv9_2_mbox_conf_w;
    net.conv9_2_mbox_conf_b = conv9_2_mbox_conf_b;
    net.conv9_2_mbox_loc_w = conv9_2_mbox_loc_w;
    net.conv9_2_mbox_loc_b = conv9_2_mbox_loc_b;
    
    disp('load weights and bias, done.');