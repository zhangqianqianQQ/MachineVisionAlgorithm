function new_conv_weights = deconv_weights(conv_weights)
    %conv_weights in shape [row,col,pre-channel,post-channel]
    s = size(conv_weights);
    num_row = s(1);
    num_col = s(2);
    num_pre_ch = s(3);
    num_post_ch = s(4);
    new_conv_weights = [];
    
    %algo: 
    %   1. for each pre-ch index, get all layers in this pre-ch index and
    %              align them to make a filter in new_conv_weights
    %   2. rotate all layers 180 degree (by doing flip_leftright and then flip_updown, both operates in each row-col plane)
    
    for pre_ch = 1:num_pre_ch
        re_assembled_filter = squeeze(conv_weights(:,:,pre_ch,:));
        new_conv_weights(:,:,:,pre_ch) = flipud(fliplr(re_assembled_filter));
    end
    new_conv_weights = single(new_conv_weights);
end