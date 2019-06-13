function [eigen_normalized,normalized_eigen_matrix, data_dimention]=normalize_eigenvalues(data,D)

dim=D;

eigen_normalized=data;
[Lamdas_gap2,data_dimention]=estimate_token(eigen_normalized,dim);
N=size(data,2);
s=zeros(1,N);
normalized_eigen_matrix=zeros(dim,size(data,2));

for i=1:dim
    %normalized_eigen_matrix(i,:)=(Lamdas_gap2(i,:)); 
    normalized_eigen_matrix(i,:)=(data(dim+1+i,:)); 

end
%normalized_eigen_matrix(1,:)=(Lamdas_gap2(1,:))+(Lamdas_gap2(2,:)); 


for i=1:N
    s(i)=sqrt(sum(normalized_eigen_matrix(:,i)));
end
for i=1:N
    normalized_eigen_matrix(:,i)=normalized_eigen_matrix(:,i)./s(i);
end
for i=1:N  
    eigen_normalized(dim+2:(2*dim)+1,i)=normalized_eigen_matrix(:,i);
end
end   

    




% dim=D;
% 
% if dim==2
% eigen_normalized=data;
% [Lamdas_gap2]=estimate_token(eigen_normalized,dim);
% %l12=(Lamdas_gap2(1,:)); 
% l1=(data(dim+2,:));
% l2=(data(dim+3,:));
% %l1 = l12 + l2;
% %s = sqrt(sum([l1', l2'].^2,2))';
% s = sqrt((l1+l2).^2);
% l2 = l2 ./ s;
% l1=l1./s;
% eigen_normalized(dim+2,:)=l1;
% eigen_normalized(dim+3,:)=l2;
% 
% 
% elseif dim==3
% eigen_normalized=data;
% [Lamdas_gap2,data_dimention]=estimate_token(eigen_normalized,dim);
% l12=(Lamdas_gap2(1,:));   
% l2=(Lamdas_gap2(2,:));
% l3=(Lamdas_gap2(3,:));
% l1 = l12 + l2;
% s = sqrt(sum([l1', l2', l3'].^2,2))';
% l3 = l3 ./ s;
% l2 = l2 ./ s;
% l1=l1/s;
% eigen_normalized(dim+2,:)=l1;
% eigen_normalized(dim+3,:)=l2; 
% eigen_normalized(dim+4,:)=l3;    
% elseif dim>3
% eigen_normalized=data;
% [Lamdas_gap2]=estimate_token(eigen_normalized,dim);
% N=size(data,2);
% s=zeros(1,N);
% normalized_eigen_matrix=zeros(dim,size(data,2));
% 
% for i=1:dim
%     %normalized_eigen_matrix(i,:)=(Lamdas_gap2(i,:)); 
%     normalized_eigen_matrix(i,:)=(data(dim+1+i,:)); 
% 
% end
% %normalized_eigen_matrix(1,:)=(Lamdas_gap2(1,:))+(Lamdas_gap2(2,:)); 
% 
% 
% for i=1:N
%     s(i)=sqrt(sum(normalized_eigen_matrix(:,i)));
% end
% for i=1:N
%     normalized_eigen_matrix(:,i)=normalized_eigen_matrix(:,i)./s(i);
% end
% for i=1:N  
%     eigen_normalized(dim+2:(2*dim)+1,i)=normalized_eigen_matrix(:,i);
% end
% end   
% 
%     
