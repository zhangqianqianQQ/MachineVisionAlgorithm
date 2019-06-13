    
function get_negative_windows(num_random_windows, num_images)
% GET_NEGATIVE_WINDOWS retrieves random windows from the original negative
%                      image set and saves the window in the specified
%                      folder when prompted.
% INPUT:
%       num_random_windows: random window samples per image
%       num_images: number of images from where to sample windows.
%
%$ Author: Jose Marcos Rodriguez $ 
%$ Date: N/D $ 
%$ Revision : 1.00 $ 
%% FILENAME  : get_negative_windows.m 
    
    % Paths
    negative_images_path = uigetdir('.\images','Select original images path');
    windows_dst_path = uigetdir('.\images','Select destination path');

    if isa(negative_images_path,'double') || isa(windows_dst_path,'double')
        cprintf('Errors','Invalid paths...\nexiting...\n\n')
        return 
    end
   
   negative_images = dir(negative_images_path);
   negative_images = negative_images(3:end);
   
   if num_images < 1
       fprintf('\ngetting all available images\n')
       num_images = numel(negative_images);
   elseif num_images > numel(negative_images)
       fprintf('not enought images...\ngetting al available images\n')
       num_images = numel(negative_images);
   end
   
   for i=1:num_images
       for nrw = 1:num_random_windows
            % getting random window from negative image
            file_name = ...
                strcat(negative_images_path,filesep,negative_images(i).name);
            I = imread(file_name);
            random_image_window = get_window(I,64,128, 'random');
            
            % making saving path
            [~, name, ext] = fileparts(file_name);
            file_saving_name = ...
                strcat(windows_dst_path, filesep,strcat(name,'_',sprintf('%02d',nrw)),ext);
            
            % saving image...
            imwrite(random_image_window, file_saving_name);
       end 
   end
   
    
    
    
