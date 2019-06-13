function [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_fixedSample(amount,data,Label,mask)
% Pick the first amount samples in each class
% Row as samples, Column as features

% delete unlabeled data
idx=Label>0;
Label=Label(idx);
data=data(idx,:);

classes=unique(Label);

selTrainData=[];
selTrainLabel=[];

selTestData=[];
selTestLabel=[];

for i=1:length(classes)
    temp = data(Label==classes(i),:);
%     pm=randperm(size(temp,1));
%     temp=temp(pm,:);
%     n=size(temp,1);
%     numTrain=ceil(ratio*n);
    temp=temp(mask{i},:);
    tempTrain = temp(1:amount,:);
    tempTest = temp(amount+1:size(temp,1),:);

    selTrainData=[selTrainData;tempTrain];
    selTestData=[selTestData;tempTest];
    selTrainLabel=[selTrainLabel;classes(i)*ones(size(tempTrain,1),1)];
    selTestLabel=[selTestLabel;classes(i)*ones(size(tempTest,1),1)];

end       




