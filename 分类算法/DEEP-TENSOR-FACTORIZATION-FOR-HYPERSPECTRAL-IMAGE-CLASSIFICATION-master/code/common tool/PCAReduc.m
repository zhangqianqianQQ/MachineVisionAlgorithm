function [coef,score,latent,penalty,OAPredict,AAPredict,OAPerclass,Kappa] = PCAReduc(datacube,label0,ratio,mask,trainmode,amount)
% 在datacube图像立方体上，以及对应标签label0上，以mask作为固定排列，选取前ratio比例的数据作为训练集
% SVM Linear & RBF
hidden_featrue = [1 2 4 5 8 10 13 17 29 44];
[data,label] = reshape_data(datacube,label0);
% PCA for whole image
[coef,score,latent] = pca(data);

penalty = cell(1,10);
% gamma = cell(1,10);
OAPredict = cell(1,10);
OAPerclass = cell(1,10);
AAPredict = cell(1,10);
Kappa = cell(1,10);

for iter=1:10
    reduc_data = bsxfun(@minus,data,mean(data,1)) * coef(:,1:hidden_featrue(iter));
%     recon_data = reduc_data * coef(:,1:hidden_featrue(iter))';
%     recon_data = bsxfun(@plus,recon_data,mean(data,1));
%     normed_data = normalization_all(recon_data);
    normed_data = normalization_all(reduc_data);
    % 5次随机实验结果
    penalty{iter} = cell(1,5);
    % gamma{iter} = cell(1,5);
    OAPredict{iter} = cell(1,5);
    AAPredict{iter} = cell(1,5);
    OAPerclass{iter} = cell(1,5);
    Kappa{iter} = cell(1,5);
    for times = 1:5
        if trainmode == 1
            % generate sample by ratio
            [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_ratioSample(1,ratio,normed_data,label,mask{times});
            % [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_ratioSample(1,ratio,reduc_data,label,mask{times});
        elseif trainmode == 2
            % generate sample by fixed samples
            % [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_fixedSample(ratio,normed_data,label,mask{times});
            [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_fixedSample(ratio,reduc_data,label,mask{times});
        else
            % generate sample by special settings
            if nargin == 5
                % Special Setting for Salinas
                % [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_SampleSpecial(ratio,normed_data,label,mask{times}); 
                [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_SampleSpecial(ratio,reduc_data,label,mask{times});
            elseif nargin == 6
                % Spcial Setting for PaviaU
                % [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_SampleSpecial(ratio,normed_data,label,mask{times},amount);
                [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_SampleSpecial(ratio,reduc_data,label,mask{times},amount);
            end
        end
        [~,penalty{iter}{times}] = svm_train_linear(selTrainData,selTrainLabel,[-5,5],1);
        % [~,penalty{iter}{times},gamma{iter}{times}] = svm_train(selTrainData,selTrainLabel,[-5,5],[-5,5],1,1);
        [OAPredict{iter}{times},AAPredict{iter}{times},OAPerclass{iter}{times},Kappa{iter}{times}] = svm_predict_linear(penalty{iter}{times},selTrainData,selTrainLabel,selTestData,selTestLabel);
        % [OAPredict{iter}{times},AAPredict{iter}{times},OAPerclass{iter}{times},Kappa{iter}{times}] = svm_predict(penalty{iter}{times},gamma{iter}{times},selTrainData,selTrainLabel,selTestData,selTestLabel);
        % [OAPredict{iter}{times},AAPredict{iter}{times},OAPerclass{iter}{times},Kappa{iter}{times}] = k_nn(selTrainData,selTrainLabel,selTestData,selTestLabel,1);
    end
end