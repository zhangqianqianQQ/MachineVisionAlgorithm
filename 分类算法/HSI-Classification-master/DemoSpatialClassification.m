%Demo of HSI data loading and classification
clear;close all;clc
addpath(genpath(pwd))
%% 
disp('Loading data.');
dataInfo=HsiDataLoad('PaviaUniv');
dataInfo.splitInfo=SplitData(dataInfo.gt_data,'fix_num',100,true);

[nr,nc]=size(dataInfo.gt_data);
train_feat=VectorIndexing3D(dataInfo.spectral_data,dataInfo.splitInfo.train_idx);
train_feat=train_feat/1000;
train_label=dataInfo.splitInfo.train_label;

test_feat=VectorIndexing3D(dataInfo.spectral_data,true(nr,nc));
test_feat=test_feat/1000;

%%
disp('Perform dimensional reduction.');
reduce_dim=32;
[train_feat,pca_eigvec,pca_eigval]=MyPCA(train_feat,1,reduce_dim);
test_feat=MyPCA(test_feat,2,pca_eigvec);
pca_feat=reshape(test_feat, [nr nc reduce_dim]);
[sp_label, num_sp] = mexSLIC(pca_feat,4000,20,5);
%% 
disp('Perform classification.');
% [w,val_loss] = MLRTrainAL(train_feat',train_label', 0.1,0.0001,100);
% [pred_label,pred_prob]=MLREval(test_feat,dataInfo.num_class, w);


sigma_rbf=1;
train_grammat=GetKernelMat(train_feat,train_feat,'rbf',sigma_rbf);
train_grammat=[(1:size(train_grammat,1))',train_grammat];
svmoptions='-s 0 -t 4 -c 50 -b 1 -q';
svm_model=svmtrain(train_label,train_grammat,svmoptions);

test_grammat=GetKernelMat(train_feat,test_feat,'rbf',sigma_rbf);
test_grammat=[(1:size(test_grammat,1))',test_grammat];
[pred_label,accuracy,pred_prob] =svmpredict(ones(size(test_grammat,1),1),test_grammat,svm_model,'-b 1');

pred_label_2d=reshape(pred_label,[nr nc]);
pred_label_mv=SpatialMajorityVoting(pred_label_2d, sp_label);
%%
% idx_gt_pixel=dataInfo.gt_data>0;
% temp=zeros(nr,nc);
% temp(idx_gt_pixel)=pred_label_2d(idx_gt_pixel);
% pred_label_2d=temp;
% temp=zeros(nr,nc);
% temp(idx_gt_pixel)=pred_label_mv(idx_gt_pixel);
% pred_label_mv=temp;

[clsStat,mat_conf]=GetAccuracy(dataInfo.splitInfo.test_label,pred_label(dataInfo.splitInfo.test_idx));
disp(['Overall Accuracy:',num2str(clsStat.OA),', Kappa Coeffcient:', num2str(clsStat.Kappa)]);

[clsStat,mat_conf]=GetAccuracy(dataInfo.splitInfo.test_label,pred_label_mv(dataInfo.splitInfo.test_idx));
disp(['Overall Accuracy:',num2str(clsStat.OA),', Kappa Coeffcient:', num2str(clsStat.Kappa)]);

color_map=GetColorMap(16);
class_map_gt=GetClassMap(dataInfo.gt_data,color_map);
class_map=GetClassMap(pred_label_2d,color_map);
class_map_mv=GetClassMap(pred_label_mv,color_map);
figure(1);set(gcf,'position',[100 200 1200 600])
subplot(1,3,1);imagesc(class_map_gt);
subplot(1,3,2);imagesc(class_map);
subplot(1,3,3);imagesc(class_map_mv);


