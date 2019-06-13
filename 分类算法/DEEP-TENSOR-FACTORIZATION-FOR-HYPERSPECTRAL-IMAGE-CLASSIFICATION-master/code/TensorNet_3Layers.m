%% Simple Fixed main strcture
Layers = cell(1,3);
Layers{1,1} = [4 2 1];
Layers{1,2} = [8 4 1];
Layers{1,3} = [10 5 2];
% Layers{1,4} = [29 10 5];
% Layers{1,5} = [44 15 7];
% Layers{1,1} = [66 20 10];
% Layers{1,2} = [96 24 12];
% Layers{1,3} = [132 30 15];
ConvFilter.PatchSize = 1;
ConvFilter.Channel = 3;
%% IndianPines Dataset and Mask
% load('D:\Workspace\HSI\trunk\Experiments\data\92AV3C\non-noise\DataCube.mat');
% load('D:\Workspace\HSI\trunk\Experiments\data\92AV3C\non-noise\Label0.mat');
% load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\IndianPines_nonnoise\5times_Experiments\IndianPines_first_mask.mat');
% load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\IndianPines_nonnoise\5times_Experiments\IndianPines_second_mask.mat');
%% PaviaUniversity Dataset and Mask
% load('D:\Workspace\HSI\trunk\datasets\pavia university\PaviaU.mat');
% load('D:\Workspace\HSI\trunk\datasets\pavia university\PaviaU_gt.mat');
% paviaU_gt = double(paviaU_gt);
% load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\PaviaUniversity\5times_Experiments\PaviaU_first_mask.mat');
% load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\PaviaUniversity\5times_Experiments\PaviaU_second_mask.mat');
% load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\PaviaUniversity\5times_Experiments\amount.mat');
%% Salinas Dataset and Mask
load('D:\Workspace\HSI\trunk\datasets\Salinas\Salinas_corrected.mat');
load('D:\Workspace\HSI\trunk\datasets\Salinas\Salinas_gt.mat');
% load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\Salinas\5times_Experiments\salinas_firstmask.mat');
load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\Salinas\5times_Experiments\salinas_secondmask.mat');
load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\Salinas\5times_Experiments\amount.mat');
%% Botswana Dataset and Mask
% load('D:\Workspace\HSI\trunk\datasets\Botswana\Botswana.mat');
% load('D:\Workspace\HSI\trunk\datasets\Botswana\Botswana_gt.mat');
% load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\Botswana\5times_Experiments\Botswana_first_mask.mat');
% load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\Botswana\5times_Experiments\Botswana_second_mask.mat');
cube = salinas_corrected;
gt = salinas_gt;
%%
num_expets = size(Layers,2);

Penalty1 = zeros(5,num_expets);
Kappa1 = zeros(5,num_expets);
OAPredict1 = zeros(5,num_expets);
AAPredict1 = zeros(5,num_expets);
OAPerclass1 = cell(5,num_expets);

Penalty2 = zeros(5,num_expets);
Kappa2 = zeros(5,num_expets);
OAPredict2 = zeros(5,num_expets);
AAPredict2 = zeros(5,num_expets);
OAPerclass2 = cell(5,num_expets);

Penalty3 = zeros(5,num_expets);
Kappa3 = zeros(5,num_expets);
OAPredict3 = zeros(5,num_expets);
AAPredict3 = zeros(5,num_expets);
OAPerclass3 = cell(5,num_expets);

