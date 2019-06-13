function [OAofPredict,AAofPredict,OAperclass,kappa] = k_nn(traindata,trainlabel,testdata,testlabel,k)
% Using k-nearest neighbor classifier to do classification, default is 1.
% Each row represents a sample, each column represents a feature
mdl = fitcknn(traindata,trainlabel,'NumNeighbors',k);
predictlabel = predict(mdl,testdata);

OAofPredict = sum(predictlabel == testlabel) / numel(testlabel);

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
AAofPredict = sum_eachclass / size(classes,1);
kappa = compute_kappa(testlabel,predictlabel);
