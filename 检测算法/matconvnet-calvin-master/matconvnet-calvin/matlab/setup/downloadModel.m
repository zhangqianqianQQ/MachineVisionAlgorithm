function downloadModel(modelName)
% downloadModel(modelName)
%
% Downloads and unzips a trained model.
%
% Copyright by Holger Caesar, 2016

% Settings
global glBaseFolder;
baseUrl = 'http://groups.inf.ed.ac.uk/calvin/caesar16eccv';
downloadFolder = fullfile(glBaseFolder, 'Downloads');
if strcmp(modelName, 'frcn')
    exportName = 'FRCN_VOC2010_model';
    exportFilesTarget = fullfile(glBaseFolder, 'Features', 'CNN-Models', 'FRCN', 'VOC2010', 'VOC2010-testRelease');
elseif strcmp(modelName, 'fcn')
    exportName = 'FCN_SiftFlow_model';
    exportFilesTarget = fullfile(glBaseFolder, 'Features', 'CNN-Models', 'FCN', 'SiftFlow', 'fcn16s-testRelease');
elseif strcmp(modelName, 'e2s2_fast')
    exportName = 'E2S2_SiftFlow_model_fast';
    exportFilesTarget = fullfile(glBaseFolder, 'Features', 'CNN-Models', 'E2S2', 'SiftFlow', 'Run1', 'SiftFlow_e2s2_run1_exp1');
elseif strcmp(modelName, 'e2s2_full')
    exportName = 'E2S2_SiftFlow_model_full';
    exportFilesTarget = fullfile(glBaseFolder, 'Features', 'CNN-Models', 'E2S2', 'SiftFlow', 'Run1', 'SiftFlow_e2s2_run1_exp2');
else
    error('Error: Unknown model: %s', modelName);
end

% Create folder
if ~exist(downloadFolder, 'dir')
    mkdir(downloadFolder);
end

% Download model
url = fullfile(baseUrl, [exportName, '.zip']);
downloadPath = fullfile(downloadFolder, [exportName, '.zip']);
if exist(downloadPath, 'file')
    fprintf('Using existing model file: %s\n', downloadPath);
else
    fprintf('Downloading model to: %s\n', downloadPath);
    websave(downloadPath, url);
end

% Unzip model
if exist(exportFilesTarget, 'dir')
    fprintf('Using existing model in: %s\n', exportFilesTarget);
else
    fprintf('Unzipping model to: %s\n', exportFilesTarget);
    unzip(downloadPath, exportFilesTarget);
end