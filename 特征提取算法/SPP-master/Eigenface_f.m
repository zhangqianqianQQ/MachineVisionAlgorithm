function [disc_set,disc_value,Mean_Image]=Eigenface_f(Train_SET,Eigen_NUM)

% the magnitude of eigenvalues of this function is corrected right 
% Centralized PCA
[NN,Train_NUM]=size(Train_SET);

if NN<=Train_NUM % for small sample size case
    
   Mean_Image=mean(Train_SET,2);  
   Train_SET=Train_SET-Mean_Image*ones(1,Train_NUM);
   R=Train_SET*Train_SET'/(Train_NUM-1);
   
   [V,S]=Find_K_Max_Eigen(R,Eigen_NUM);
   disc_value=S;
   disc_set=V;
   
% for small sample size case
else 
    
   Mean_Image=mean(Train_SET,2);  
   Train_SET=Train_SET-Mean_Image*ones(1,Train_NUM);

  R=Train_SET'*Train_SET/(Train_NUM-1);
  
  [V,S]=Find_K_Max_Eigen(R,Eigen_NUM);
  disc_value=S;
  disc_set=zeros(NN,Eigen_NUM);
  
  Train_SET=Train_SET/sqrt(Train_NUM-1);
  for k=1:Eigen_NUM
    disc_set(:,k)=(1/sqrt(disc_value(k)))*Train_SET*V(:,k);
  end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Eigen_Vector,Eigen_Value]=Find_K_Max_Eigen(Matrix,Eigen_NUM)

[NN,NN]=size(Matrix);

%Note this is equivalent to; [V,S]=eig(St,SL); also equivalent to [V,S]=eig(Sn,St); %
[V,S]=eig(Matrix); 

S=diag(S);
[S,index]=sort(S);

Eigen_Vector=zeros(NN,Eigen_NUM);
Eigen_Value=zeros(1,Eigen_NUM);

p=NN;
for t=1:Eigen_NUM
    Eigen_Vector(:,t)=V(:,index(p));
    Eigen_Value(t)=S(p);
    p=p-1;
end
