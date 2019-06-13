function image_window = get_window(I,W,H, method)
% GET_WINDOW Gets a WxH window from the input image (I) with method 
%           'method'. Possible method are 'center','random' or coordiantes.
%
%
% INPUT: 
%       I: input image
%       W,H: width and height of the desired window
%       method: {center, random, coordinates}
%               center picks a centered window from the image
%               random picks any random window where possible
%               coordinates specify the upper left corner coords.
%
% OUTPUT: the sampled window
%
%$ Author: Jose Marcos Rodriguez $ 
%$ Date: N/D $ 
%$ Revision : 1.00 $ 
%% FILENAME  : get_window.m 

if ischar(method)
    
    if strcmp(method,'random')
        [height,width,~] = size(I);
        max_x_pixel = width-W+1;
        min_y_pixel = height-H+1;
        rand_h = mod(round(rand()*100),min_y_pixel)+1;
        rand_w = mod(round(rand()*100),max_x_pixel)+1;
        image_window = I(rand_h:rand_h+H-1,rand_w:rand_w+W-1,:);

    elseif strcmp(method,'center')
        [height,width,~] = size(I);
        x_margin = width-W+1;
        y_margin = height-H+1;
        x0 = max(1,floor(x_margin/2));
        y0 = max(1,floor(y_margin/2));
        image_window = I(y0:y0+H-1,x0:x0+W-1,:);
        
    else
        cprintf('Errors','GET_WINDOW: windows selction method not recognized\n')
        image_window = [];
    end
    
elseif isnumeric(method)
        x0 = method(1);
        y0 = method(2);
        [height,width,~] = size(I);
        if y0+H-1 <= height && x0+W-1 <= width
            image_window = I(y0:y0+H-1,x0:x0+W-1,:);
        else
            cprintf('Errors','Window size o\n')
            image_window = [];
        end
else
    cprintf('Errors','Method not recognized\n')
    image_window = [];
end