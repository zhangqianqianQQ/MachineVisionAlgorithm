%% 
%-----------------Conv3d-----------------
%作  者：杨帆
%公  司：BJTU
%功  能：3维卷积。
%输  入：
%       in_array    -----> 输入高维数组（dim = 3）。
%       kernels     -----> 卷积核（dim = 4）。
%       bias        -----> 偏置。
%       stride      -----> 步长。
%       padding     -----> 填充像素数。
%       dilation    -----> 卷积核膨胀距离。
%输  出：
%       out_array   -----> 输出高维数组（dim = 3）。
%备  注：Matlab 2016a。
%----------------------------------------

%%

function out_array = Conv3d(in_array, kernels, bias, stride, padding, dilation)

    % 检查数据维数    
    in_dims = ndims(in_array);
    if(in_dims == 3)
        [height, width, depth] = size(in_array);
    else
        error('输入数据维度小于3维，请检查输入数据。');
    end
    
    if(ndims(kernels) < 4)
        error('输入卷积核维度小于4维，请检查输入数据。')
    else
        [k_height, k_width, k_depth, k_num] = size(kernels);
        n_kwidth = (k_width - 1) * dilation + 1;
        n_kheight = (k_height - 1) * dilation + 1;
    end
    
    % 检查bias数目是否与输入数组一致
    if(k_num ~= length(bias))
        error('bias数目与输入数组不一致，请检查输入数据。');
    end
          
    % 填充    
    n_height = height + 2 * padding;
    n_width = width + 2 * padding;
    pad_in_array = zeros(n_height, n_width, depth);    
    pad_in_array(1 + padding: padding + width, 1 + padding: padding + height, :)...
        = in_array;
    
    % 确定输出大小
    o_height = floor((n_height - n_kheight) / stride + 1);
    o_width = floor((n_width - n_kwidth) / stride + 1);
    out_array = zeros(o_height, o_width, k_num);
    
    % im2col
    cidx = n_width * n_height * (0: k_depth - 1)'; 
    ridx = 1: o_height;
    t = cidx(:, ones(o_height, 1)) + 1 + stride * (ridx(ones(k_depth, 1), :) - 1);
    tt = zeros(k_height * k_depth, o_height);
    rows = 1: k_depth;
    for c = 0: k_height - 1
        tt(c * k_depth + rows, :) = t + c * dilation;
    end
    ttt = zeros(k_height * k_width * k_depth, o_height);
    rows = 1: k_height * k_depth;
    for a = 0: k_width - 1
        ttt(a * k_height * k_depth + rows, :) = tt + n_height * dilation * a;
    end
    tttt = zeros(k_height * k_width * k_depth, o_height * o_width);
    cols = 1: o_height;
    for b = 0: o_width - 1,
        tttt(:, b * o_height + cols) = ttt + stride * n_height * b;
    end
    in_array_ = pad_in_array(tttt);
    ker = reshape(permute(kernels, [4, 3, 1, 2]), k_num, []);
    out_array_ = ker * in_array_;
    out_array = permute(reshape(out_array_, k_num, o_height, o_width), [2, 3, 1]);
    
    % 添加偏置
    for k = 1: k_num
        out_array(:, :, k) = out_array(:, :, k) + bias(k);
    end
end
    
    
