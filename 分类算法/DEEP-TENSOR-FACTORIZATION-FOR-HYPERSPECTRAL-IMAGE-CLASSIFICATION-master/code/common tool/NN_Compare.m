% Script for 1-NN
% Caculate Automatically

tic;
% IndianPines_nonnoise dataset
load('D:\Workspace\HSI\trunk\Experiments\data\92AV3C\non-noise\DataCube.mat');
load('D:\Workspace\HSI\trunk\Experiments\data\92AV3C\non-noise\Label0.mat');
load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\IndianPines_nonnoise\5times_Experiments\IndianPines_first_mask.mat');
% 5% results
IndianPines_5_1NN_OA = cell(1,5);
IndianPines_5_1NN_OAPerclass = cell(1,5);
IndianPines_5_1NN_AA = cell(1,5);
IndianPines_5_1NN_Kappa = cell(1,5);
[data,label] = reshape_data(finalsub,Label0);
parfor iter = 1:5
    [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_ratioSample(1,0.05,data,label,IndianPines_first_mask{iter});
    [IndianPines_5_1NN_OA{iter},IndianPines_5_1NN_AA{iter},IndianPines_5_1NN_OAPerclass{iter},IndianPines_5_1NN_Kappa{iter}] = k_nn(selTrainData,selTrainLabel,selTestData,selTestLabel,1);
end
save IndianPines_5_1NN.mat IndianPines_5_1NN_AA IndianPines_5_1NN_OA IndianPines_5_1NN_OAPerclass IndianPines_5_1NN_Kappa
clear IndianPines_5_1NN_AA IndianPines_5_1NN_OA IndianPines_first_mask IndianPines_5_1NN_OAPerclass IndianPines_5_1NN_Kappa

% 10% results
load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\IndianPines_nonnoise\5times_Experiments\IndianPines_second_mask.mat');

IndianPines_10_1NN_OA = cell(1,5);
IndianPines_10_1NN_OAPerclass = cell(1,5);
IndianPines_10_1NN_AA = cell(1,5);
IndianPines_10_1NN_Kappa = cell(1,5);
[data,label] = reshape_data(finalsub,Label0);
parfor iter = 1:5
    [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_ratioSample(1,0.1,data,label,IndianPines_second_mask{iter});
    [IndianPines_10_1NN_OA{iter},IndianPines_10_1NN_AA{iter},IndianPines_10_1NN_OAPerclass{iter},IndianPines_10_1NN_Kappa{iter}] = k_nn(selTrainData,selTrainLabel,selTestData,selTestLabel,1);
end
save IndianPines_10_1NN.mat IndianPines_10_1NN_AA IndianPines_10_1NN_OA IndianPines_10_1NN_OAPerclass IndianPines_10_1NN_Kappa
clear


% Botswana Dataset
load('D:\Workspace\HSI\trunk\datasets\Botswana\Botswana.mat');
load('D:\Workspace\HSI\trunk\datasets\Botswana\Botswana_gt.mat');
load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\Botswana\5times_Experiments\Botswana_first_mask.mat');

% 10% results
Botswana_10_1NN_OA = cell(1,5);
Botswana_10_1NN_OAPerclass = cell(1,5);
Botswana_10_1NN_AA = cell(1,5);
Botswana_10_1NN_Kappa = cell(1,5);
[data,label] = reshape_data(Botswana,Botswana_gt);
parfor iter = 1:5
    [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_ratioSample(1,0.1,data,label,Botswana_first_mask{iter});
    [Botswana_10_1NN_OA{iter},Botswana_10_1NN_AA{iter},Botswana_10_1NN_OAPerclass{iter},Botswana_10_1NN_Kappa{iter}] = k_nn(selTrainData,selTrainLabel,selTestData,selTestLabel,1);
end
save Botswana_10_1NN.mat Botswana_10_1NN_AA Botswana_10_1NN_OA Botswana_10_1NN_OAPerclass Botswana_10_1NN_Kappa
clear Botswana_10_1NN_AA Botswana_10_1NN_OA Botswana_first_mask Botswana_10_1NN_OAPerclass Botswana_10_1NN_Kappa

% 5% results 
load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\Botswana\5times_Experiments\Botswana_second_mask.mat');
Botswana_5_1NN_OA = cell(1,5);
Botswana_5_1NN_OAPerclass = cell(1,5);
Botswana_5_1NN_AA = cell(1,5);
Botswana_5_1NN_Kappa = cell(1,5);
[data,label] = reshape_data(Botswana,Botswana_gt);
parfor iter = 1:5
    [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_ratioSample(1,0.05,data,label,Botswana_second_mask{iter});
    [Botswana_5_1NN_OA{iter},Botswana_5_1NN_AA{iter},Botswana_5_1NN_OAPerclass{iter},Botswana_5_1NN_Kappa{iter}] = k_nn(selTrainData,selTrainLabel,selTestData,selTestLabel,1);
end
save Botswana_5_1NN.mat Botswana_5_1NN_AA Botswana_5_1NN_OA Botswana_5_1NN_OAPerclass Botswana_5_1NN_Kappa
clear



% Pavia University 
load('D:\Workspace\HSI\trunk\datasets\pavia university\PaviaU.mat');
load('D:\Workspace\HSI\trunk\datasets\pavia university\PaviaU_gt.mat');
load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\PaviaUniversity\5times_Experiments\amount.mat');
% 1% results
load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\PaviaUniversity\5times_Experiments\PaviaU_first_mask.mat');
PaviaU_1_1NN_OA = cell(1,5);
PaviaU_1_1NN_OAPerclass = cell(1,5);
PaviaU_1_1NN_AA = cell(1,5);
PaviaU_1_1NN_Kappa = cell(1,5);
[data,label] = reshape_data(paviaU,paviaU_gt);
parfor iter = 1:5
    [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_SampleSpecial(0.01,data,label,PaviaU_first_mask{iter},amount);
    [PaviaU_1_1NN_OA{iter},PaviaU_1_1NN_AA{iter},PaviaU_1_1NN_OAPerclass{iter},PaviaU_1_1NN_Kappa{iter}] = k_nn(selTrainData,selTrainLabel,selTestData,selTestLabel,1);
end
save PaviaU_1_1NN.mat PaviaU_1_1NN_AA PaviaU_1_1NN_OA PaviaU_1_1NN_OAPerclass PaviaU_1_1NN_Kappa
clear PaviaU_1_1NN_AA PaviaU_1_1NN_OA PaviaU_1_1NN_OAPerclass PaviaU_1_1NN_Kappa PaviaU_first_mask
% 10% results
load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\PaviaUniversity\5times_Experiments\PaviaU_second_mask.mat');
PaviaU_10_1NN_OA = cell(1,5);
PaviaU_10_1NN_OAPerclass = cell(1,5);
PaviaU_10_1NN_AA = cell(1,5);
PaviaU_10_1NN_Kappa = cell(1,5);
[data,label] = reshape_data(paviaU,paviaU_gt);
parfor iter = 1:5
    [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_SampleSpecial(0.1,data,label,PaviaU_second_mask{iter},amount);
    [PaviaU_10_1NN_OA{iter},PaviaU_10_1NN_AA{iter},PaviaU_10_1NN_OAPerclass{iter},PaviaU_10_1NN_Kappa{iter}] = k_nn(selTrainData,selTrainLabel,selTestData,selTestLabel,1);
end
save PaviaU_10_1NN.mat PaviaU_10_1NN_AA PaviaU_10_1NN_OA PaviaU_10_1NN_OAPerclass PaviaU_10_1NN_Kappa
clear

% salinas dataset
load('D:\Workspace\HSI\trunk\datasets\Salinas\Salinas_corrected.mat');
load('D:\Workspace\HSI\trunk\datasets\Salinas\Salinas_gt.mat');
% 30 samples per class results
load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\Salinas\5times_Experiments\salinas_firstmask.mat');
Salinas_30Sam_1NN_OA = cell(1,5);
Salinas_30Sam_1NN_OAPerclass = cell(1,5);
Salinas_30Sam_1NN_AA = cell(1,5);
Salinas_30Sam_1NN_Kappa = cell(1,5);
[data,label] = reshape_data(salinas_corrected,salinas_gt);
parfor iter = 1:5
    [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_fixedSample(30,data,label,salinas_firstmask{iter});
    [Salinas_30Sam_1NN_OA{iter},Salinas_30Sam_1NN_AA{iter},Salinas_30Sam_1NN_OAPerclass{iter},Salinas_30Sam_1NN_Kappa{iter}] = k_nn(selTrainData,selTrainLabel,selTestData,selTestLabel,1);
end
save Salinas_30Sam_1NN.mat Salinas_30Sam_1NN_AA Salinas_30Sam_1NN_OA Salinas_30Sam_1NN_OAPerclass Salinas_30Sam_1NN_Kappa
clear Salinas_30Sam_1NN_AA Salinas_30Sam_1NN_OA salinas_firstmask Salinas_30Sam_1NN_OAPerclass Salinas_30Sam_1NN_Kappa
% Average 68 samples per class results
load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\Salinas\5times_Experiments\salinas_secondmask.mat');
load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\Salinas\5times_Experiments\amount.mat');
Salinas_68Sam_1NN_OA = cell(1,5);
Salinas_68Sam_1NN_AA = cell(1,5);
Salinas_68Sam_1NN_OAPerclass = cell(1,5);
Salinas_68Sam_1NN_Kappa = cell(1,5);
[data,label] = reshape_data(salinas_corrected,salinas_gt);
parfor iter = 1:5
    [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_SampleSpecial(amount,data,label,salinas_secondmask{iter});
    [Salinas_68Sam_1NN_OA{iter},Salinas_68Sam_1NN_AA{iter},Salinas_68Sam_1NN_OAPerclass{iter},Salinas_68Sam_1NN_Kappa{iter}] = k_nn(selTrainData,selTrainLabel,selTestData,selTestLabel,1);
end
save Salinas_68Sam_1NN.mat Salinas_68Sam_1NN_AA Salinas_68Sam_1NN_OA Salinas_68Sam_1NN_OAPerclass Salinas_68Sam_1NN_Kappa
clear

% KSC dataset
load('D:\Workspace\HSI\trunk\datasets\KSC\KSC.mat');
load('D:\Workspace\HSI\trunk\datasets\KSC\KSC_gt.mat');
% 5% results
load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\KSC\5times_Experiments\KSC_second_mask.mat');
KSC_5_1NN_OA = cell(1,5);
KSC_5_1NN_OAPerclass = cell(1,5);
KSC_5_1NN_AA = cell(1,5);
KSC_5_1NN_Kappa = cell(1,5);
[data,label] = reshape_data(KSC,KSC_gt);
parfor iter = 1:5
    [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_ratioSample(1,0.05,data,label,KSC_second_mask{iter});
    [KSC_5_1NN_OA{iter},KSC_5_1NN_AA{iter},KSC_5_1NN_OAPerclass{iter},KSC_5_1NN_Kappa{iter}] = k_nn(selTrainData,selTrainLabel,selTestData,selTestLabel,1);
end
save KSC_5_1NN.mat KSC_5_1NN_AA KSC_5_1NN_OA KSC_5_1NN_OAPerclass KSC_5_1NN_Kappa
clear KSC_5_1NN_AA KSC_5_1NN_OA KSC_second_mask KSC_5_1NN_OAPerclass KSC_5_1NN_Kappa

% 10% results
load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\KSC\5times_Experiments\KSC_first_mask.mat');
KSC_10_1NN_OA = cell(1,5);
KSC_10_1NN_OAPerclass = cell(1,5);
KSC_10_1NN_AA = cell(1,5);
KSC_10_1NN_Kappa = cell(1,5);
[data,label] = reshape_data(KSC,KSC_gt);
parfor iter = 1:5
    [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_ratioSample(1,0.1,data,label,KSC_first_mask{iter});
    [KSC_10_1NN_OA{iter},KSC_10_1NN_AA{iter},KSC_10_1NN_OAPerclass{iter},KSC_10_1NN_Kappa{iter}] = k_nn(selTrainData,selTrainLabel,selTestData,selTestLabel,1);
end
save KSC_10_1NN.mat KSC_10_1NN_AA KSC_10_1NN_OA KSC_10_1NN_OAPerclass KSC_10_1NN_Kappa
clear
toc;

 