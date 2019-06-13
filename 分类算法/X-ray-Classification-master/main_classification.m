% clc;
% clear;
% close all;


training_data = csvread('./10000IRMA_Total_Training_New.csv');
testing_data = csvread('./10000IRMA_Total_Testing_New.csv');

train_ftr = training_data(:,1:112);
test_ftr = testing_data(:,1:112);

train_lbl = training_data(:,113);
test_lbl = testing_data(:,113);


h1 = size(train_ftr,1);
randorder1 = randperm(h1);
h_train = train_ftr(randorder1, :);
trn_lbl = train_lbl(randorder1, :);

h2 = size(test_ftr,1);
randorder2 = randperm(h2);
h_test = test_ftr(randorder2, :);
tst_lbl = test_lbl(randorder2, :);

predict_lbl_train = multisvm(h_train,trn_lbl,h_train);
predict_lbl_tst = multisvm(h_train,trn_lbl,h_test);

% % gamma = 0.0078125
% gamma = 0.0078125
% c = 10
% sigma = 1/(sqrt(2*gamma));
% SVMStruct = svmtrain(h_train,trn_lbl,'kernel_function','rbf','boxconstraint',c,'rbf_sigma',sigma);
% 
% predict_lbl_train = svmclassify(SVMStruct,h_train);
% predict_lbl_tst = svmclassify(SVMStruct,h_test);

accuracy_train = ((6039 -(nnz(abs(predict_lbl_train - trn_lbl))))/6039 ) * 100
accuracy_test = ((2961 - (nnz(abs(predict_lbl_tst - tst_lbl))))/2961 ) * 100
