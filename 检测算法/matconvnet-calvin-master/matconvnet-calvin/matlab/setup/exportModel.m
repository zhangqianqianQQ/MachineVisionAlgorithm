function exportModel(modelName)
% exportModel(modelName)
%
% Zips a trained model so that it can be uploaded to our homepage.
%
% Copyright by Holger Caesar, 2016

% Settings
global glBaseFolder;
if strcmp(modelName, 'frcn')
    exportName = 'FRCN_VOC2010_model';
    exportFiles = {'net-epoch-16.mat', 'net-train.pdf', 'log.txt', 'resultsEpochFinalTest.mat'};
    exportFilesPrefix = fullfile(glBaseFolder, 'Features', 'CNN-Models', 'FRCN', 'VOC2010', 'VOC2010-testRelease');
elseif strcmp(modelName, 'fcn')
    exportName = 'FCN_SiftFlow_model';
    exportFiles = {'labelings-test-epoch50', 'net-epoch-50.mat', 'net-opts.mat', 'net-train.pdf', 'log.txt', 'stats-test-epoch50.mat'};
    exportFilesPrefix = fullfile(glBaseFolder, 'Features', 'CNN-Models', 'FCN', 'SiftFlow', 'fcn16s-testRelease');
elseif strcmp(modelName, 'e2s2_fast')
    exportName = 'E2S2_SiftFlow_model_fast';
    exportFiles = {'labelings-test-epoch10', 'net-epoch-10.mat', 'net-opts.mat', 'net-train.pdf', 'log.txt', 'stats-test-epoch10.mat'};
    exportFilesPrefix = fullfile(glBaseFolder, 'Features', 'CNN-Models', 'E2S2', 'SiftFlow', 'Run1', 'SiftFlow_e2s2_run1_exp1');
elseif strcmp(modelName, 'e2s2_full')
    exportName = 'E2S2_SiftFlow_model_full';
    exportFiles = {'labelings-test-epoch25', 'net-epoch-25.mat', 'net-opts.mat', 'net-train.pdf', 'log.txt', 'stats-test-epoch25.mat'};
    exportFilesPrefix = fullfile(glBaseFolder, 'Features', 'CNN-Models', 'E2S2', 'SiftFlow', 'Run1', 'SiftFlow_e2s2_run1_exp2');
else
    error('Error: Unknown model: %s', modelName);
end

% Define paths
exportFolder = fullfile(glBaseFolder, 'Export');
if ~exist(exportFolder, 'dir')
    mkdir(exportFolder);
end

% Create zip file
exportFilePath = fullfile(exportFolder, [exportName, '.zip']);
if exist(exportFilePath, 'file')
    fprintf('Using existing zip file: %s\n', exportFilePath);
else
    fprintf('Creating zip file: %s\n', exportFilePath);
    zip(exportFilePath, strcat(exportFilesPrefix, filesep, exportFiles));
end