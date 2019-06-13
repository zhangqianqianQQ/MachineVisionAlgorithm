%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    My_minfilter：最小值滤波
%   输入：
%       I：输入灰度图像
%       window_size：最小值滤波的窗口大小
%   输出：output：最小值滤波的暗通道图像
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [output] = My_minfilter(I,window_size)

    %% 第一步 读取图像信息
    I_new = I;
    [height,width] = size(I);
    
    %% 第二步 遍历循环，进行最小值化
    for i = 1:height
        for j = 1:width
            % 处理边界，防止越界
            i_down = i-window_size;
            i_up = i+window_size;
            j_down = j-window_size;
            j_up = j+window_size;
            if(i_down<=0)
                i_down = 1;
            end
            if(j_down<=0)
                j_down = 1;
            end
            if(i_up>height)
                i_up = height;
            end
            if(j_up>width)
                j_up = width;
            end
            % 最小值滤波，取窗口内的最小值作为当前像素点的值
            I_new(i,j) =  min (min(I(i_down:i_up,j_down:j_up)) );
        end
    end
    
    %% 第三步 输出
    output = I_new;
end