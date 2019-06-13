% demo_e2s2_fast()
%
% Trains and tests a Region-based semantic segmentation with end-to-end training on SIFT Flow.
% Requires the version of VGG-16 pretrained with MatConvNet's beta16, and does not
% work with newer versions. This is most likely due to exploding gradients, although the architecture is identical.
%
% Copyright by Holger Caesar, 2016

% Add folders to path
setup();

% Settings
global glFeaturesFolder; % Define global variables to be used in all scripts
labelingsFolder = fullfile(glFeaturesFolder, 'CNN-Models', 'E2S2', 'SiftFlow', 'Run1', sprintf('%s_e2s2_run1_exp1', 'SiftFlow'), 'labelings-test-epoch10');

% Download dataset
downloadSiftFlow();

% Download base network
downloadNetwork('version', 'beta16');

% Download Selective Search
downloadSelectiveSearch();

% Extract region proposals and labels
setupE2S2Regions();

% Train and test network
e2s2_wrapper_SiftFlow_fast();

% Show example segmentation
fileList = dirSubfolders(labelingsFolder);
image = imread(fullfile(labelingsFolder, fileList{1}));
figure();
imshow(image);