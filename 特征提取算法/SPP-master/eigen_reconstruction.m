row=112;
column=92; 
NN=row*column;

Class_Train_NUM=5;
Class_Sample_NUM=10; % total
Class_Test_NUM=Class_Sample_NUM-Class_Train_NUM;

Class_NUM=40;
Train_NUM=Class_NUM*Class_Train_NUM; % 
Test_NUM=Class_NUM*(Class_Sample_NUM-Class_Train_NUM); % 

Eigen_NUM=10;
Disc_NUM=Eigen_NUM;

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
% !!! Note that: Centralization have great effection when
%  Cos distance is used, but it has no impact when L2 or L1 distance is used
Mean_Image=mean(Train_DAT,2);  
Train_DAT=Train_DAT-Mean_Image*ones(1,Train_NUM);
Test_DAT=Test_DAT-Mean_Image*ones(1,Test_NUM);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Projection,disc_value]=Eigenface_f(Train_DAT, Disc_NUM); 
Eigen_face=zeros(NN,10);

for k=1:1:10
    Eigen_face(:,k)=Projection(:,k);
    Eigen_face(:,k)=mat2gray(Eigen_face(:,k));
end

Eigen_face=reshape(Eigen_face,[row,column,10]);

for count=1:1:10
    subplot(1,10,count);imshow(Eigen_face(:,:,count))
end
    





