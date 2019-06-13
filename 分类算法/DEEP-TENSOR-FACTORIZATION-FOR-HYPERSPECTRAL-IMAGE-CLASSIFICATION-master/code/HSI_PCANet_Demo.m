load('D:\Workspace\HSI\trunk\datasets\pavia university\PaviaU.mat');
load('D:\Workspace\HSI\trunk\datasets\pavia university\PaviaU_gt.mat');
paviaU_gt = double(paviaU_gt);
load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\PaviaUniversity\5times_Experiments\PaviaU_first_mask.mat');
load('D:\Workspace\HSI\trunk\Experiments\Deep-Tensor\Experiment Results\固定训练样本实验\PaviaUniversity\5times_Experiments\amount.mat');

PCANet.NumStages = 2;
PCANet.PatchSize = [3 3];
PCANet.NumFilters = [3 3];
ImgFormat = 'gray';
ImgSize = [610 340];
TrnData_ImgCell = cell(103,1);
for i=1:103
    TrnData_ImgCell{i,1} = paviaU(:,:,i);
end
[f,V] = PCANet_train(TrnData_ImgCell,PCANet,1);
combined_cell = cell(size(f,1),1);
for i=1:size(f,1)
    combined_cell{i} = Concatenation(f{i});
end
combined_datacube = Concatenation(combined_cell);
Penalty = zeros(5,1);
Kappa = zeros(5,1);
OAPredict = zeros(5,1);
AAPredict = zeros(5,1);
OAOfTrain = cell(5,1);
OAPerclass = cell(5,1);
[data,label] = reshape_data(combined_datacube,paviaU_gt);
normed_data = normalization_all(data);
for iter=1:5
    [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_SampleSpecial(0.01,normed_data,label,PaviaU_first_mask{iter},amount);
    [OAOfTrain{iter},Penalty(iter)] = svm_train_linear(selTrainData,selTrainLabel,[-5,5],1);
    [OAPredict(iter),AAPredict(iter),OAPerclass{iter},Kappa(iter)] = svm_predict_linear(Penalty(iter),selTrainData,selTrainLabel,selTestData,selTestLabel);
end