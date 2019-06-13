%% Compile MatConvNet
% TODO

%% Setup classifier
setup_path = 'D:\Users\sim0629\matconvnet-1.0-beta20\matlab';
% need to be called
run(fullfile(setup_path, 'vl_setupnn.m'));
load('imdb.mat');
load('net-epoch-57.mat');

%% Detection and Classification
close all;
[filename, pathname, ~] = uigetfile({'*.jpg;*.tif;*.png;*.gif','All Image Files'});
im = imread(fullfile(pathname, filename));

[ellipses, resized_im] = detectEllipses(im, true);
num_of_ellipses = length(ellipses);
features = zeros(50 * num_of_ellipses, 100, 3, 'uint8');
scoreses = zeros(num_of_ellipses, 8);

for i = 1 : num_of_ellipses
    feature = extractFeatureImage(resized_im, ellipses, i, false);
    scoreses(num_of_ellipses+1-i,:) = classifyFeature(feature, images, net)';
    features((num_of_ellipses-i)*50+1 : (num_of_ellipses+1-i)*50, :, :) = feature(52:101,1:100,:);
end

figure;

subplot('position', [0, 0.3, 0.3, 0.7]);
imshow(features);

subplot('position', [0.3, 0, 0.7, 0.3]);
imshow('labels.jpg');

subplot('position', [0.3, 0.3, 0.7, 0.7]);
colormap('jet');
imagesc(scoreses);
