%% Some parameters to set - make sure that your code works at image borders!
clear all;
close all;
% Row and column of the pixel for which we wish to find all similar patches 

row = 10;
col = 10;

% Patchsize - make sure your code works for different values
patchSize = 5;

% Search window size - make sure your code works for different values
searchWindowSize = 9;

%% Implementation of work required in your basic section-------------------

% Load Image
image = imread('images/alleyNoisy_sigma20.png');
image = rgb2gray(image);
%image = imresize(image, 0.5);

%Compute the integral image the explanation is inside the funciton
image_ii = computeIntegralImage(image, false);

% I compared the obtained result with the MATLAB integralImage function
%MATLAB_image_ii = integralImage(image);

% Display the normalised Integral Image
% NOTE: 1 - This is for display only, not for template matching yet!
%       2 - We don't want to use the normalized integral image for template
%           matching
figure('name', 'Normalised Integral Image');
imshow(image_ii);

% Template matching for naive SumSquareDifferences (i.e. just loop and sum)

[offsetsRows_naive, offsetsCols_naive, distances_naive] = templateMatchingNaive(row, col,...
    patchSize, searchWindowSize, image);

tic
% Template matching using integral images
[offsetsRows_ii, offsetsCols_ii, distances_ii] = templateMatchingIntegralImage(row, col,...
    patchSize, searchWindowSize, image);
toc
%% Let's print out your results--------------------------------------------

% NOTE: Your results for the naive and the integral image method should be
% the same!
for i=1:length(offsetsRows_naive)
    disp(['offset rows: ', num2str(offsetsRows_ii(i)), '; offset cols: ',...
        num2str(offsetsCols_ii(i)), '; Naive Distance = ', num2str(distances_naive(i),10),...
        '; Integral Im Distance = ', num2str(distances_ii(i),10)]);
end