function [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_SampleSpecial(ratio,data,Label,mask,amount)
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
    temp=temp(mask{i},:);
    n=size(temp,1);
    if nargin == 5
        numTrain=ceil(ratio*amount(i));
        train=1:floor(numTrain);
        test=floor(numTrain)+1:n;
    elseif nargin == 4
        train = 1:ratio(i);
        test = ratio(i)+1:n; 
    end
    tempTrain = temp(train,:);
    tempTest = temp(test,:);

    selTrainData=[selTrainData;tempTrain];
    selTestData=[selTestData;tempTest];
    selTrainLabel=[selTrainLabel;classes(i)*ones(size(tempTrain,1),1)];
    selTestLabel=[selTestLabel;classes(i)*ones(size(tempTest,1),1)];

end       




