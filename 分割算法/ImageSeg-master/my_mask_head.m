function mask = my_mask_head(roi_aligned, weights)
    res = roi_aligned;
    
    res = my_vl_conv(res,weights.conv0_w,[]);
    res = maskhead_bn(res,weights.conv0_beta,weights.conv0_gamma);
    res = maskhead_relu(res);
    
    res = my_vl_conv(res,weights.conv1_w,[]);
    res = maskhead_bn(res,weights.conv1_beta,weights.conv1_gamma);
    res = maskhead_relu(res);
    
    res = my_vl_conv(res,weights.conv2_w,[]);
    res = maskhead_bn(res,weights.conv2_beta,weights.conv2_gamma);
    res = maskhead_relu(res);
    
    res = my_vl_conv(res,weights.conv3_w,[]);
    res = maskhead_bn(res,weights.conv3_beta,weights.conv3_gamma);
    res = maskhead_relu(res);
    
    res = 
end