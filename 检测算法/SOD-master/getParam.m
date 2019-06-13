function param = getParam(modelName)

param.modelName = modelName;
% See the paper for the meaning of the following three parameters
param.lambda = 0.075;
param.gamma = 1;
param.phi = log(0.3);
% The maximum output number
param.maxnum = 30;
% By default, we perturb the initialization of our optimization for better
% local maxima
param.perturb = true;
% The number of proposals used from the whole image
param.masterImgPropN = 30;
% The number of proposals used from each sub-image
param.subImgPropN = 10;
% The number of sub-images (rois)
param.roiN = 5;
% This parameter is used for merging similar rois
param.roiClusterCutoff = 0.3;
param.roiExpand = 1;
% 100 proposal centers
load center100
param.center = center;
% The following parameters are for the CNN model
param.protoFile = fullfile('model', modelName, 'deploy.prototxt');
param.modelFile = fullfile('model', modelName, ...
    sprintf('%s_SOD_finetune.caffemodel', modelName));
param.useGPU = true;
param.GPUID = 0;
param.width = 224;
param.height = 224;
param.batchSize = 10;
param.imageMean = single(repmat(reshape([103.939 116.779 123.68],1,1,3),...
    [param.height, param.width, 1]));

