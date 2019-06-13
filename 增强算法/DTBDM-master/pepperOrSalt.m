% Add salt or pepper noise to image of certain density
% image_noisy = pepperOrSalt(image_orig, ND, type_noise, min_val, max_val)
% image_noisy = image after adding salt or pepper or both salt and pepper noise
% image_orig = image after adding salt or pepper or both salt and pepper noise
% ND = noise density, default value is 0.2(20% noise)
% type_noise = decides whether to add salt or pepper or both type of noise,
% value of 1 for pepper, 2 for salt and 3 for both salt and pepper noise. 
% Default value is 3(both salt and pepper will be added in case od default value)
% min_val = the value of minimum noise. Value of 0 for pepper noise.
% Different value should be assigned to min_val in case of random valued
% impulse noise
% max_val = the value of maximum noise. Value of 1 for pepper noise in case of image with range [0,1]
% whereas value of 255 should be assigned in case of image with range
% [0,255].
% Different value should be assigned to max_val in case of random valued
% impulse noise

%%
function img = pepperOrSalt(varargin)
if length(varargin) == 1
    img = varargin{1};
    ND = 0.2;
    type_noise = 3;
    
    class_img = class(img);
    min_val = 0;
    if(isa(class_img ,'uint8'))
        max_val = 255;
    else
        max_val = 255;
    end
elseif length(varargin) < 3
    img = varargin{1};
    ND = varargin{2};
    type_noise = 3;
    class_img = class(img);
    min_val = 0;
    if(isa(class_img ,'uint8'))
        max_val = 255;
    else
        max_val = 1;
    end
elseif length(varargin) == 3
    img = varargin{1};
    ND = varargin{2};
    type_noise = varargin{3};
    
    class_img = class(img);
    min_val = 0;
    if(isa(class_img ,'uint8'))
        max_val = 255;
    else
        max_val = 1;
    end
    elseif length(varargin) == 4        
    img = varargin{1};
    ND = varargin{2};
    type_noise = varargin{3};
    min_val = varargin{4};
    class_img = class(img);
    if(isa(class_img ,'uint8'))
        max_val = 255;
    else
        max_val = 1;
    end
        max_val = max(img(:));
elseif length(varargin) >= 5        
        img = varargin{1};
        ND = varargin{2};
        type_noise = varargin{3};
        min_val = varargin{4};
        max_val = varargin{5};
else
    disp('not enough input parameter');
    img = 0;
    return;
end    
Narr = rand(size(img));
if type_noise == 1

        img(Narr<ND) = min_val;
    
elseif type_noise == 2
    
    img(Narr<ND) = max_val;
    
else
    
    img(Narr<ND/2) = min_val;
    img((Narr>=ND/2)&(Narr<ND)) = max_val;
    
end
