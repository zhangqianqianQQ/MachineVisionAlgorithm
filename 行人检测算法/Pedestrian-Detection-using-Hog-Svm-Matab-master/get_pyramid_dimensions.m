function [num_levels, num_windows, windows_per_level] = get_pyramid_dimensions(I)
% GET_PYRAMID_DIMENSIONS function to compute the pyramid dimensions
%
% INPUT: 
%       I: input image
% OUTPUT:
%       num_levels: pyramid levels
%       num_windows: total number of windows over whole pyramid
%       windows_per_level: number of windows in each level
%
%$ Author: Jose Marcos Rodriguez $ 
%$ Date: N/D $ 
%$ Revision : 1.01 $ 
%% FILENAME  : get_pyramid_dimensions.m 

    w_params = get_params('window_params');
    window_width = w_params.width;
    window_height = w_params.height;
    
    py_params = get_params('pyramid_params');
    scale = py_params.scale;
    stride = py_params.stride;

    % computing number of levels in the pyramid
    [height,width, ~] = size(I);
    l_w = (log(width)/log(scale)) - (log(window_width)/log(scale));
    l_h = (log(height)/log(scale)) - (log(window_height)/log(scale));
    num_levels = floor(min(l_w,l_h))+1;
    %         fprintf('number of levels:%d\n', levels+1);

    levels = 0:num_levels-1;

    % image dimensions
    im_w = ceil(width./scale.^(levels));
    im_h = ceil(height./scale.^(levels));

    % num windows computed as: 1 window + n*stride
    num_V_windows = floor((im_h-window_height)/stride)+1;
    num_H_windows = floor((im_w-window_width)/stride)+1;

    % Counting windows through levels
    windows_per_level = (num_V_windows .* num_H_windows);
    num_windows = sum(windows_per_level);  

end

            
            