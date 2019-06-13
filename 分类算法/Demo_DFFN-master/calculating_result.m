%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script is used to calculate three metrics (i.e., OA, AA, Kappa) 
% and draw classification map.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
close all;
clc

OA=[];
AA=[];
CA=[];
kappa=[];

%%%%%%%%%%%%%%%% for the Indian Pines image  %%%%%%%%%%%%%%%%%%%%%%
num_classes=16;   
prob_data=importdata('info/indian_pines_prob.txt');
load(strcat('auxiliary_data/indian_pines/data.mat'));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% for the University of Pavia image %%%%%%%%%%%%%%%%
% num_classes=9;   
% prob_data=importdata('info/paviau_prob.txt');
% load(strcat('auxiliary_data/paviau/data.mat'));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% for the Salinas image %%%%%%%%%%%%%%%%%%%%%%%%%%
% num_classes=16;   
% prob_data=importdata('info/salinas_prob.txt');
% load(strcat('auxiliary_data/salinas/data.mat'));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

prob_data_temp=prob_data;  
true_label=TEST_LABEL';
test_prob=[];
predict_label=[];
for i=1:length(prob_data_temp)/num_classes
    prob_temp=prob_data_temp((i-1)*num_classes+1:i*num_classes,:)';
    test_prob=[test_prob;prob_temp];
    predict_label=[predict_label;find(prob_temp==max(prob_temp))];
end

[OA,kappa, AA,CA]=calcError(true_label,predict_label-1,1:num_classes)

%%%%%%%%%%%%%%%%%%%%%%  draw classification map    %%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%  for the Indian Pines image %%%%%%%%%%%%%%%%
resultsmap=zeros(145*145,1);  
resultsmap(TRAIN_INDEX',:)=TRAIN_LABEL'+1;
resultsmap(TEST_INDEX',:)=predict_label;
resultsmap=reshape(resultsmap,145,145);
maps=label2color(resultsmap,'india');  
imwrite(maps,'DFFN_indian_pines.jpg','jpg'); 
figure,imshow(maps);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%  for the University of Pavia image %%%%%%%%%%
% resultsmap=zeros(610*340,1);  
% resultsmap(TRAIN_INDEX',:)=TRAIN_LABEL'+1;
% resultsmap(TEST_INDEX',:)=predict_label;
% resultsmap=reshape(resultsmap,610,340); 
% maps=label2color(resultsmap,'uni'); 
% imwrite(maps,'DFFN_paviau.jpg','jpg'); 
% figure,imshow(maps);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%  for the Salinas image %%%%%%%%%%
% resultsmap=zeros(512*217,1);  
% resultsmap(TRAIN_INDEX',:)=TRAIN_LABEL'+1;
% resultsmap(TEST_INDEX',:)=predict_label;
% resultsmap=reshape(resultsmap,512,217); 
% maps=label2color(resultsmap,'india'); 
% imwrite(maps,'DFFN_salinas.jpg','jpg'); 
% figure,imshow(maps);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
