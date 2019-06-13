function downloadSiftFlow()
% downloadSiftFlow()
%
% Downloads and unpacks the SIFT Flow dataset.
%
% Copyright by Holger Caesar, 2016

% Settings
zipName = 'SiftFlowDataset.zip';
url = 'http://www.cs.unc.edu/~jtighe/Papers/ECCV10/siftflow/SiftFlowDataset.zip';
rootFolder = calvin_root();
datasetFolder = fullfile(rootFolder, 'data', 'Datasets', 'SiftFlow');
downloadFolder = fullfile(rootFolder, 'data', 'Downloads');
zipFile = fullfile(downloadFolder, zipName);
semanticLabelFolder = fullfile(datasetFolder, 'SemanticLabels');
metaFolder = fullfile(datasetFolder, 'Meta');

% Download dataset
if ~exist(metaFolder, 'file')
    % Create folder
    if ~exist(datasetFolder, 'dir')
        mkdir(datasetFolder);
    end
    if ~exist(downloadFolder, 'dir')
        mkdir(downloadFolder);
    end
    
    % Download zip file
    if ~exist(zipFile, 'file')
        fprintf('Downloading SIFT Flow dataset (140MB)...\n');
        websave(zipFile, url);
    end
    
    % Unzip it
    if ~exist(semanticLabelFolder, 'dir')
        fprintf('Unpacking SIFT Flow dataset...\n');
        unzip(zipFile, datasetFolder);
    end
    
    % Create meta folder
    if ~exist(metaFolder, 'dir')
        mkdir(metaFolder);
    end
end
