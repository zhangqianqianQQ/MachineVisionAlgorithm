function [hogs,windows,wxl,coordinates] = get_pyramid_hogs(I, desc_size, scale, stride)
% GET_PYRAMID_HOGS function computes de HOG descriptor for all the 
%                  windows in a scale-space pyramid
%
% INPUT:
%       I: image to scan
%       desc_size: size of the descriptor (number of components)
%       scale: scale factor between pyramid levels
%       stride: window stride inside a pyramid level
%
% OUPUT:
%       hogs: HOGs of all the windows at all the levels
%       windows: all the windows of all levels
%       wxl: number of windows per level
%       coordinates: coordinates of all the windows 
%
%$ Author: Jose Marcos Rodriguez $ 
%$ Date: N/D $ 
%$ Revision : 1.00 $ 
%% FILENAME  : get_pyramid_hogs.m 

    params = get_params('window_params');
    window_heigth = params.height;
    window_width = params.width;

    [pyramid, coordinates] = ...
        get_scale_space_pyramid_images(I,scale, stride, false);

    [total_levels, total_windows, wxl] = get_pyramid_dimensions(I);

    hogs = zeros(total_windows,desc_size);
    windows = uint8(zeros(window_heigth,window_width,size(I,3), total_windows));
    index = 1;

    % for all pyramid levels...
    for level=1:total_levels

       % for all images in the level... (128x64x3xNumWindows) 
       num_windows = size(pyramid{level},4); 
       
       for num_image=1:num_windows

            % 3 chanel window (R,G,B)
            if size(pyramid{level}(:,:,:),3) > 1
                window = pyramid{level}(:,:,num_image*3-2:num_image*3);
            % 1 chanel window (Gray)
            else 
                window = pyramid{level}(:,:,num_image);
            end

            hogs(index,:) = compute_HOG(window,8,2,9)';
            windows(:,:,:,index) = window;
            index = index + 1;
       end
    end
end