Penalty123 = zeros(5,num_expets);
Kappa123 = zeros(5,num_expets);
OAPredict123 = zeros(5,num_expets);
AAPredict123 = zeros(5,num_expets);
OAPerclass123 = cell(5,num_expets);
%%
for i=1:num_expets
    %% First Layer
    W1 = FormingConvFilter(cube,ConvFilter,Layers{i}(1));
    Datacube_conved1 = Convolution(cube,W1,ConvFilter);
    ktensor1 = CPDecompose(Datacube_conved1,Layers{i}(1));
    Datacube_pooled1 = Pooling(ktensor1);
    combined_Datacube1 = Concatenation(Datacube_pooled1);
    % Second Layer: Classification
    [data,label] = reshape_data(combined_Datacube1,gt);
    % Normalization
    normed_data = normalization_all(data);
    for iter=1:5
        % IndianPines
        % [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_ratioSample(1,0.1,normed_data,label,IndianPines_second_mask{iter});
        % PaviaUniversity
        % [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_SampleSpecial(0.01,normed_data,label,PaviaU_first_mask{iter},amount);
        % Salinas
        % [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_fixedSample(30,normed_data,label,salinas_firstmask{iter});
        [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_SampleSpecial(amount,normed_data,label,salinas_secondmask{iter});
        % Botswana
        % [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_ratioSample(1,0.05,normed_data,label,Botswana_second_mask{iter});
        [~,Penalty1(iter,i)] = svm_train_linear(selTrainData,selTrainLabel,[-5,5],1);
        [OAPredict1(iter,i),AAPredict1(iter,i),OAPerclass1{iter,i},Kappa1(iter,i)] = svm_predict_linear(Penalty1(iter,i),selTrainData,selTrainLabel,selTestData,selTestLabel);
    end
    %% Second Layer
    W2 = FormingConvFilter(combined_Datacube1,ConvFilter,Layers{i}(2));
    Datacube_conved2 = Convolution(combined_Datacube1,W2,ConvFilter);
    ktensor2 = CPDecompose(Datacube_conved2,Layers{i}(2));
    Datacube_pooled2 = Pooling(ktensor2);
    combined_Datacube2 = Concatenation(Datacube_pooled2);
    % Second Layer: Classification
    [data,label] = reshape_data(combined_Datacube2,gt);
    % Normalization
    normed_data = normalization_all(data);
    for iter=1:5
        % IndianPines
        % [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_ratioSample(1,0.1,normed_data,label,IndianPines_second_mask{iter});
        % PaviaUniversity
        % [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_SampleSpecial(0.01,normed_data,label,PaviaU_first_mask{iter},amount);
        % Salinas
        % [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_fixedSample(30,normed_data,label,salinas_firstmask{iter});
        [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_SampleSpecial(amount,normed_data,label,salinas_secondmask{iter});
        % Botswana
        % [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_ratioSample(1,0.05,normed_data,label,Botswana_second_mask{iter});
        [~,Penalty2(iter,i)] = svm_train_linear(selTrainData,selTrainLabel,[-5,5],1);
        [OAPredict2(iter,i),AAPredict2(iter,i),OAPerclass2{iter,i},Kappa2(iter,i)] = svm_predict_linear(Penalty2(iter,i),selTrainData,selTrainLabel,selTestData,selTestLabel);
    end
    %% Third Layer
    W3 = FormingConvFilter(combined_Datacube2,ConvFilter,Layers{i}(3));
    Datacube_conved3 = Convolution(combined_Datacube2,W3,ConvFilter);
    ktensor3 = CPDecompose(Datacube_conved3,Layers{i}(3));
    Datacube_pooled3 = Pooling(ktensor3);
    combined_Datacube3 = Concatenation(Datacube_pooled3);
    % Third Layer: Classification
    [data,label] = reshape_data(combined_Datacube3,gt);
    % Normalization
    normed_data = normalization_all(data);
    for iter=1:5
        % IndianPines
        % [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_ratioSample(1,0.1,normed_data,label,IndianPines_second_mask{iter});
        % PaviaUniversity
        % [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_SampleSpecial(0.01,normed_data,label,PaviaU_first_mask{iter},amount);
        % Salinas
        % [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_fixedSample(30,normed_data,label,salinas_firstmask{iter});
        [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_SampleSpecial(amount,normed_data,label,salinas_secondmask{iter});
        % Botswana
        % [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_ratioSample(1,0.05,normed_data,label,Botswana_second_mask{iter});
        [~,Penalty3(iter,i)] = svm_train_linear(selTrainData,selTrainLabel,[-5,5],1);
        [OAPredict3(iter,i),AAPredict3(iter,i),OAPerclass3{iter,i},Kappa3(iter,i)] = svm_predict_linear(Penalty3(iter,i),selTrainData,selTrainLabel,selTestData,selTestLabel);
    end
    % Combined 123 Layer to Classification
    Datacube12 = cell(2,1);
    Datacube12{1,1} = combined_Datacube1;
    Datacube12{2,1} = combined_Datacube2;
    combined_Datacube12 = Concatenation(Datacube12);
    Datacube123 = cell(2,1);
    Datacube123{1,1} = combined_Datacube12;
    Datacube123{2,1} = combined_Datacube3;
    combined_Datacube123 = Concatenation(Datacube123);
    [data,label] = reshape_data(combined_Datacube123,gt);
    % Normalization
    normed_data = normalization_all(data);
    for iter=1:5
        % IndianPines
        % [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_ratioSample(1,0.1,normed_data,label,IndianPines_second_mask{iter});
        % PaviaUniversity
        % [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_SampleSpecial(0.01,normed_data,label,PaviaU_first_mask{iter},amount);
        % Salinas
        % [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_fixedSample(30,normed_data,label,salinas_firstmask{iter});
        [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_SampleSpecial(amount,normed_data,label,salinas_secondmask{iter});
        % Botswana
        % [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_ratioSample(1,0.05,normed_data,label,Botswana_second_mask{iter});
        [~,Penalty123(iter,i)] = svm_train_linear(selTrainData,selTrainLabel,[-5,5],1);
        [OAPredict123(iter,i),AAPredict123(iter,i),OAPerclass123{iter,i},Kappa123(iter,i)] = svm_predict_linear(Penalty123(iter,i),selTrainData,selTrainLabel,selTestData,selTestLabel);
    end
end
kap1 = mean(Kappa1);
OA1 = mean(OAPredict1);
AA1 = mean(AAPredict1);
kap2 = mean(Kappa2);
OA2 = mean(OAPredict2);
AA2 = mean(AAPredict2);
kap3 = mean(Kappa3);
OA3 = mean(OAPredict3);
AA3 = mean(AAPredict3);
kap123 = mean(Kappa123);
OA123 = mean(OAPredict123);
AA123 = mean(AAPredict123);








