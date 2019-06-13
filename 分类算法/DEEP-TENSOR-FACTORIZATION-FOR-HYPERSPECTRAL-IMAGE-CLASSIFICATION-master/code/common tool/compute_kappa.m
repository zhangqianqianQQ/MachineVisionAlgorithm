function kp=compute_kappa(true_label,result_label)
if(length(true_label)~=length(result_label))
    error('两个label数组长度不等。');
elseif(size(true_label,1)~=size(result_label,1))
    result_label=result_label';
end
true_label=double(true_label);
result_label=double(result_label);

class_labels=unique(true_label);
class_num=length(class_labels);
N=length(true_label);

confusion_matrix=zeros(class_num,class_num);

for i=1:class_num
    for j=1:class_num 
        confusion_matrix(i,j)=sum((true_label==class_labels(j))&(result_label==class_labels(i)));
    end
end
col_sum=sum(confusion_matrix,1);
row_sum=sum(confusion_matrix,2);

temp=sum(col_sum.*(row_sum'));
kp=(N*sum(diag(confusion_matrix)) - temp)/(N^2-temp);
