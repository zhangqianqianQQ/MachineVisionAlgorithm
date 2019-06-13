function [OAoftrain,penalty,gamma] = svm_train(traindata,trainlabel,rangeOfpenalty,rangeOfgamma,incrOfpenalty,incrOfgamma)
% Using the training data and corresponding label to get the best penalty
% and gamma with respect to highest accuracy which is the result of 5-fold
% cross-validation(default). 
% Using the grid search to look for the pair of parameters:(penalty,gamma)
% penalty lies in the range of rangeOfpenalty in the speed of incrOfpenalty
% gamma lies in the range of rangeOfgamma in the speed of incrOfgamma

% svmtrain/svmpredict:
%       data:row represents # of samples, column represents # of features
%       label:column vector
% rangeOfpenalty:2-dims row vector
% rangeOfgamma:2-dims row vector
% incrOfpenalty,incrOfgamma:scaler on the basis of 2

i = 0;
j = 0;
row = size(rangeOfpenalty(1):incrOfpenalty:rangeOfpenalty(2),2);
column = size(rangeOfgamma(1):incrOfgamma:rangeOfgamma(2),2);
OAoftrain = cell(row,column);
OAbest = 0;
penalty = 2^(rangeOfpenalty(1));
gamma = 2^(rangeOfgamma(1));
for iter_c = rangeOfpenalty(1):incrOfpenalty:rangeOfpenalty(2)
    i = i+1;
    for iter_gamma = rangeOfgamma(1):incrOfgamma:rangeOfgamma(2)
        j= j+1;
        cmd = ['-v 5 -t 2 -c ',sprintf('%.16f',2^(iter_c)),' -g ',sprintf('%.16f',2^(iter_gamma))];
        OAoftrain{i,j} = svmtrain(trainlabel,traindata,cmd);
        if OAoftrain{i,j} > OAbest
            penalty = 2^(iter_c);
            gamma = 2^(iter_gamma);
            OAbest = OAoftrain{i,j};
        end
    end
    j = 0;
end