clear all;
clc;

addpath(genpath('.'))

trainSameLabelClassifier;
trainSegmentSaliencyRegressor;

% it is very time consuming to learn the fusiong weight
% in practice, we found the uniform weight performs well
% learnFusionWeight;

% let's simply set the fusion weight to 1
seg_para = [0.8000  100.0000  150.0000;
            0.8000  400.0000  300.0000;
            0.9000  200.0000  200.0000;
            0.9000  100.0000  200.0000;
            0.8000  300.0000  150.0000;
            1.0000  200.0000  150.0000;
            0.9000  300.0000  300.0000;
            1.0000  100.0000  150.0000;
            1.0000  500.0000  300.0000;
            0.9000  200.0000  300.0000;
            0.8000  600.0000  200.0000;
            1.0000  600.0000  300.0000;
            0.8000  200.0000  150.0000;
            1.0000  500.0000  200.0000;
            0.8000  400.0000  150.0000;
            1.0000  300.0000  150.0000;
            0.8000  100.0000  200.0000;
            0.8000  100.0000  300.0000;
            0.8000  200.0000  200.0000;
            0.8000  200.0000  300.0000;
            0.8000  300.0000  200.0000;
            0.8000  300.0000  300.0000;
            0.8000  400.0000  200.0000;
            0.8000  500.0000  150.0000;
            0.8000  500.0000  200.0000];

w = ones(size(seg_para, 1), 1);

regressor = load( 'trained_classifiers\segment_saliency_regressor_200_15_rf.mat' );
segment_saliency_regressor = regressor.segment_saliency_regressor;
para = seg_para;

if ~exist('model', 'dir')
    mkdir( 'model' );
end

save( 'model/drfiModelMatlab.mat', 'segment_saliency_regressor', 'w', 'para' );