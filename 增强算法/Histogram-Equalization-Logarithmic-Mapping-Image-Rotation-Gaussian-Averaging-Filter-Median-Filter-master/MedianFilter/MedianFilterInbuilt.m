% Flush out the MATLAB.
close all;
clc;
clear all;


% Read the desired image file.
ImageData=imread('auto.pnm');


% Display the original image.
figure,imshow(ImageData);
title(' Original Image: ');


% Filter implementation.
OutputImage = medfilt2(ImageData);


% Display the output image.
figure, imshow(OutputImage);
title(' Final Image: ');


% Add noise to oriiginal image.
ImageDataNoise = imnoise(ImageData,'Salt & Pepper', 0.04);


% Display the original image with noise.
figure,imshow(ImageDataNoise);
title(' Original Image with noise: ');


% Filter implementation.
OutputImageWithNoise = medfilt2(ImageDataNoise);


% Display the output image.
figure,imshow(OutputImageWithNoise);
title(' Final Image(with noise): ');