% Flush out the MATLAB.
close all;
clc;
clear all;


% Read the desired image file.
ImageData=imread('auto.pnm');


% Display the original image.
figure,imshow(ImageData);
title(' Original Image: ');


% Take the input of the sigma from user.
SigmaValue = input('Enter the Sigma = ');


% Gaussian Filter implementation.
OutputImage = imgaussfilt(ImageData,SigmaValue);


% Display the output image.
figure, imshow(OutputImage);
title(' Final Image: ');


% Add noise to oriiginal image.
ImageDataNoise = imnoise(ImageData,'Salt & Pepper', 0.04);


% Display the original image with noise.
figure,imshow(ImageDataNoise);
title(' Original Image with noise: ');


% Gaussian Filter implementation.
OutputImageWithNoise = imgaussfilt(ImageDataNoise,SigmaValue);


% Display the output image.
figure,imshow(OutputImageWithNoise);
title(' Final Image(with noise): ');