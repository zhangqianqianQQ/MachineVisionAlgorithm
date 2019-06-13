function [pred_label,pred_prob]=MLREval(data,num_class, w)
% Eval a MLR model for given data
% Input: data-N*D matrix, N is the number of data samples, D is the data dimension
%             num_class: number of class
%             w: model weight vector, which should be a D*num_class matrix
%Output: pred_label-the predicted class label with the maximum probablity
%               pred_prob-the predicted class probablities for each sample
% 2016-10-15 by jlfeng              
[~, num_dim]=size(data);
if size(w,1)~=num_dim  || size(w,2)~=num_class
    disp('The dimension of the model parameter is incompatible with the input data!');
    return;
end
prod_tmp=data*w;
exp_tmp=exp(prod_tmp);
pred_prob=exp_tmp./repmat(sum(exp_tmp,2),[1 num_class]);
[~,pred_label]=max(pred_prob,[],2);
