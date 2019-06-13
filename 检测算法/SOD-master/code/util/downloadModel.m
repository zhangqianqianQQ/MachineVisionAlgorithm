function downloadModel(modelName)

if strcmp(modelName, 'GoogleNet')
    fprintf('downloading GoogleNet model files\n'); 
    if ~exist(fullfile('model',modelName), 'dir')
        mkdir(fullfile('model',modelName));
    end
    urlwrite('http://www.cs.bu.edu/groups/ivc/Subitizing/model/GoogleNet/deploy.prototxt', ...
        fullfile('model', modelName, 'deploy.prototxt'));
    urlwrite('http://www.cs.bu.edu/groups/ivc/Subitizing/model/GoogleNet/GoogleNet_SOD_finetune.caffemodel', ...
        fullfile('model', modelName, 'GoogleNet_SOD_finetune.caffemodel'));
elseif strcmp(modelName, 'VGG16')
    fprintf('downloading VGG16 model files\n'); 
    if ~exist(fullfile('model',modelName), 'dir')
        mkdir(fullfile('model',modelName));
    end
    urlwrite('http://www.cs.bu.edu/groups/ivc/Subitizing/model/VGG16/deploy.prototxt', ...
        fullfile('model', modelName, 'deploy.prototxt'));
    urlwrite('http://www.cs.bu.edu/groups/ivc/Subitizing/model/VGG16/VGG16_SOD_finetune.caffemodel', ...
        fullfile('model', modelName, 'VGG16_SOD_finetune.caffemodel'));
else
    fprintf('model name not known\n');
end