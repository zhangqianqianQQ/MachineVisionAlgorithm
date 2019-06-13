function downloadSelectiveSearch()
% downloadSelectiveSearch()
%
% Downloads and unpacks the Selective Search region proposal method.
%
% Copyright by Holger Caesar, 2016

% Settings
zipName = 'SelectiveSearchCodeIJCV.zip';
url = 'http://koen.me/research/downloads/SelectiveSearchCodeIJCV.zip';
rootFolder = calvin_root();
codeFolder = fullfile(rootFolder, 'data', 'Code');
downloadFolder = fullfile(rootFolder, 'data', 'Downloads');
zipFile = fullfile(downloadFolder, zipName);
checkFile = fullfile(codeFolder, 'SelectiveSearchCodeIJCV', 'Image2HierarchicalGrouping.m');

% Download dataset
if ~exist(checkFile, 'file')
    % Create folder
    if ~exist(codeFolder, 'dir')
        mkdir(codeFolder);
    end
    if ~exist(downloadFolder, 'dir')
        mkdir(downloadFolder);
    end
    
    % Download zip file
    if ~exist(zipFile, 'file')
        fprintf('Downloading Selective Search (0.3MB)...\n');
        websave(zipFile, url);
    end
    
    % Unzip it
    if ~exist(checkFile, 'file')
        fprintf('Unpacking Selective Search...\n');
        unzip(zipFile, codeFolder);
    end
end

% Add to path
addpath(genpath(fullfile(codeFolder, 'SelectiveSearchCodeIJCV')));
