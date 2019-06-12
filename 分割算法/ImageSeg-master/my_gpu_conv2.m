function ret = my_gpu_conv2(l_prev_layer, filter)
    ret = conv2(l_prev_layer,filter,'valid');
end