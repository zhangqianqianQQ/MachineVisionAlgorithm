function downloadVOC2010()
% downloadVOC2010()
%
% Downloads and unpacks the PASCAL VOC 2010 dataset.
%
% Copyright by Holger Caesar, 2016

% Settings
zipNameData = 'VOCtrainval_03-May-2010.tar';
zipNameDevkit = 'VOCdevkit_08-May-2010.tar';
urlData = 'http://host.robots.ox.ac.uk/pascal/VOC/voc2010/VOCtrainval_03-May-2010.tar';
urlDevkit = 'http://host.robots.ox.ac.uk/pascal/VOC/voc2010/VOCdevkit_08-May-2010.tar';
rootFolder = calvin_root();
datasetFolder = fullfile(rootFolder, 'data', 'Datasets', 'VOC2010');
downloadFolder = fullfile(rootFolder, 'data', 'Downloads');
zipFileData = fullfile(downloadFolder, zipNameData);
zipFileDevkit = fullfile(downloadFolder, zipNameDevkit);
dataFolder = fullfile(datasetFolder, 'VOCdevkit', 'VOC2010', 'JPEGImages');
devkitFolder = fullfile(datasetFolder, 'VOCdevkit', 'VOCcode');

% Download dataset
if ~exist(devkitFolder, 'dir')
    % Create folder
    if ~exist(datasetFolder, 'dir')
        mkdir(datasetFolder);
    end
    if ~exist(downloadFolder, 'dir')
        mkdir(downloadFolder);
    end
    
    % Download data
    if ~exist(dataFolder, 'dir')
        % Download tar file
        if ~exist(zipFileData, 'file')
            fprintf('Downloading VOC 2010 dataset (1.3GB)...\n');
            websave(zipFileData, urlData);
        end
        
        % Untar it
        fprintf('Unpacking VOC 2010 dataset...\n');
        untar(zipFileData, datasetFolder);
    end
    
    % Download devkit
    if ~exist(devkitFolder, 'dir')
        % Download tar file
        if ~exist(zipFileDevkit, 'file')
            fprintf('Downloading VOC 2010 devkit (0.3MB)...\n');
            websave(zipFileDevkit, urlDevkit);
        end
        
        % Untar it
        fprintf('Unpacking VOC 2010 devkit...\n');
        untar(zipFileDevkit, datasetFolder);
    end
end

% Add to path
addpath(devkitFolder);
