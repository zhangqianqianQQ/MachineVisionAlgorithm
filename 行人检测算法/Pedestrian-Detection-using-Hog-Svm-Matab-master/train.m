addpath('./params/');
addpath('./libs/');
addpath('./libsvm-master/matlab');
model_name='SVM_model';
path={'./','./images/pos/','./images/neg/'};
model=train_svm(model_name,path);