%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    My_darkchannel：求暗通道
%   输入：
%       I：输入RGB图像
%       window_size：暗通道最小值滤波的窗口大小
%   输出：output：暗通道
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [output] = My_darkchannel(I,window_size)

    %% 第一步 读取图像信息
	% 获取图像大小和维度
    [height,width,~] = size(I);
    % 初始化暗通道图像
    dark_channel = ones(height,width);
    
    %% 第二步 获取每个像素点三个通道的最小值
    for i = 1:height
        for j = 1:width
            % 获取像素点位置三个通道的最小值
            dark_channel(i,j) = min( I(i,j,:) );
 
        end
    end 
    
    %% 第三步 最小值滤波
    % 调用My_minfilter函数进行最小值滤波
    min_dark_channel = My_minfilter(dark_channel,window_size);
    
    %% 第四步 输出暗通道
    output = min_dark_channel;
    
end