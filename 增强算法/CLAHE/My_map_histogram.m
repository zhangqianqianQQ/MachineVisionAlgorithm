%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   My_adapthisteq：计算重分配的look_up_table，范围从min_pixel到
%                   max_pixel
%   输入：输入直方图Hist  
%         灰度值上下限min_pixel,max_pixel
%         像素点总数 
%         直方图横轴总数sum_pixel_bin
%         高分成的子块数subpart_X  
%         宽分成的子块数subpart_Y
%   输出：重分配的look_up_tabl
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [output] = My_map_histogram(Hist,min_pixel,max_pixel,sum_pixel_bins,sum_pixels,subpart_X,subpart_Y)
    output=zeros(subpart_X,subpart_Y,sum_pixel_bins);
    scale = (max_pixel - min_pixel)/sum_pixels;
    % 遍历计算
    for i = 1:subpart_X
        for j = 1:subpart_Y
            sum = 0;
            for nr = 1:sum_pixel_bins
                sum = sum + Hist(i,j,nr);
                output(i,j,nr) = fix( min( min_pixel + sum*scale,max_pixel ) );
            end
        end
    end
end

