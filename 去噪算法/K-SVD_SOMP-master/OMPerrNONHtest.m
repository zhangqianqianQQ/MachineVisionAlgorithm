function [A]=OMPerrNONHtest(D,X,BETA,errorGoal)
%=============================================

P=size(X,2);
K=size(D,2);
A=sparse(K,P); 

%对P列数据的每一列进行OMP计算，得到其对应的系数
for i=1:P
   
    x=X(:,i);
    beta=BETA(:,i);
    
    %1 得到点乘beta的该列数据
    x_beta=beta.*x;
    
    %2 得到点乘beta的字典
    D_beta=zeros(size(D));
    for j=1:K
        D_beta(:,j)=D(:,j).*beta;
    end
    %3 对该列数据和字典进行一次OMP 得到该列数据对应字典的系数
    [a,indx]=omp_single(D_beta,x_beta,errorGoal);
    
    %4 将表示该列数据的系数放入系数矩阵 
    if (~isempty(indx))
           A(indx,i)=a;
    end
end
end
