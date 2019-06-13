function [normed_traindata,normed_testdata ] = normalization(traindata,testdata)
% Calculating mean and standard deviation of train samples on each band
% Using calculated mean and standard deviation to perform normalization on
% both train samples and test samples

mean_val=mean(traindata,1);
sigma_val=std(traindata,0,1);
    
traindata=bsxfun(@minus,traindata,mean_val);
normed_traindata=bsxfun(@rdivide,traindata,sigma_val);
    
testdata=bsxfun(@minus,testdata,mean_val);
normed_testdata=bsxfun(@rdivide,testdata,sigma_val);

%selTrainData=bsxfun(@rdivide,selTrainData,sum(selTrainData,2));
%selTestData=bsxfun(@rdivide,selTestData,sum(selTestData,2)); 

% mean_val = mean(traindata,1);
% normed_traindata = bsxfun(@minus,traindata,mean_val);
% 
% sigma_val = std(normed_traindata,0,1);
% normed_traindata = bsxfun(@rdivide,normed_traindata,sigma_val);
% normed_testdata = bsxfun(@minus,testdata,mean_val);
% normed_testdata = bsxfun(@rdivide,normed_testdata,sigma_val);
 
