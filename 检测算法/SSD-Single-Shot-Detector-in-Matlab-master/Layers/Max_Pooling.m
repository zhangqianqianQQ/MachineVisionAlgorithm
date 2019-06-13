%% 
%---------------Max_Pooling--------------
%作  者：杨帆
%公  司：BJTU
%功  能：最大池化。
%输  入：
%       in_array    -----> 输入高维数组（dim = 3）。
%       window_size -----> 池化窗口大小。
%       stride      -----> 步长。
%       padding     -----> 填充像素数。
%输  出：
%       out_array   -----> 输出高维数组（dim = 3）。
%备  注：Matlab 2016a。
%----------------------------------------

%%

function out_array = Max_Pooling(in_array, window_size, stride, padding)
    
    % 检查数据维数    
    in_dims = ndims(in_array);
    if(in_dims == 3)
        [height, width, depth] = size(in_array);
    else
        error('输入数据维度小于3维，请检查输入数据。');
    end
    
    % 填充
    if(padding ~= 0)
        n_height = height + 2 * padding;
        n_width = width + 2 * padding;
    else
        n_height = height + mod(height, stride);
        n_width = width + mod(width, stride);
    end
    
    pad_in_array = zeros(n_height, n_width, depth);    
    pad_in_array(1 + padding: padding + width, 1 + padding: padding + height, :)...
        = in_array;
    
    % 确定输出大小
    o_height = floor((n_height - window_size) / stride + 1);
    o_width = floor((n_width - window_size) / stride + 1);
    out_array = zeros(o_height, o_width, depth);
    
    % im2col
    cidx = (0: window_size - 1)'; 
    ridx = 1: o_height;
    t = cidx(:, ones(o_height, 1)) + 1 + stride * (ridx(ones(window_size, 1),:) - 1);
    tt = zeros(window_size ^ 2, o_height);
    rows = 1: window_size;
    for a = 0: window_size - 1
        tt(a * window_size + rows, :) = t + n_height * a;
    end
    ttt = zeros(window_size ^ 2, o_height * o_width);
    cols = 1: o_height;
    for b = 0: o_width - 1
        ttt(:,b * o_height + cols) = tt + stride * n_height * b;
    end
    tttt = zeros(window_size ^ 2, o_height * o_width * depth);
    chanls = 1: o_height * o_width;
    for c = 0: depth - 1
        tttt(:, c * o_height * o_width + chanls) = ...
            ttt + n_height * n_width * c;
    end
    in_array_ = pad_in_array(tttt);  
    out_array = reshape(max(in_array_), o_height, o_width, depth);

    
%     % 窗口滑动
%     for i = 1 : stride: n_height - window_size + 1
%         for j = 1 : stride: n_width - window_size + 1
% 
%             % 提取图像块
%             block = pad_in_array(i: i + window_size - 1, ...
%                 j: j + window_size - 1, :);
%             
%             for k = 1: depth
%                 out_array(1 + (i - 1) / stride, 1 + (j - 1) / stride, k) = ...
%                     max(max(block(:, :, k)));
%             end
%         end
%     end
end