% Flush out the MATLAB.
close all;
clc;
clear all;


% Read the desired image file.
ImageData=imread('BC.jpg');

ImageData=rgb2gray(ImageData);


% Display the original image.
figure,imshow(ImageData);
title(' Original Image without Histogram: ');


% Histogram image implementation.
HistogramImage = histeq(ImageData);


% Display the output image.
figure,imshow(HistogramImage);
title(' Final Image with Histogram: ');


% Add noise to oriiginal image.
ImageDataNoise = imnoise(ImageData,'Salt & Pepper', 0.04);

% Display the original image with noise.
figure,imshow(ImageDataNoise);
title(' Original Image with noise: ');


% Histogram image implementation.
HistogramImageNoise = histeq(ImageDataNoise);


% Display the output image.
figure,imshow(HistogramImageNoise);
title(' Final Image(with noise) with Histogram: ');