function pred_class=SRClassifier(train_data,train_label,test_data,param)
% Sparse representation based classifier
% Input: 
%    train_data- the training data, each coloum is a sample
%    train_label- the label of training data
%    test_data- test data, each coloum is a sample
%    param- struct
%            param.L (optional, maximum number of elements in each decomposition, 
%               min(m,p) by default)
%            param.eps (optional, threshold on the squared l2-norm of the residual,
%               0 by default
%            param.lambda (optional, penalty parameter, 0 by default
%            param.numThreads (optional, number of threads for exploiting
%            multi-core / multi-cpus. By default, it takes the value -1,
%            which automatically selects all the available CPUs/cores).
%2016-10-20, jlfeng
if param.mode==0
    sr_coef=mexOMP(test_data,train_data,param);
elseif Param.mode==1
    sr_coef=mexLasso(test_data,train_data,param);
else
    error('Only L0 or L1 regularization can be used!')    
end
sr_coef=full(sr_coef);
label_list=unique(train_label);
num_label=length(label_list);
num_test=size(test_data,2);
err_approx=zeros(num_test,num_label);
for kk=1:num_label
    idx=train_label==label_list(kk);
    test_data_recover=train_data(:,idx)*sr_coef(idx,:);
    err_approx(:,kk)=sum((test_data-test_data_recover).^2,1)';
end
[~,idx_min]=min(err_approx,[],2);
pred_class=label_list(idx_min);


