% Variable and definition declaration

global VOC07PATH VOCCLASS;

VOC07PATH = '/home/iqbal/datasets/VOCdevkit/VOC2007/';
VOCCLASS = {'aeroplane' 'bicycle' 'bird' 'boat' 'bottle' 'bus' 'car' 'cat' 'chair' 'cow' 'diningtable' 'dog' 'horse' 'motorbike' 'person' 'pottedplant' 'sheep' 'sofa' 'train' 'tvmonitor'};


% Path declaration
addpath('/home/iqbal/datasets/VOCdevkit/VOCcode');
addpath('/home/iqbal/caffe/matlab/caffe');
addpath('/home/iqbal/dependency/SelectiveSearchCodeIJCV');
addpath('/home/iqbal/dependency/SelectiveSearchCodeIJCV/Dependencies');
addpath('/home/iqbal/dependency/liblinear-1.96/matlab');
