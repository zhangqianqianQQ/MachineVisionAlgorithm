function img3=manipulator(img,level)

scale=[1,3,5,7,9];
noise_level=[0.000,0.0003,0.0005,0.0007,0.0009];

if ~exist('level', 'var') 
    level=randi(5);
end
img2=rgb2hsv(img);
a=img2(:,:,3);
b=max(a(:));
img3=img2;
img3(:,:,3) = img3(:,:,3)/b/scale(level);
img3 = hsv2rgb(img3);
img3=imnoise(img3,'gaussian',0,noise_level(level));
H = fspecial('gaussian',5,0.83);
img3 = imfilter(img3,H,'replicate'); 
img3=uint8(img3*255);