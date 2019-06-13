close all
clear
clc
 
%Select the degraded image
[filename, pathname] = uigetfile({'*.*';'*.bmp';'*.jpg'}, 'Select the Fingerprint image file');
 
%or_im, read the original image to work on
or_im = imread([pathname,filename]);
 
 
[fin_im] =  main_function(or_im);
 
%imshow(fin_im);
imagesc(fin_im);colormap(gray(256));
