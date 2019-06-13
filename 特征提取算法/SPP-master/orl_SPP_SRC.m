clc
t0=clock;
Image_row_NUM=112;Image_column_NUM=92; 
NN=Image_row_NUM*Image_column_NUM;

Class_Train_NUM=5;
Class_Sample_NUM=10; % total
Class_Test_NUM=Class_Sample_NUM-Class_Train_NUM;

Class_NUM=40;
Train_NUM=Class_NUM*Class_Train_NUM; % 
Test_NUM=Class_NUM*(Class_Sample_NUM-Class_Train_NUM); % 

Train_DAT=zeros(NN,Train_NUM);
s=1;
for r=1:Class_NUM
   for t=1:Class_Train_NUM
     string=['E:\ORL_face\orlnumtotal\s' int2str(r) '_' int2str(t)];
     A=imread(string,'bmp');
     B=im2double(A);
     Train_DAT(:,s)=B(:);
     s=s+1;
   end
end

Test_DAT=zeros(NN,Test_NUM);
s=1;
for r=1:Class_NUM
   for t=Class_Train_NUM+1:Class_Sample_NUM
     string=['E:\ORL_face\orlnumtotal\s' int2str(r) '_' int2str(t)];
     A=imread(string,'bmp');
     B=im2double(A);
     Test_DAT(:,s)=B(:);
     s=s+1;
   end
end

% to center the each training sample and testing sample
Mean_Image=mean(Train_DAT,2);  
Train_DAT=Train_DAT-Mean_Image*ones(1,Train_NUM);
Test_DAT=Test_DAT-Mean_Image*ones(1,Test_NUM);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% do dimensional reduction, by PCA pre-processing

% Eigen_NUM can be changed! Eigen_NUM must be less than Train_NUM
Eigen_NUM=80;
[PCA_Projection,disc_value]=Eigenface_f(Train_DAT, Eigen_NUM);   

% LLE_DP Transform:
Train_SET=PCA_Projection'*Train_DAT; % size of (Eigen_NUM,Train_NUM); % PCA-based 
Test_SET=PCA_Projection'*Test_DAT;   % size of (Eigen_NUM,Test_NUM); % PCA-based

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Feature extraction using SPP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Step 1, Construct weight matrix S using MSR, Eq(15). That is SPP1
MatrixS=zeros(Train_NUM,Train_NUM);
for k=1:1:Train_NUM
    A=zeros(Eigen_NUM,Train_NUM-1);
    if k==1
       y=Train_SET(:,1);
       A=Train_SET(:,2:Train_NUM);
       x0=inv(A'*A)*A'*y;
       %solve the L1_minimization through y=Ax
       xp=l1eq_pd(x0,A,[],y,1e-3);
       xp=xp/norm(xp,1);
       MatrixS(:,k)=[0 xp'];
    else
       y=Train_SET(:,k);
       A(:,1:k-1)=Train_SET(:,1:k-1);
       A(:,k:Train_NUM-1)=Train_SET(:,k+1:Train_NUM);
       x0=inv(A'*A)*A'*y;
       xp=l1eq_pd(x0,A,[],y,1e-3);
       xp=xp/norm(xp,1);
       %xp1=xp(1:k-1);
       %xp2=xp(k:Train_NUM-1);
       %MatrixS(:,k)=[xp1' 0 xp2'];
       MatrixS(:,k)=[xp(1:k-1)' 0 xp(k:Train_NUM-1)'];
    end
    clear A;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Step 2, using Eq.(22) to calculate the projection W
E=eye(Train_NUM,Train_NUM);
SB=MatrixS+MatrixS'-MatrixS'*MatrixS;

Mat1=Train_SET*SB*Train_SET';
Mat2=Train_SET*Train_SET';

% d is the number of projections, and d must be no larger than Eigen_NUM
d=80;
[W,Gen_Value]=Find_K_Max_Gen_Eigen(Mat1,Mat2,d);
Train=W'*Train_SET;
Test=W'*Test_SET;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%do classification using SRC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
A=Train;
% normalization of test set to have unit L2 norm
for count=1:1:Train_NUM
    A(:,count)=A(:,count)/norm(A(:,count),2);
end

distribute=zeros(Test_NUM,1);
classification=zeros(Test_NUM,1);
miss=0;

for t=1:1:Test_NUM
y=Test(:,t);
x0=inv(A'*A)*A'*y;

%solve the L1_minimization through y=Ax
xp=l1eq_pd(x0,A,[],y,1e-3);
L=norm(xp,1);
test=zeros(Class_NUM,1);
    for k=1:1:Class_NUM
        Rx=zeros(Test_NUM,1);
        Rx(Class_Test_NUM*(k-1)+1:Class_Test_NUM*k)=xp(Class_Test_NUM*(k-1)+1:Class_Test_NUM*k);
        res=y-A*Rx;
        test(k)=norm(res,2);
    end
[value,order]=min(test);
classification(t)=order;
   if t<(order-1)*Class_Test_NUM+1|t>order*Class_Test_NUM
       miss=miss+1;
   end
   distribute(t)=(Class_NUM*sum(abs(xp(Class_Test_NUM*(order-1)+1:Class_Test_NUM*order)))/L-1)/(Class_NUM-1);
end

classification=reshape(classification,Class_Test_NUM,Class_NUM);
distribute=reshape(distribute,Class_Test_NUM,Class_NUM);
classification
distribute
miss
Recognition_rate=(Test_NUM-miss)/Test_NUM;

MatrixS_part=MatrixS(1:3*Class_Test_NUM,1:3*Class_Test_NUM)
fprintf('Recognition_rate=%7.3f',Recognition_rate);
time=etime(clock,t0)


