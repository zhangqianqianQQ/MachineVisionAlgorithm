function l_curr = gpu_forward_conv(l_prev, weights)
    tic;
    s = size(l_prev);
    num_prev_row = s(1);
    num_prev_col = s(2);
    num_prev_ch = s(3);
    
    ss = size(weights);
    num_curr_ch = ss(4);
    
    %disp('zero-pad the l_prev')
    padded_l_prev = zeros(num_prev_row+2, num_prev_col+2, num_prev_ch);
    padded_l_prev(2:num_prev_row+1, 2:num_prev_col+1, 1:num_prev_ch) = l_prev;
    padded_gpu_l_prev = gpuArray(padded_l_prev);
    %disp('start looping')
    parfor ch = 1:num_curr_ch       
        l_curr(:,:,ch) = convn(padded_gpu_l_prev, gpuArray(squeeze(weights(:,:,:,ch))),'valid');
    end
    l_curr = gather(l_curr);
    %l_curr(l_curr<0) = 0; % this is the relu
    toc
end