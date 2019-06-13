function downloadNetwork(varargin)
% downloadNetwork()
%
% Downloads the VGG-16 network model.
%
% Copyright by Holger Caesar, 2016

% Parse input
p = inputParser;
addParameter(p, 'modelName', 'imagenet-vgg-verydeep-16');
addParameter(p, 'version', ''); % use latest version, otherwise betaXX
parse(p, varargin{:});

modelName = p.Results.modelName;
version = p.Results.version;

% Settings
url = sprintf('http://www.vlfeat.org/matconvnet/models%s/%s.mat', prependNotEmpty(version, '/'), modelName);
rootFolder = calvin_root();
modelFolder = fullfile(rootFolder, 'data', 'Features', 'CNN-Models', 'matconvnet');
modelPath = fullfile(modelFolder, sprintf('%s%s.mat', modelName, prependNotEmpty(version, '_')));

% Download network
if ~exist(modelPath, 'file')
    % Create folder
    if ~exist(modelFolder, 'dir')
        mkdir(modelFolder);
    end
    
    % Download model
    if ~exist(modelPath, 'dir')
        fprintf('Downloading model (0.5GB)...\n');
        websave(modelPath, url);
    end
end
