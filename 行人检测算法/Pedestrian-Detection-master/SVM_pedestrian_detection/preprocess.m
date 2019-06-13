%%
%preprocess script
function [ img ] = preprocess( img )
%do whatever preprocessing of an image here
%   input - original image
%   output - grayscale image
[~,~,c] = size(img);


if (c ~= 1) img = rgb2gray(img); end
img = im2uint8(img);

end

