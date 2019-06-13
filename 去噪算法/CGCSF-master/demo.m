clc;
clear;
close all;

addpath( genpath( 'functions/') );

%---------------------------------------------------
% Block size
%---------------------------------------------------
block_size = [32 32];

%---------------------------------------------------
% Load an image
% (Must be an 8 bit color or grayscale image)
% Recommended: Image size integer multiple of block_size
%              (However, program will run 
%               irrespective of Image size, by 
%               cropping the image region which is
%               multiple of block_size)
%---------------------------------------------------
img = imread('data/monarch.png');

%---------------------------------------------------
% Calculating the contrast detection thresholds
%---------------------------------------------------
CGCSF_CRMS_thr = CGCSF( img, block_size );

%---------------------------------------------------
% Show the MASKING MAP/DISTORTION VISIBILITY MAP
%---------------------------------------------------
distortion_visibility_map = imresize(CGCSF_CRMS_thr, [size(img, 1) size(img, 2)], 'nearest');
figure('Name', 'CRMS threshold map (dB)');
imshow(distortion_visibility_map, []);
colormap jet;colorbar;