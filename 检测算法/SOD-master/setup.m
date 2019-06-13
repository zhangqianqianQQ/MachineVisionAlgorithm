% set your mat caffe path
matcaffePath = '/research/cbi/jmzhang_work_dir/caffe-master/matlab/';
addpath(matcaffePath)
addpath(genpath('./'))

% default: using GoogleNet
% other option: VGG16 which is used in the paper
param = getParam('GoogleNet');  
% param = getParam('VGG16');

net = initModel(param);