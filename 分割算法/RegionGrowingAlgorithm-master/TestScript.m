close all; clear all; clc;

%  image = imread('Resources/images/3096.jpg');
 image = imread('Resources/images/28075.jpg');
%   image = imread('Resources/images/113016.jpg');
 
 %image = imread('Resources/images/3096.jpg');
%     image = rgb2gray(image);

% neighborhoodType = 4; % 4-point connectivity
neighborhoodType = 4; % 8-point connectivty


tic;
[ segmentedImage, binaryImage, regionMatrix ] = RegionGrowingSegmentation(image, neighborhoodType);
display('Segmentation time:');
toc;
 