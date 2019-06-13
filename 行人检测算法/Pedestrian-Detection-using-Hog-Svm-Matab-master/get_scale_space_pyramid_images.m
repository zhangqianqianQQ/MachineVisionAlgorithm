function [pyramid, coordinates] = get_scale_space_pyramid_images(I,scale,stride, show)
% GET_SCALE_SPACE_PYRAMID_IMAGES retrieves every window image in a 
%                                scale-space-pyramid structure.
%
% INPUT:
%       I: image to process
%       scale: scaling ratio between levels
%       stride: sampling pixel distance between two consecutive windows
%
% OUTPUT:
%       pyramid: cell array pyramid strctured with every window indexed
%                by level and numer of window within that level.
%       coordiantes: coordinates of each window referenced to the level 0
%                    pyramid layer.
%
%$ Author: Jose Marcos Rodriguez $ 
%$ Date: N/D $ 
%$ Revision : 1.00 $ 
%% FILENAME  : get_scale_space_pyramid_images.m 

    % pre allocating memory
    [levels, num_windows,~] = get_pyramid_dimensions(I);
    coordinates = zeros(2,num_windows);
    pyramid = cell(1,levels);
    coord_indx = 1;
    level = 1;
    
    params = get_params('window_params');
    window_v_size = params.height;
    window_h_size = params.width;

    [height,width, ~] = size(I);
    sub_level_image = imresize(I,1);
    
    while height >= window_v_size && width >= window_h_size
        % showing the sub-level image
        title = strcat('level ',int2str(level));
        if show
            figure('name', title); 
            imshow(sub_level_image)
        end
        
        % getting windows over the sub-level image
        [pyramid{level}, coords] = get_windows(sub_level_image,stride,show);
        for c=1:size(coords,2)
            coordinates(1,coord_indx) = coords(1,c);
            coordinates(2,coord_indx) = coords(2,c);
            coord_indx = coord_indx + 1;
        end
        % accesing example to a given window number and level
        % window1 = pyramid{level}(:,:,:,1);
        % window2 = pyramid{level}(:,:,:,2);

        % continue re-scaling the image
        sub_level_image = imresize(sub_level_image, 1.0/scale);
        [height,width, ~] = size(sub_level_image);

        % updating level values
        level = level + 1;
    end
    
    
    
    %% AUX function to get all window from an image
    function [windows, coordinates] = get_windows(I,stride, show)
        
        % window and image size
        [im_v_size,im_h_size,~] = size(I);
        
        % number of vertical and horitzontal windows
        % assuming at least one window fits over the image , so:
        % we'll have 1 window + N sliding windows...
        num_V_windows = floor((im_v_size-window_v_size)/stride)+1;
        num_H_windows = floor((im_h_size-window_h_size)/stride)+1;

        % remaining pixels between last window and image border
        V_margin = im_v_size - (num_V_windows-1)*stride - window_v_size;
        H_margin = im_h_size - (num_H_windows-1)*stride - window_h_size;
        
        % computing offset
        V_offset = floor(V_margin/2);
        H_offset = floor(H_margin/2);

%         fprintf('num horitzontal windows: %d \n',num_H_windows)
%         fprintf('num vertical windows: %d \n',num_V_windows)
        
        % retrieving windows
        if show
            figure('name', 'windows');
        end

        windows = uint8(zeros(128,64,size(I,3),num_V_windows*num_H_windows));
        coordinates = uint8(zeros(2,num_V_windows*num_H_windows));

        % all vertical windows
        index = 1;
        v_ini = 1 + V_offset;

        for i=1:num_V_windows
            h_ini = 1 + H_offset;
            v_fin = v_ini + window_v_size-1;
            
            % all horitzontal windows
            for j=1:num_H_windows
                coordinates(1, index) = h_ini;
                coordinates(2, index) = v_ini;
            
                h_fin = h_ini + window_h_size-1;
                windows(:,:,:,index) = I(v_ini:v_fin,h_ini:h_fin,:); 
                
                % showing windows 
                if show
                    subplot(num_V_windows,num_H_windows,index);
                    subimage(windows(:,:,:,index));
                end
                
                % moving window
                h_ini = h_ini + stride;
                index = index + 1;
            end
            
            v_ini = v_ini + stride;
        end
    end
end
    
    
    