function [clear_img, img] = gen_data(whichdata, sigma)

if ~exist('whichdata', 'var')
    whichdata = 1;
end

if ~exist('sigma', 'var')
    sigma = 0.3;
end

switch (whichdata)
    case 1      % gradient with gaussian noise
        clear_img = zeros(100, 100);
        vals = linspace(1, 0, 46);
        clear_img(15:60, 15:60) = repmat(vals, 46, 1);
        
        % add noise
        img = clear_img + sigma * randn(100, 100);
    case 2      % gradient with salt & pepper noise
        clear_img = zeros(100, 100);
        vals = linspace(1, 0, 46);
        clear_img(15:60, 15:60) = repmat(vals, 46, 1);
        
        % add noise
        r = rand(100, 100);
        img = clear_img;
        img(r < sigma/2) = 0;
        img(r > 1-sigma/2) = 1;
end
