function [train_label,test_label,unlabeled_label,train_index,test_index,unlabeled_index] ...
          = generating_index(dataset,dataset_gt,no_classes)
      
switch dataset
    case 'indian_pines'   
        per_class_num=[5,143,83,24,49,73,3,48,2,98,245,60,21,126,39,10];  % For Indian Pines: 10% sampling.  
    case 'paviau'
        per_class_num=[132,372,42,62,27,101,27,74,19];   % For University of Pacia: 2% sampling.
    case 'salinas'
        per_class_num=[11,19,10,7,14,20,18,57,32,17,6,10,5,6,37,10];   % For Salinas: 0.5% sampling.
end

Train_Label = [];
Train_index = [];
train_data=[];
test_data=[];
train_label=[];
test_label=[];
train_index=[];
test_index=[];
index_len=[];
      
for ii = 1: no_classes

   label_gt=dataset_gt;
   index_ii =  find(label_gt == ii)';  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
   rand_order=randperm(length(index_ii));
   class_ii = ones(1,length(index_ii))* ii;
   Train_Label = [Train_Label class_ii];
   Train_index = [Train_index index_ii]; 
   
   num_train=per_class_num(ii);
 % num_train=floor(length(index_ii)*percent);
   train_ii=rand_order(:,1:num_train);
   train_index=[train_index index_ii(train_ii)];
%   train_index=[train_index index_ii(train_ii)];
   
   test_index_temp=index_ii;
   test_index_temp(:,train_ii)=[];
   test_index=[test_index test_index_temp];
%%   test_index=[test_index test_index_temp];
   
   train_label=[train_label class_ii(:,1:num_train)];
   test_label=[test_label class_ii(num_train+1:end)];
   
end

unlabeled_index =  find(label_gt == 0)';
order=randperm(length(unlabeled_index));
unlabeled_index = unlabeled_index (order);
unlabeled_label=zeros(1,length(unlabeled_index));