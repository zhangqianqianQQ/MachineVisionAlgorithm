%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   My_guidedfilter：导向滤波，优化投射率矩阵
%   输入：
%       guide_image：向导图片
%       I：滤波图片
%       radius：滤波半径
%       sooth_parameter：平滑程度
%   输出：output：优化的投射率矩阵
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [output] = My_guidedfilter(guide_image, I, radius, sooth_parameter)


    [height, width] = size(guide_image);
    % 投射率矩阵中半径radius的累积和，便于求平均
    N = My_cumulative_sum(ones(height, width), radius); 
    
    % 向导图的平均
    mean_guide = My_cumulative_sum(guide_image, radius) ./ N;
    % 滤波图的平均
    mean_I = My_cumulative_sum(I, radius) ./ N;
    % 计算向导图和滤波图的积的平均
    mean_IG = My_cumulative_sum(guide_image.*I, radius) ./ N;
    % 计算向导图和滤波图的协方差
    cov_IG = mean_IG - mean_guide .* mean_I;
    % 计算向导图平方的平均
    mean_II = My_cumulative_sum(guide_image.*guide_image, radius) ./ N;
    % 计算滤波图片的方差
    var_I = mean_II - mean_guide .* mean_guide;
    
    % 求a
    a = cov_IG ./ (var_I + sooth_parameter);
    % 求b
    b = mean_I - a .* mean_guide; 
    
    % 求a的平均
    mean_a = My_cumulative_sum(a, radius) ./ N;
    % 求b的平均
    mean_b = My_cumulative_sum(b, radius) ./ N;
    
    % 求q
    q = mean_a .* guide_image + mean_b; 
    output = q;
end