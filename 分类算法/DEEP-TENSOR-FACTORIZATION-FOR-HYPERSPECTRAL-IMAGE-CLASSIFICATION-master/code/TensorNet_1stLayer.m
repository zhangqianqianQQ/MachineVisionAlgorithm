%% Simple Fixed main strcture
Layers = cell(1,3);
% Layers{1,1} = [8 4 1];
% Layers{1,2} = [10 5 2];
% Layers{1,3} = [17 8 4];
% Layers{1,4} = [29 10 5];
% Layers{1,5} = [44 15 7];
Layers{1,1} = [7 20 10];
Layers{1,2} = [13 24 12];
Layers{1,3} = [17 30 15];
% Layers{1,1} = [200 20 10];
% Layers{1,2} = [250 24 12];
% Layers{1,3} = [300 30 15];
% ConvFilter.PatchSize = 1;
% ConvFilter.Channel = 3;
%% IndianPines Dataset and Mask
load('D:\Workspace\HSI\trunk\Experiments\data\92AV3C\non-noise\DataCube.mat');
load('D:\Workspace\HSI\trunk\Experiments\data\92AV3C\non-noise\Label0.mat');
load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\IndianPines_nonnoise\5times_Experiments\IndianPines_first_mask.mat');
% load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\IndianPines_nonnoise\5times_Experiments\IndianPines_second_mask.mat');
%% PaviaUniversity Dataset and Mask
% load('D:\Workspace\HSI\trunk\datasets\pavia university\PaviaU.mat');
% load('D:\Workspace\HSI\trunk\datasets\pavia university\PaviaU_gt.mat');
% paviaU_gt = double(paviaU_gt);
% load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\PaviaUniversity\5times_Experiments\PaviaU_first_mask.mat');
% load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\PaviaUniversity\5times_Experiments\PaviaU_second_mask.mat');
% load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\PaviaUniversity\5times_Experiments\amount.mat');
%% Salinas Dataset and Mask
% load('D:\Workspace\HSI\trunk\datasets\Salinas\Salinas_corrected.mat');
% load('D:\Workspace\HSI\trunk\datasets\Salinas\Salinas_gt.mat');
% load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\Salinas\5times_Experiments\salinas_firstmask.mat');
% load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\Salinas\5times_Experiments\salinas_secondmask.mat');
% load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\Salinas\5times_Experiments\amount.mat');
%% Botswana Dataset and Mask
% load('D:\Workspace\HSI\trunk\datasets\Botswana\Botswana.mat');
% load('D:\Workspace\HSI\trunk\datasets\Botswana\Botswana_gt.mat');
% load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\Botswana\5times_Experiments\Botswana_first_mask.mat');
% load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\Botswana\5times_Experiments\Botswana_second_mask.mat');
%%
num_expets = size(Layers,2);
Penalty = zeros(5,num_expets);
Kappa = zeros(5,num_expets);
OAPredict = zeros(5,num_expets);
AAPredict = zeros(5,num_expets);
OAOfTrain = cell(5,num_expets);
OAPerclass = cell(5,num_expets);
for i=1:num_expets
    tic;
    % Forming ConvFilter
    % W = FormingConvFilter(paviaU,ConvFilter,Layers{i}(1));
    % Convolution
    % Datacube_conved = Convolution(paviaU,W,ConvFilter);
    Datacube_conved{1,1} = finalsub;
    % CP Decomposition
    ktensor = CPDecompose(Datacube_conved,Layers{i}(1));
    % Pooling
    Datacube_pooled = Pooling(ktensor);
    % Concatenation
    combined_Datacube = Concatenation(Datacube_pooled);
    % Classification
    [data,label] = reshape_data(combined_Datacube,Label0);
    % Normalization
    normed_data = normalization_all(data);
    for iter=1:5
        % IndianPines
        [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_ratioSample(1,0.05,normed_data,label,IndianPines_first_mask{iter});
        % PaviaUniversity
        % [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_SampleSpecial(0.01,normed_data,label,PaviaU_first_mask{iter},amount);
        % Salinas
        % [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_fixedSample(30,normed_data,label,salinas_firstmask{iter});
        % Botswana
        % [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_ratioSample(1,0.05,normed_data,label,Botswana_second_mask{iter});
        [OAOfTrain{iter,i},Penalty(iter,i)] = svm_train_linear(selTrainData,selTrainLabel,[-5,5],1);
        [OAPredict(iter,i),AAPredict(iter,i),OAPerclass{iter,i},Kappa(iter,i)] = svm_predict_linear(Penalty(iter,i),selTrainData,selTrainLabel,selTestData,selTestLabel);
    end
    toc;
end
OA = mean(OAPredict);
AA = mean(AAPredict);
% kap = mean(Kappa);
% oaperclass = cell(1,num_expets);
% for i=1:num_expets
%     tempOAPerclass = 0;
%     for j=1:5
%         tempOAPerclass = tempOAPerclass + OAPerclass{j,i};
%     end
%     oaperclass{i} = tempOAPerclass ./ 5;
% end