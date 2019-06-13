function [OAofpredict,AAofpredict,OAperclass,kappa] = svm_predict(penalty,gamma,traindata,trainlabel,testdata,testlabel)
% stage1:
% With the prior best pair of parameters(penalty,gamma), using all train 
% samples to train the model
% stage2:
% Taking previous model to test on the remaining test samples

% svmtrain/svmpredict:
%       data:row represents # of samples, column represents # of features
%       label:column vector

cmd = ['-t 2 -c ',sprintf('%.16f',penalty),' -g ',sprintf('%.16f',gamma)];

model = svmtrain(trainlabel,traindata,cmd);
[predictlabel,OAofpredict,~] = svmpredict(testlabel,testdata,model);  
OAofpredict = OAofpredict(1);
sum_eachclass = 0;
classes = unique(testlabel);
OAperclass = zeros(size(classes,1),1);
for iter=1:size(classes,1)
    labeloftest = testlabel == classes(iter);
    labelofpredict = predictlabel == classes(iter);
    compare = (labeloftest+labelofpredict) == 2;
    OAperclass(iter) = sum(compare)/sum(labeloftest);
    sum_eachclass = sum_eachclass + sum(compare)/sum(labeloftest);
end
AAofpredict = sum_eachclass / size(classes,1);
kappa = compute_kappa(testlabel,predictlabel);