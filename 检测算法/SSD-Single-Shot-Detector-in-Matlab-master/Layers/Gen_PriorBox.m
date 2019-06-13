%% 
%--------------Gen_PriorBox--------------
%作  者：杨帆
%公  司：BJTU
%功  能：产生Prior Box。
%输  入：
%       scale           -----> 特征图对应尺度。
%       aspect_ratio    -----> 特征图Box对应长宽比。
%       feature_size    -----> 特征图大小。
%输  出：
%       priorbox        -----> 输出Prior Box。
%备  注：Matlab 2016a。
%----------------------------------------

%%

function priorbox = Gen_PriorBox(scale, aspect_ratio, feature_size)

    % 检查特征图层数是否与各参数对应
    if(length(scale) ~= length(aspect_ratio))
        error('特征图层数要与各参数对应。');
    elseif(length(scale) ~= size(feature_size, 1))
        error('特征图层数要与各参数对应。');
    end
    
    for n = 1: length(scale)
        prior_table = zeros(feature_size(n, 1), feature_size(n, 2), ...
            length(aspect_ratio(n).r));
                
        for i = 1: feature_size(n, 1)
            for j = 1: feature_size(n, 2)
                
                cen_y = (i - 0.5) / feature_size(n, 1);
                cen_x = (j - 0.5) / feature_size(n, 2);
                
                left_y = max(cen_y - 0.5 * scale(n), 0);
                left_x = max(cen_x - 0.5 * scale(n), 0);
                right_y = min(left_y + scale(n), 1);
                right_x = min(left_x + scale(n), 1);
                
                prior_table(i, j, 1: 4) = ...
                        [left_x, left_y, right_x, right_y];
                
                if(n ~= length(scale))
                    s1 = sqrt(scale(n) * scale(n + 1)); 
                else
                    s1 = sqrt(scale(n));
                end
                
                left_y = max(cen_y - 0.5 * s1, 0);
                left_x = max(cen_x - 0.5 * s1, 0);
                right_x = min(left_x + s1, 1);
                right_y = min(left_y + s1, 1);
                
                prior_table(i, j, 5: 8) = ...
                        [left_x, left_y, right_x, right_y];                
                
                for k = 3: 2 + length(aspect_ratio(n).r)
                    
                    p_width = scale(n) * sqrt(aspect_ratio(n).r(k - 2));
                    p_height = scale(n) / sqrt(aspect_ratio(n).r(k - 2));
                                        
                    left_y = max(cen_y - 0.5 * p_height, 0);
                    left_x = max(cen_x - 0.5 * p_width, 0);
                    right_y = min(cen_y + 0.5 * p_height, 1);
                    right_x = min(cen_x + 0.5 * p_width, 1);
                    
                    prior_table(i, j, 1 + 4 * (k - 1): 4 * k) = ...
                        [left_x, left_y, right_x, right_y];
                end
            end
        end
        priorbox(n).p = single(prior_table);
    end
end

