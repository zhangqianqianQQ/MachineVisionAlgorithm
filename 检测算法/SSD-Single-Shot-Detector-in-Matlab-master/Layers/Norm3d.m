%% 
%-----------------Norm3d-----------------
%作  者：杨帆
%公  司：BJTU
%功  能：第三维归一化。
%输  入：
%       in_array    -----> 输入高维数组（dim = 3）。
%输  出：
%       out_array   -----> 输出高维数组（dim = 3）。
%备  注：Matlab 2016a。
%----------------------------------------

%%

function out_array = Norm3d(in_array)

    % 检查数据维数    
    in_dims = ndims(in_array);
    if(in_dims == 3)
        [height, width, depth] = size(in_array);
    else
        error('输入数据维度小于3维，请检查输入数据。');
    end
    
    % 初始化out_array
    out_array = zeros(height, width, depth);
    
    % 按第1、2维遍历卷积核
    for i = 1: height
        for j = 1: width
            vector = in_array(i, j, :);
            vector = reshape(vector, 1, size(vector, 3));
            
            % 计算第三维上每个特征图像素的2范数
            
            norm_vec = norm(vector, 2);
            
            % 归一化
            if(norm_vec ~= 0)
                out_array(i, j, :) = 10 * in_array(i, j, :) / norm_vec;
            end
        end
    end
end
        