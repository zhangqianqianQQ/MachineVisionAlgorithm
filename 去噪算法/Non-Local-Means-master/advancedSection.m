%% Some parameters to set - make sure that your code works at image borders!
close all;
patchSize = 5;
sigma = 20; % standard deviation (different for each image!)
h = 0.55; %decay parameter
windowSize = 15; % --> it takes 99 seconds to run

%NOTE: for each image, please also read its CORRESPONDING 'clean' or
%reference image. We will need this later to do some analysis
%NOTE2: the noise level is different for each image (it is 20, 10, and 5 as
%indicated in the image file names)
%NOTE3 : all the functions to denoise the image work both with grayscale
%images and with RGB images

%Load the image to denoise and the refernce image 
imageNoisy = imread('images/alleyNoisy_sigma20.png');
imageReference = imread('images/alleyReference.png');

% converting the image in grayscale is much faster roughly 3 times faster
imageNoisy = rgb2gray(imageNoisy);
imageReference = rgb2gray(imageReference);

% we can resize the image so the code can run even faster
%imageNoisy = imresize(imageNoisy, 0.5);
%imageReference = imresize(imageReference, 0.5);


% Implement the non-local means functions and compare the performances

%############################## SIGMA = 20 ######################
% tic
% filtered = nonLocalMeansWithoutIntegral(imageNoisy, sigma, h, patchSize, windowSize, false);            
% toc
% 
% figure('name', 'NL-Means Denoised Image with Naive Approach -- SIGMA = 20 h = 0.55');
% imshow(filtered);

tic
filtered = nonLocalMeans(imageNoisy, sigma, h, patchSize, windowSize, false);            
toc

figure('name', 'NL-Means Denoised Image with Integral Images Approach -- SIGMA = 20 h = 1');
imshow(filtered);

h = 0.15;

% tic
% filtered = nonLocalMeansWithoutIntegral(imageNoisy, sigma, h, patchSize, windowSize, false);            
% toc
% 
% figure('name', 'NL-Means Denoised Image with Naive Approach -- SIGMA = 20 h = 0.25');
% imshow(filtered);

tic
filtered = nonLocalMeans(imageNoisy, sigma, h, patchSize, windowSize, false);            
toc

figure('name', 'NL-Means Denoised Image with Integral Images Approach -- SIGMA = 20 h = 0.25');
imshow(filtered);

%############################### SIGMA = 5 ####################

imageNoisy = imread('images/townNoisy_sigma5.png');
imageReference = imread('images/townReference.png');

% converting the image in grayscale is much faster roughly 3 times faster
imageNoisy = rgb2gray(imageNoisy);
imageReference = rgb2gray(imageReference);

sigma = 5; % standard deviation (different for each image!)
h = 0.55; %decay parameter

% tic
% filtered = nonLocalMeansWithoutIntegral(imageNoisy, sigma, h, patchSize, windowSize, false);            
% toc
% 
% figure('name', 'NL-Means Denoised Image with Naive Approach -- SIGMA = 5 h = 0.55');
% imshow(filtered);

tic
filtered = nonLocalMeans(imageNoisy, sigma, h, patchSize, windowSize, false);            
toc

figure('name', 'NL-Means Denoised Image with Integral Images Approach -- SIGMA = 5 h = 0.55');
imshow(filtered);

h = 0.25;

% tic
% filtered = nonLocalMeansWithoutIntegral(imageNoisy, sigma, h, patchSize, windowSize, false);            
% toc
% 
% figure('name', 'NL-Means Denoised Image with Naive Approach -- SIGMA = 5 h = 0.25');
% imshow(filtered);

tic
filtered = nonLocalMeans(imageNoisy, sigma, h, patchSize, windowSize, false);            
toc

figure('name', 'NL-Means Denoised Image with Integral Images Approach -- SIGMA = 5 h = 0.25');
imshow(filtered);




%% Let's show your results!

%Show the denoised image
% figure('name', 'NL-Means Denoised Image');
% imshow(filtered);

%Show difference image
diff_image = abs(imageReference - filtered);
figure('name', 'Difference Image');
imshow(diff_image ./ max(max((diff_image))));

%Print some statistics ((Peak) Signal-To-Noise Ratio)
disp('For Noisy Input');
[peakSNR, SNR] = psnr(imageNoisy, imageReference);
disp(['SNR: ', num2str(SNR, 10), '; PSNR: ', num2str(peakSNR, 10)]);

disp('For Denoised Result');
[peakSNR, SNR] = psnr(filtered, imageReference);
disp(['SNR: ', num2str(SNR, 10), '; PSNR: ', num2str(peakSNR, 10)]);

%Feel free (if you like only :)) to use some other metrics (Root
%Mean-Square Error (RMSE), Structural Similarity Index (SSI) etc.)