% Flush out the MATLAB.
close all;
clc;
clear all;


% Read the desired image file.
ImageData=imread('ct_scan.pnm');


% Display the original image.
figure,imshow(ImageData);
title(' Original Image: ');


% Take the input of the angle from user.
Angle = input('Enter the Angle = ');


% Image rotation implementation.
OutputImage = imrotate(ImageData,Angle);


% Display the output image.
figure, imshow(OutputImage);
title(' Final Image: ');


% Add noise to oriiginal image.
ImageDataNoise = imnoise(ImageData,'Salt & Pepper', 0.04);


% Display the original image with noise.
figure,imshow(ImageDataNoise);
title(' Original Image with noise: ');


% Image rotation implementation.
OutputImageWithNoise = imrotate(ImageDataNoise,Angle);


% Display the output image.
figure,imshow(OutputImageWithNoise);
title(' Final Image(with noise): ');