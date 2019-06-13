%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   My_adapthisteq：剪裁函数，用于剪裁直方图并且重新分配像素值,
%                   可以把超过Clip_limit的像素值均匀分配到直方图
%                    的其他位置
%   输入：输入直方图Hist
%         直方图横轴总数sum_pixel_bin
%         剪裁阈值Clip_limit
%         高分成的子块数subpart_X  
%         宽分成的子块数subpart_Y
%   输出：剪裁后的直方图Hist
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Hist] = My_clip_histogram(Hist,sum_pixel_bin,clip_limit,subpart_X,subpart_Y)
    
    for i = 1:subpart_X
        for j = 1:subpart_Y
           %% 第一步 计算超过阈值的像素值总数 
            sum_excess = 0;
            for nr = 1:sum_pixel_bin
                excess = Hist(i,j,nr) - clip_limit;
                if excess > 0
                    sum_excess = sum_excess + excess;
                end
            end

           %% 第二步 剪裁并重建直方图
            % 平均超过的像素值
            bin_averate = sum_excess / sum_pixel_bin;
            % 上限，保证重建的直方图不超过阈值
            upper = clip_limit - bin_averate;
            for nr = 1:sum_pixel_bin
                % 若大于阈值，直接裁掉
                if Hist(i,j,nr) > clip_limit
                    Hist(i,j,nr) = clip_limit;
                else
                    % 否则，若大于上限，把这些像素值设为阈值
                    if Hist(i,j,nr) > upper
                        % 从总数中减去
                        sum_excess = sum_excess + upper - Hist(i,j,nr);
                        Hist(i,j,nr) = clip_limit;
                    else
                        % 否则，若小于上限，则加上平均超过的像素值
                        sum_excess = sum_excess - bin_averate;
                        Hist(i,j,nr) = Hist(i,j,nr) + bin_averate;
                    end
                end
            end
            
            % 若超过像素值总数大于零，再平均分给每一个像素值
            if sum_excess > 0
                % 计算步长
                step_size = max(1,fix(1+sum_excess/sum_pixel_bin));
                % 从最小灰度级到最大灰度级按照步长循环搜索
                for nr = 1:sum_pixel_bin
                    sum_excess = sum_excess - step_size;
                    Hist(i,j,nr) = Hist(i,j,nr) + step_size;
                    % 若小于1，循环结束
                    if sum_excess < 1
                        break;
                    end
                end
            end
            
        end
    end
end
