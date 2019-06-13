%Demo of HSI data loading and classification
clear;close all;clc
addpath(genpath(pwd))
%% 
disp('Loading data.');
dataInfo=HsiDataLoad('PaviaUniv');
dataInfo.splitInfo=SplitData(dataInfo.gt_data,'fix_num',100,true);

train_feat=VectorIndexing3D(dataInfo.spectral_data,dataInfo.splitInfo.train_idx);
test_feat=VectorIndexing3D(dataInfo.spectral_data,dataInfo.splitInfo.test_idx);
train_feat=train_feat/1000;
test_feat=test_feat/1000;
train_label=dataInfo.splitInfo.train_label;
test_label=dataInfo.splitInfo.test_label;
%%
disp('Perform dimensional reduction.');
% [train_feat,pca_eigvec,pca_eigval]=MyPCA(train_feat,1,32);
% test_feat=MyPCA(test_feat,2,pca_eigvec);

% lda_model=MyLDA(train_feat,1,train_label);
% [lda_label_train,train_feat]=MyLDA(train_feat,2,lda_model);
% [lda_label_test,test_feat]=MyLDA(test_feat,2,lda_model);

sigma_rbf=3;
[train_feat_proj,pca_eigvec,pca_eigval]=KernelPCA(train_feat,1,72,train_feat,'rbf',sigma_rbf);
test_feat_proj=KernelPCA(test_feat,2,pca_eigvec,train_feat,'rbf',sigma_rbf);
train_feat=train_feat_proj;
test_feat=test_feat_proj;
clear train_feat_proj test_feat_proj;

%%
disp('Perform classification.');
[w,val_loss] = MLRTrainAL(train_feat',train_label', 0.1,0.0001,100);
[pred_label,pred_prob]=MLREval(test_feat,dataInfo.num_class, w);

% sigma_rbf=1;
% train_grammat=GetKernelMat(train_feat,train_feat,'rbf',sigma_rbf);
% train_grammat=[(1:size(train_grammat,1))',train_grammat];
% svmoptions='-s 0 -t 4 -c 50 -b 1 -q';
% svm_model=svmtrain(train_label,train_grammat,svmoptions);
% 
% test_grammat=GetKernelMat(train_feat,test_feat,'rbf',sigma_rbf);
% test_grammat=[(1:size(test_grammat,1))',test_grammat];
% [pred_label,accuracy,pred_prob] =svmpredict(test_label,test_grammat,svm_model,'-b 1');

%%
[clsStat,mat_conf]=GetAccuracy(test_label,pred_label);
disp(['Overall Accuracy:',num2str(clsStat.OA),', Kappa Coeffcient:', num2str(clsStat.Kappa)]);
color_map=GetColorMap(16);
mat_pred_label=zeros(size(dataInfo.gt_data));
mat_pred_label(dataInfo.splitInfo.test_idx)=pred_label;
class_map=GetClassMap(mat_pred_label,color_map);
class_map_gt=GetClassMap(dataInfo.gt_data,color_map);
figure(1);set(gcf,'position',[300 200 900 600])
subplot(1,2,1);imagesc(class_map_gt);
subplot(1,2,2);imagesc(class_map);
