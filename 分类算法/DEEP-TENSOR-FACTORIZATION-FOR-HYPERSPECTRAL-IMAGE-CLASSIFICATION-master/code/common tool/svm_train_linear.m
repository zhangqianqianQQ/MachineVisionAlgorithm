function [OAoftrain,penalty] = svm_train_linear(traindata,trainlabel,rangeOfpenalty,incrOfpenalty)
% Using the training data and corresponding label to get the best penalty
% with respect to highest accuracy which is the result of 5-fold
% cross-validation(default). 
% Using the grid search to look for the pair of parameters:(penalty)
% penalty lies in the range of rangeOfpenalty in the speed of incrOfpenalty

% svmtrain/svmpredict:
%       data:row represents # of samples, column represents # of features
%       label:column vector
% rangeOfpenalty:2-dims row vector
% incrOfpenalty:scaler on the basis of 2

i = 0;
row = size(rangeOfpenalty(1):incrOfpenalty:rangeOfpenalty(2),2);
OAoftrain = cell(1,row);
OAbest = 0;
penalty = 2^(rangeOfpenalty(1));
for iter_c = rangeOfpenalty(1):incrOfpenalty:rangeOfpenalty(2)
    i = i+1;
    cmd = ['-v 5 -t 0 -c ',sprintf('%.16f',2^(iter_c))];
    OAoftrain{i} = svmtrain(trainlabel,traindata,cmd);
    if OAoftrain{i} > OAbest
        penalty = 2^(iter_c);
        OAbest = OAoftrain{i};
    end
end