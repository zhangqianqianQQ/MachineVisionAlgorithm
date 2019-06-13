clear;
clc;
close all

% create test data to check the correctness of Ridege Regression and RRSVM algorithms 

% inputdata:
% 150 positive, 150 negative
% each data is d by n where d is the dimension, n is the number of local
% features here d=100,n=100

% create data for training: 300, 150 positive and 150 negative
d=100;           % each feature has dimention of 100
nB=100;          % each image has 100 local features
nTr=300;         % 300 images for training
nTst=100;        % 300 featreus for testing

trDPos=cell(nTr/2,1);
trDNeg=cell(nTr/2,1);
tstDPos=cell(nTst/2,1);
tstDNeg=cell(nTst/2,1);

rng(1);

posMu=[10* ones(50,1);ones(50,1)]; 
noiseMu=[5.5* ones(50,1);5.5*ones(50,1)];
% create training data: 150 positive, 150 negative, for each positive
% label: there are 30 posivitive instance and 70 negative instances
for i=1:1:nTr/2
trDPos{i}=ML_Norm.l2norm(   [repmat(posMu,1,30),repmat(noiseMu,1,70)]+randn(100));
trDNeg{i}=ML_Norm.l2norm( [repmat(noiseMu,1,100)]+randn(100));
end

trD=cat(1,trDPos(:),trDNeg(:));
trLb= [ones(length(trDPos),1);-1* ones(length(trDNeg),1)];



for i=1:1:nTst/2
tstDPos{i}=ML_Norm.l2norm([repmat(posMu,1,30),repmat(noiseMu,1,70)]+randn(100));
tstDNeg{i}=ML_Norm.l2norm([repmat(noiseMu,1,100)]+randn(100));
end

tstD=cat(1,tstDPos(:),tstDNeg(:));
tstLb= [ones(length(tstDPos),1);-1* ones(length(tstDNeg),1)];

save('valData.mat','trLb','tstLb','trD','tstD');