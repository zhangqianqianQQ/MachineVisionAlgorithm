function mat_gram = GetKernelMat(data1,data2,kernel_type,kernel_param)
% Ccomputes the Gram matrix of a specified kernel function.
%Input: data1, data2-Input data matix      
%            kernel_type: 'linear' | 'poly' | 'rbf'|'intersect'|'sigmoid'
% 2016-10-16 by jlfeng

n1=size(data1,1);
n2=size(data2,1);

switch kernel_type
    case 'linear'
        mat_gram=data2*data1';
    case 'poly'
        mat_gram=(data2*data1'+1).^kernel_param;       
    case 'polyhomog'
        mat_gram=(data2*data1').^kernel_param;
    case 'rbf'
        mat_gram = exp(-(repmat(sum(data1.*data1,2)',n2,1) + ...
                repmat(sum(data2.*data2,2),1,n1) - 2*data2*data1') ...
                /(2*kernel_param^2));       
    case 'intersect'
        mat_gram=zeros(n2,n1);
        for kk=1:n1
            temp=min(data2,repmat(data1(kk,:),[n2 1]));
            mat_gram(:,kk)=sum(temp,2);
        end
    case 'sigmod'
        mat_gram=tanh(data2*data1'*kernel_param(1)+kernel_param(2));
    otherwise
        error('Unknown kernel function.');
end

