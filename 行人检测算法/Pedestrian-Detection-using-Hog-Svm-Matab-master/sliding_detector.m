function sliding_detector(model)
% SLIDING_DETECTOR given a folder containing PNG or JPG images applies
%                 the specified libSVM model to scan through every image 
%                 for pedestrians in a sliding window basis drawing it
%                 as the window slides through every scale-space pyramid
%                 level.
%  
%
%$ Author: Jose Marcos Rodriguez $ 
%$ Date: N/D $ 
%$ Revision : 1.00 $ 
%% FILENAME  : sliding_detector.m 


    path = uigetdir('.\images','Select positive test image path');
    if isa(path,'double')
        cprintf('Errors','Invalid paths...\nexiting...\n\n')
        return 
    end
    
    images = rdir(strcat(path,filesep,'*.png'));
    for i=1:numel(images)
        file_name = images(i).name;
        disp(file_name);
        I = imread(file_name);
        [h,w,~] = size(I);
        scale = min(w/86, h/142);
        I = imresize(I, 1.2/scale);
        draw_sliding_window(I,model);
    end
end