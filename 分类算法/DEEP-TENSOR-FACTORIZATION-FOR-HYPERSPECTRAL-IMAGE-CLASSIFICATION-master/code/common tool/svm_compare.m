% Script for SVM
% Caculate Automatically

tic;
% IndianPines_nonnoise dataset
load('D:\Workspace\HSI\trunk\Experiments\data\92AV3C\non-noise\DataCube.mat');
load('D:\Workspace\HSI\trunk\Experiments\data\92AV3C\non-noise\Label0.mat');
load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\IndianPines_nonnoise\5times_Experiments\IndianPines_first_mask.mat');
% 5% results + SVM_RBF
% IndianPines_5_SVMRBF_penalty = cell(1,5);
% IndianPines_5_SVMRBF_gamma = cell(1,5);
% IndianPines_5_SVMRBF_OA = cell(1,5);
% IndianPines_5_SVMRBF_AA = cell(1,5);
% IndianPines_5_SVMRBF_OAPerclass = cell(1,5);
% IndianPines_5_SVMRBF_Kappa = cell(1,5);
% [data,label] = reshape_data(finalsub,Label0);
% normed_data = normalization_all(data);
% parfor iter = 1:5
%     [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_ratioSample(1,0.05,normed_data,label,IndianPines_first_mask{iter});
%     % training
%     [~,IndianPines_5_SVMRBF_penalty{iter},IndianPines_5_SVMRBF_gamma{iter}] = svm_train(selTrainData,selTrainLabel,[-5,5],[-5,5],1,1);
%     % predicting
%     [IndianPines_5_SVMRBF_OA{iter},IndianPines_5_SVMRBF_AA{iter},IndianPines_5_SVMRBF_OAPerclass{iter},IndianPines_5_SVMRBF_Kappa{iter}] = svm_predict(IndianPines_5_SVMRBF_penalty{iter},IndianPines_5_SVMRBF_gamma{iter},selTrainData,selTrainLabel,selTestData,selTestLabel);
% end
% save IndianPines_5_SVMRBF.mat IndianPines_5_SVMRBF_AA IndianPines_5_SVMRBF_OA IndianPines_5_SVMRBF_penalty IndianPines_5_SVMRBF_gamma
% clear IndianPines_5_SVMRBF_AA IndianPines_5_SVMRBF_OA IndianPines_5_SVMRBF_penalty IndianPines_5_SVMRBF_gamma

% 5% results + SVM_linear
IndianPines_5_SVMLinear_penalty = cell(1,5);
IndianPines_5_SVMLinear_OA = cell(1,5);
IndianPines_5_SVMLinear_OAPerclass = cell(1,5);
IndianPines_5_SVMLinear_AA = cell(1,5);
IndianPines_5_SVMLinear_Kappa = cell(1,5);
[data,label] = reshape_data(finalsub,Label0);
normed_data = normalization_all(data);
parfor iter = 1:5
    [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_ratioSample(1,0.05,normed_data,label,IndianPines_first_mask{iter});
    % training
    [~,IndianPines_5_SVMLinear_penalty{iter}] = svm_train_linear(selTrainData,selTrainLabel,[-5,5],1);
    % predicting
    [IndianPines_5_SVMLinear_OA{iter},IndianPines_5_SVMLinear_AA{iter},IndianPines_5_SVMLinear_OAPerclass{iter},IndianPines_5_SVMLinear_Kappa{iter}] = svm_predict_linear(IndianPines_5_SVMLinear_penalty{iter},selTrainData,selTrainLabel,selTestData,selTestLabel);
end
save IndianPines_5_SVMLinear.mat IndianPines_5_SVMLinear_AA IndianPines_5_SVMLinear_OA IndianPines_5_SVMLinear_penalty IndianPines_5_SVMLinear_OAPerclass IndianPines_5_SVMLinear_Kappa
clear IndianPines_5_SVMLinear_AA IndianPines_5_SVMLinear_OA IndianPines_5_SVMLinear_penalty IndianPines_first_mask IndianPines_5_SVMLinear_OAPerclass IndianPines_5_SVMLinear_Kappa

% 10% results + SVM_RBF
load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\IndianPines_nonnoise\5times_Experiments\IndianPines_second_mask.mat');
% IndianPines_10_SVMRBF_penalty = cell(1,5);
% IndianPines_10_SVMRBF_gamma = cell(1,5);
% IndianPines_10_SVMRBF_OA = cell(1,5);
% IndianPines_10_SVMRBF_AA = cell(1,5);
% [data,label] = reshape_data(finalsub,Label0);
% normed_data = normalization_all(data);
% for iter = 1:5
%     [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_ratioSample(1,0.1,normed_data,label,IndianPines_10perclass_mask{iter});
%     % training
%     [~,IndianPines_10_SVMRBF_penalty{iter},IndianPines_10_SVMRBF_gamma{iter}] = svm_train(selTrainData,selTrainLabel,[-10,10],[-10,10],1,1);
%     % predicting
%     [IndianPines_10_SVMRBF_OA{iter},IndianPines_10_SVMRBF_AA{iter}] = svm_predict(IndianPines_10_SVMRBF_penalty{iter},IndianPines_10_SVMRBF_gamma{iter},selTrainData,selTrainLabel,selTestData,selTestLabel);
% end
% save IndianPines_10_SVMRBF.mat IndianPines_10_SVMRBF_AA IndianPines_10_SVMRBF_OA IndianPines_10_SVMRBF_penalty IndianPines_10_SVMRBF_gamma
% clear IndianPines_10_SVMRBF_AA IndianPines_10_SVMRBF_OA IndianPines_10_SVMRBF_penalty IndianPines_10_SVMRBF_gamma

% 10% results + SVM_Linear
IndianPines_10_SVMLinear_penalty = cell(1,5);
IndianPines_10_SVMLinear_OA = cell(1,5);
IndianPines_10_SVMLinear_OAPerclass = cell(1,5);
IndianPines_10_SVMLinear_AA = cell(1,5);
IndianPines_10_SVMLinear_Kappa = cell(1,5);
[data,label] = reshape_data(finalsub,Label0);
normed_data = normalization_all(data);
parfor iter = 1:5
    [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_ratioSample(1,0.1,normed_data,label,IndianPines_second_mask{iter});
    % training
    [~,IndianPines_10_SVMLinear_penalty{iter}] = svm_train_linear(selTrainData,selTrainLabel,[-5,5],1);
    % predicting
    [IndianPines_10_SVMLinear_OA{iter},IndianPines_10_SVMLinear_AA{iter},IndianPines_10_SVMLinear_OAPerclass{iter},IndianPines_10_SVMLinear_Kappa{iter}] = svm_predict_linear(IndianPines_10_SVMLinear_penalty{iter},selTrainData,selTrainLabel,selTestData,selTestLabel);
end
save IndianPines_10_SVMLinear.mat IndianPines_10_SVMLinear_AA IndianPines_10_SVMLinear_OA IndianPines_10_SVMLinear_penalty IndianPines_10_SVMLinear_OAPerclass IndianPines_10_SVMLinear_Kappa
clear


% Botswana Dataset
load('D:\Workspace\HSI\trunk\datasets\Botswana\Botswana.mat');
load('D:\Workspace\HSI\trunk\datasets\Botswana\Botswana_gt.mat');
load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\Botswana\5times_Experiments\Botswana_first_mask.mat');
% 5% results + SVM_RBF
% Botswana_5_SVMRBF_penalty = cell(1,5);
% Botswana_5_SVMRBF_gamma = cell(1,5);
% Botswana_5_SVMRBF_OA = cell(1,5);
% Botswana_5_SVMRBF_AA = cell(1,5);
% Botswana_5_SVMRBF_OAPerclass = cell(1,5);
% Botswana_5_SVMRBF_Kappa = cell(1,5);
% [data,label] = reshape_data(Botswana,Botswana_gt);
% normed_data = normalization_all(data);
% parfor iter = 1:5
%     [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_ratioSample(1,0.05,normed_data,label,Botswana_first_mask{iter});
%     % training
%     [~,Botswana_5_SVMRBF_penalty{iter},Botswana_5_SVMRBF_gamma{iter}] = svm_train(selTrainData,selTrainLabel,[-5,5],[-5,5],1,1);
%     % predicting
%     [Botswana_5_SVMRBF_OA{iter},Botswana_5_SVMRBF_AA{iter},Botswana_5_SVMRBF_OAPerclass{iter},Botswana_5_SVMRBF_Kappa{iter}] = svm_predict(Botswana_5_SVMRBF_penalty{iter},Botswana_5_SVMRBF_gamma{iter},selTrainData,selTrainLabel,selTestData,selTestLabel);
% end
% save Botswana_5_SVMRBF.mat Botswana_5_SVMRBF_AA Botswana_5_SVMRBF_OA Botswana_5_SVMRBF_penalty Botswana_5_SVMRBF_gamma
% clear Botswana_5_SVMRBF_AA Botswana_5_SVMRBF_OA Botswana_5_SVMRBF_penalty Botswana_5_SVMRBF_gamma

% 10% results + SVM_linear
Botswana_10_SVMLinear_penalty = cell(1,5);
Botswana_10_SVMLinear_OA = cell(1,5);
Botswana_10_SVMLinear_OAPerclass = cell(1,5);
Botswana_10_SVMLinear_AA = cell(1,5);
Botswana_10_SVMLinear_Kappa = cell(1,5);
[data,label] = reshape_data(Botswana,Botswana_gt);
normed_data = normalization_all(data);
parfor iter = 1:5
    [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_ratioSample(1,0.1,normed_data,label,Botswana_first_mask{iter});
    % training
    [~,Botswana_10_SVMLinear_penalty{iter}] = svm_train_linear(selTrainData,selTrainLabel,[-5,5],1);
    % predicting
    [Botswana_10_SVMLinear_OA{iter},Botswana_10_SVMLinear_AA{iter},Botswana_10_SVMLinear_OAPerclass{iter},Botswana_10_SVMLinear_Kappa{iter}] = svm_predict_linear(Botswana_10_SVMLinear_penalty{iter},selTrainData,selTrainLabel,selTestData,selTestLabel);
end
save Botswana_10_SVMLinear.mat Botswana_10_SVMLinear_AA Botswana_10_SVMLinear_OA Botswana_10_SVMLinear_penalty Botswana_10_SVMLinear_OAPerclass Botswana_10_SVMLinear_Kappa
clear Botswana_10_SVMLinear_AA Botswana_10_SVMLinear_OA Botswana_10_SVMLinear_penalty Botswana_first_mask Botswana_10_SVMLinear_OAPerclass Botswana_10_SVMLinear_Kappa

% 10% results + SVM_RBF
load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\Botswana\5times_Experiments\Botswana_second_mask.mat');
% Botswana_10_SVMRBF_penalty = cell(1,5);
% Botswana_10_SVMRBF_gamma = cell(1,5);
% Botswana_10_SVMRBF_OA = cell(1,5);
% Botswana_10_SVMRBF_AA = cell(1,5);
% [data,label] = reshape_data(finalsub,Label0);
% normed_data = normalization_all(data);
% for iter = 1:5
%     [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_ratioSample(1,0.1,normed_data,label,Botswana_10perclass_mask{iter});
%     % training
%     [~,Botswana_10_SVMRBF_penalty{iter},Botswana_10_SVMRBF_gamma{iter}] = svm_train(selTrainData,selTrainLabel,[-10,10],[-10,10],1,1);
%     % predicting
%     [Botswana_10_SVMRBF_OA{iter},Botswana_10_SVMRBF_AA{iter}] = svm_predict(Botswana_10_SVMRBF_penalty{iter},Botswana_10_SVMRBF_gamma{iter},selTrainData,selTrainLabel,selTestData,selTestLabel);
% end
% save Botswana_10_SVMRBF.mat Botswana_10_SVMRBF_AA Botswana_10_SVMRBF_OA Botswana_10_SVMRBF_penalty Botswana_10_SVMRBF_gamma
% clear Botswana_10_SVMRBF_AA Botswana_10_SVMRBF_OA Botswana_10_SVMRBF_penalty Botswana_10_SVMRBF_gamma

% 5% results + SVM_Linear
Botswana_5_SVMLinear_penalty = cell(1,5);
Botswana_5_SVMLinear_OA = cell(1,5);
Botswana_5_SVMLinear_OAPerclass = cell(1,5);
Botswana_5_SVMLinear_AA = cell(1,5);
Botswana_5_SVMLinear_Kappa = cell(1,5);
[data,label] = reshape_data(Botswana,Botswana_gt);
normed_data = normalization_all(data);
parfor iter = 1:5
    [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_ratioSample(1,0.05,normed_data,label,Botswana_second_mask{iter});
    % training
    [~,Botswana_5_SVMLinear_penalty{iter}] = svm_train_linear(selTrainData,selTrainLabel,[-5,5],1);
    % predicting
    [Botswana_5_SVMLinear_OA{iter},Botswana_5_SVMLinear_AA{iter},Botswana_5_SVMLinear_OAPerclass{iter},Botswana_5_SVMLinear_Kappa{iter}] = svm_predict_linear(Botswana_5_SVMLinear_penalty{iter},selTrainData,selTrainLabel,selTestData,selTestLabel);
end
save Botswana_5_SVMLinear.mat Botswana_5_SVMLinear_AA Botswana_5_SVMLinear_OA Botswana_5_SVMLinear_penalty Botswana_5_SVMLinear_OAPerclass Botswana_5_SVMLinear_Kappa
clear



% Pavia University 
load('D:\Workspace\HSI\trunk\datasets\pavia university\PaviaU.mat');
load('D:\Workspace\HSI\trunk\datasets\pavia university\PaviaU_gt.mat');
load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\PaviaUniversity\5times_Experiments\amount.mat');
% 1% results + SVMLinear
load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\PaviaUniversity\5times_Experiments\PaviaU_first_mask.mat');
PaviaU_1_SVMLinear_penalty = cell(1,5);
PaviaU_1_SVMLinear_OA = cell(1,5);
PaviaU_1_SVMLinear_OAPerclass = cell(1,5);
PaviaU_1_SVMLinear_AA = cell(1,5);
PaviaU_1_SVMLinear_Kappa = cell(1,5);
[data,label] = reshape_data(paviaU,paviaU_gt);
normed_data = normalization_all(data);
parfor iter = 1:5
    [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_SampleSpecial(0.01,normed_data,label,PaviaU_first_mask{iter},amount);
    % training
    [~,PaviaU_1_SVMLinear_penalty{iter}] = svm_train_linear(selTrainData,selTrainLabel,[-5,5],1);
    % predicting
    [PaviaU_1_SVMLinear_OA{iter},PaviaU_1_SVMLinear_AA{iter},PaviaU_1_SVMLinear_OAPerclass{iter},PaviaU_1_SVMLinear_Kappa{iter}] = svm_predict_linear(PaviaU_1_SVMLinear_penalty{iter},selTrainData,selTrainLabel,selTestData,selTestLabel);
end
save PaviaU_1_SVMLinear.mat PaviaU_1_SVMLinear_AA PaviaU_1_SVMLinear_OA PaviaU_1_SVMLinear_penalty PaviaU_1_SVMLinear_OAPerclass PaviaU_1_SVMLinear_Kappa
clear PaviaU_1_SVMLinear_AA PaviaU_1_SVMLinear_OA PaviaU_1_SVMLinear_penalty PaviaU_1_SVMLinear_OAPerclass PaviaU_1_SVMLinear_Kappa PaviaU_first_mask
% 10% results + SVMLinear
load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\PaviaUniversity\5times_Experiments\PaviaU_second_mask.mat');
PaviaU_10_SVMLinear_penalty = cell(1,5);
PaviaU_10_SVMLinear_OA = cell(1,5);
PaviaU_10_SVMLinear_OAPerclass = cell(1,5);
PaviaU_10_SVMLinear_AA = cell(1,5);
PaviaU_10_SVMLinear_Kappa = cell(1,5);
[data,label] = reshape_data(paviaU,paviaU_gt);
normed_data = normalization_all(data);
parfor iter = 1:5
    [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_SampleSpecial(0.1,normed_data,label,PaviaU_second_mask{iter},amount);
    % training
    [~,PaviaU_10_SVMLinear_penalty{iter}] = svm_train_linear(selTrainData,selTrainLabel,[-5,5],1);
    % predicting
    [PaviaU_10_SVMLinear_OA{iter},PaviaU_10_SVMLinear_AA{iter},PaviaU_10_SVMLinear_OAPerclass{iter},PaviaU_10_SVMLinear_Kappa{iter}] = svm_predict_linear(PaviaU_10_SVMLinear_penalty{iter},selTrainData,selTrainLabel,selTestData,selTestLabel);
end
save PaviaU_10_SVMLinear.mat PaviaU_10_SVMLinear_AA PaviaU_10_SVMLinear_OA PaviaU_10_SVMLinear_penalty PaviaU_10_SVMLinear_OAPerclass PaviaU_10_SVMLinear_Kappa
clear
% 10% results + SVMRBF
% load('F:\zjChen\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\PaviaUniversity\5times_Experiments\PaviaU_first_mask.mat');
% PaviaU_10_SVMRBF_penalty = cell(1,5);
% PaviaU_10_SVMRBF_OA = cell(1,5);
% PaviaU_10_SVMRBF_AA = cell(1,5);
% PaviaU_10_SVMRBF_gamma = cell(1,5);
% [data,label] = reshape_data(paviaU,paviaU_gt);
% normed_data = normalization_all(data);
% for iter = 1:5
%     % [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_ratioSample(1,0.05,normed_data,label,PaviaU_second_mask{iter});
%     [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_SampleSpecial(amount,0.1,normed_data,label,PaviaU_first_mask{iter});
%     % training
%     [~,PaviaU_10_SVMRBF_penalty{iter},PaviaU_10_SVMRBF_gamma{iter}] = svm_train(selTrainData,selTrainLabel,[-5,5],[-5,5],1,1);
%     % predicting
%     [PaviaU_10_SVMRBF_OA{iter},PaviaU_10_SVMRBF_AA{iter}] = svm_predict(PaviaU_10_SVMRBF_penalty{iter},PaviaU_10_SVMRBF_gamma{iter},selTrainData,selTrainLabel,selTestData,selTestLabel);
% end
% save PaviaU_10_SVMRBF.mat PaviaU_10_SVMRBF_AA PaviaU_10_SVMRBF_OA PaviaU_10_SVMRBF_penalty PaviaU_10_SVMRBF_gamma
% clear 


% salinas dataset
load('D:\Workspace\HSI\trunk\datasets\Salinas\Salinas_corrected.mat');
load('D:\Workspace\HSI\trunk\datasets\Salinas\Salinas_gt.mat');
% 30 samples per class results + SVMLinear
load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\Salinas\5times_Experiments\salinas_firstmask.mat');
Salinas_30Sam_SVMLinear_penalty = cell(1,5);
Salinas_30Sam_SVMLinear_OA = cell(1,5);
Salinas_30Sam_SVMLinear_OAPerclass = cell(1,5);
Salinas_30Sam_SVMLinear_AA = cell(1,5);
Salinas_30Sam_SVMLinear_Kappa = cell(1,5);
[data,label] = reshape_data(salinas_corrected,salinas_gt);
normed_data = normalization_all(data);
parfor iter = 1:5
    [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_fixedSample(30,normed_data,label,salinas_firstmask{iter});
    % training
    [~,Salinas_30Sam_SVMLinear_penalty{iter}] = svm_train_linear(selTrainData,selTrainLabel,[-5,5],1);
    % predicting
    [Salinas_30Sam_SVMLinear_OA{iter},Salinas_30Sam_SVMLinear_AA{iter},Salinas_30Sam_SVMLinear_OAPerclass{iter},Salinas_30Sam_SVMLinear_Kappa{iter}] = svm_predict_linear(Salinas_30Sam_SVMLinear_penalty{iter},selTrainData,selTrainLabel,selTestData,selTestLabel);
end
save Salinas_30Sam_SVMLinear.mat Salinas_30Sam_SVMLinear_AA Salinas_30Sam_SVMLinear_OA Salinas_30Sam_SVMLinear_penalty Salinas_30Sam_SVMLinear_OAPerclass Salinas_30Sam_SVMLinear_Kappa
clear Salinas_30Sam_SVMLinear_AA Salinas_30Sam_SVMLinear_OA Salinas_30Sam_SVMLinear_penalty salinas_firstmask Salinas_30Sam_SVMLinear_OAPerclass Salinas_30Sam_SVMLinear_Kappa
% Average 68 samples per class results + SVMLinear
load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\Salinas\5times_Experiments\salinas_secondmask.mat');
load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\Salinas\5times_Experiments\amount.mat');
Salinas_68Sam_SVMLinear_penalty = cell(1,5);
Salinas_68Sam_SVMLinear_OA = cell(1,5);
Salinas_68Sam_SVMLinear_AA = cell(1,5);
Salinas_68Sam_SVMLinear_OAPerclass = cell(1,5);
Salinas_68Sam_SVMLinear_Kappa = cell(1,5);
[data,label] = reshape_data(salinas_corrected,salinas_gt);
normed_data = normalization_all(data);
parfor iter = 1:5
    [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_SampleSpecial(amount,normed_data,label,salinas_secondmask{iter});
    % training
    [~,Salinas_68Sam_SVMLinear_penalty{iter}] = svm_train_linear(selTrainData,selTrainLabel,[-5,5],1);
    % predicting
    [Salinas_68Sam_SVMLinear_OA{iter},Salinas_68Sam_SVMLinear_AA{iter},Salinas_68Sam_SVMLinear_OAPerclass{iter},Salinas_68Sam_SVMLinear_Kappa{iter}] = svm_predict_linear(Salinas_68Sam_SVMLinear_penalty{iter},selTrainData,selTrainLabel,selTestData,selTestLabel);
end
save Salinas_68Sam_SVMLinear.mat Salinas_68Sam_SVMLinear_AA Salinas_68Sam_SVMLinear_OA Salinas_68Sam_SVMLinear_penalty Salinas_68Sam_SVMLinear_OAPerclass Salinas_68Sam_SVMLinear_Kappa
clear
toc;

 