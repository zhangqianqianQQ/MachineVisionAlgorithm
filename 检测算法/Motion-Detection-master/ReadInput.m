function [Img1_KLT Img2_KLT] = ReadInput(DataDir,FileNum,SrcNo)
for i = 1:FileNum
    DataName = strcat(num2str(i),'.txt');
    DataName = strcat('_r_',DataName);
    DataName = strcat(num2str(SrcNo),DataName);
    DataName = strcat(DataDir,DataName);
    FileName(i,:) = DataName;
%     display(FileName(i,:));
end

K1 = importdata(FileName(1,:));
K2 = importdata(FileName(2,:));
K3 = importdata(FileName(3,:));
K4 = importdata(FileName(4,:));
K5 = importdata(FileName(5,:));
K6 = importdata(FileName(6,:));
K7 = importdata(FileName(7,:));
K8 = importdata(FileName(8,:));
K9 = importdata(FileName(9,:));

Img1_KLT.R1_p = K1(:,1:2);
Img1_KLT.R2_p = K2(:,1:2);
Img1_KLT.R3_p = K3(:,1:2);
Img1_KLT.R4_p = K4(:,1:2);
Img1_KLT.R5_p = K5(:,1:2);
Img1_KLT.R6_p = K6(:,1:2);
Img1_KLT.R7_p = K7(:,1:2);
Img1_KLT.R8_p = K8(:,1:2);
Img1_KLT.R9_p = K9(:,1:2);

Img2_KLT.R1_p = K1(:,3:4);
Img2_KLT.R2_p = K2(:,3:4);
Img2_KLT.R3_p = K3(:,3:4);
Img2_KLT.R4_p = K4(:,3:4);
Img2_KLT.R5_p = K5(:,3:4);
Img2_KLT.R6_p = K6(:,3:4);
Img2_KLT.R7_p = K7(:,3:4);
Img2_KLT.R8_p = K8(:,3:4);
Img2_KLT.R9_p = K9(:,3:4);