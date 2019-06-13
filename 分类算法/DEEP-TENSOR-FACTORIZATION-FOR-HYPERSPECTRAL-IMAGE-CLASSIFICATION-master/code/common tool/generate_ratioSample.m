function [selTrainData,selTrainLabel,selTestData,selTestLabel] = generate_ratioSample(exp_time,ratio,data,Label,mask)
% Using existing mask to permute each class, selecting training samples and
% testing samples by ratio

idx=Label>0;
Label=Label(idx);
data=data(idx,:);

classes=unique(Label);

for exp_count=1:exp_time
        
    selTrainData=[];
    selTrainLabel=[];
    
    selTestData=[];
    selTestLabel=[];
         
    for i=1:length(classes)
        temp=data(Label==classes(i),:);
        temp=temp(mask{i},:);
        n=size(temp,1);
        numTrain=ceil(ratio*n);
        train=1:floor(numTrain);
        test=floor(numTrain)+1:n;
        
        selTrainData=[selTrainData;temp(train,:)];
        selTestData=[selTestData;temp(test,:)];
        selTrainLabel=[selTrainLabel;classes(i)*ones(length(train),1)];
        selTestLabel=[selTestLabel;classes(i)*ones(length(test),1)];
    end       
end



