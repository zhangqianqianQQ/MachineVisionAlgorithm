%This is  a  sample demo
%Test Digits dataset
addpath('tools/');
addpath('print/');
options = [];
options.maxIter = 200;
options.error = 1e-6;
options.nRepeat = 30;
options.minIter = 50;
options.meanFitRatio = 0.1;
options.rounds = 30;
options.K=10;
options.Gaplpha=100;
options.WeightMode='Binary';


% options.kmeans means whether to run kmeans on v^* or not
% options alpha is an array of weights for different views

options.alphas = [0.01 0.01];
options.kmeans = 1;
options.beta=10;

%% read dataset

load handwritten.mat
data{1} = fourier';
data{2} = pixel';   
K = 10;


%% normalize data matrix

for i = 1:length(data)
%     dtemp=computeDistMat(data{i},2);
%     W{i}=constructW(dtemp,20);
%     data{i} = data{i} / sum(sum(data{i}));
    options.WeightMode='Binary';
    W{i}=constructW_cai(data{i},options);
    data{i} = data{i} / sum(sum(data{i}));
end
%save('handwrittenW','W');
%%

% run 20 times
U_final = cell(1,3);
V_final = cell(1,3);
V_centroid = cell(1,3);
for i = 1:20
   [U_final{i}, V_final{i}, V_centroid{i} log] = GMultiNMF(data, K, W,gnd, options);
   printResult( V_centroid{i}, gnd, K, options.kmeans);
   fprintf('\n');
end
