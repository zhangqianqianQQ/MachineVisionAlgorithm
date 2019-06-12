function ret = my_gpu_convn(l_prev, weights)
    s = size(weights);
    num_ch = s(4);
    ret = zeros(s(1),s(2),s(4));
    for ch = 1:num_ch
        ret(:,:,ch) = convn(l_prev,squeeze(weights(:,:,:,ch)));
    end
    
end