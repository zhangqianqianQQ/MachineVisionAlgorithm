% demo_fcn()
%
% Trains and tests a Fully Convolutional Network on SIFT Flow.
%
% Copyright by Holger Caesar, 2016

% Add folders to path
setup();

% Settings
expNameAppend = 'testRelease';

% Download dataset
downloadSiftFlow();

% Download base network
downloadNetwork();

% Train network
dataset = SiftFlowDatasetMC();
fcnTrainGeneric('expNameAppend', expNameAppend, 'dataset', dataset);

% Test network
stats = fcnTestGeneric('expNameAppend', expNameAppend, 'dataset', dataset);
disp(stats);

% Show example segmentation
global glFeaturesFolder;
labelingsFolder = fullfile(glFeaturesFolder, 'CNN-Models', 'FCN', dataset.name, sprintf('fcn16s-%s', expNameAppend), 'labelings-test-epoch50');
fileList = dirSubfolders(labelingsFolder);
image = imread(fullfile(labelingsFolder, fileList{1}));
figure();
imshow(image);
