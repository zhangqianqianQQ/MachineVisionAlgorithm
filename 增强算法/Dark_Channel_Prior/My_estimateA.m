%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    My_estimateA：估计全局大气光A
%   输入：
%       I：输入RGB图像
%       dark_channel：I的暗通道
%   输出：output：RGB三个通道的全局大气光A
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [output] = My_estimateA(I,dark_channel)
    
    %% 第一步 初始化A并读取信息
    A = zeros(1,1,3);
    [height,width] = size(dark_channel);
    
   
    
    % 一共要取的点个数（亮度值前0.1%一共点数)
    points_number = round(width * height * 0.001);
    % 下面从最亮点中计算A的值
    % 从零开始迭代
    for k = 1:points_number    
        
         %% 第二步 取出dark_channel里的亮点
        brightest_points = max( max(dark_channel) );
        [i,j] = find (dark_channel==brightest_points);
        % 可能有多个最亮点，取第一个即可
        i = i(1);
        j = j(1);
        % 将此最亮点置0，方便找寻第二亮的点
        dark_channel(i,j) = 0;
        
         %% 第三步 根据亮点的位置计算A值
        % 在原图中对应位置找到它的亮度值
        % 对三个通道取平均
        % 若大于A，则更新A的值
        if(mean( I(i,j,:) )>mean(A(1,1,:)))
            % 分别记录三个通道的A值
            A(1,1,1) = (A(1,1,1)+I(i,j,1))/2;
            A(1,1,2) = (A(1,1,2)+I(i,j,2))/2;
            A(1,1,3) = (A(1,1,3)+I(i,j,3))/2;
        end
    end
    
    %% 第四步 输出A
    output = A;
end