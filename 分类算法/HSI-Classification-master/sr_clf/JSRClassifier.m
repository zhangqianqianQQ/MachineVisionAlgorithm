function err_approx_group=JSRClassifier(train_data,train_label,test_data,list_groups,param)
% Joint Sparse Representation based classifier
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
    sr_coef=mexSOMP(test_data,train_data,list_groups,param);
elseif param.mode==1
    sr_coef0=zeros(size(train_data,2),size(test_data,2));
    sr_coef=mexL1L2BCD(test_data,train_data,sr_coef0,list_groups,param);
end
label_list=unique(train_label);
num_label=length(label_list);
num_group=length(list_groups);
pred_class_group=zeros(num_group,1);
pred_class=zeros(size(test_data,2),1);
for ll=1:num_group
    if ll<num_group
        idx_group=list_groups(ll)+1:list_groups(ll+1);
    else
        idx_group=list_groups(ll)+1:size(test_data,2);
    end
    test_data_group=test_data(:,idx_group);
    sr_coef_group= sr_coef(:,idx_group);
    err_approx_group=zeros(1,num_label);
    for kk=1:num_label
        idx_label=train_label==label_list(kk);
        test_data_rec=train_data(:,idx_label)*sr_coef_group(idx_label,:);
        err_approx_temp=(test_data_group-test_data_rec).^2;
        err_approx_group(kk)=sum(err_approx_temp(:));
    end
    [~,pred_class_group(ll)]=min(err_approx_group,[],2);
    pred_class(idx_group)=label_list(pred_class_group(ll));
end
