function [A]=read_normals_at_Reversed_votes(i,Ordered_Reversed_V,N,dim,normals)
%default - return only the normal
if normals==1
A=zeros(dim,N);
for j=1:N
   
    A(:,j)=(Ordered_Reversed_V{j}(:,i))';
    
end
elseif normals==2
A=zeros(2*dim,N);
for j=1:N
   
    A(:,j)=(Ordered_Reversed_V{j}(:,i))';
    
end
else
A=zeros(normals*dim,N);
for j=1:N
   
    A(:,j)=(Ordered_Reversed_V{j}(:,i))';
    
end

end