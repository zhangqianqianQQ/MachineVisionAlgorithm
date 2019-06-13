function [mask] = random_pm(data,label)
% randomly choose the permutation for each class, returned as mask for
% picking the fixed training samples
rand('state',sum(100*clock));

idx=label>0;
Label=label(idx);
data=data(idx,:);
classes=unique(Label);
mask = cell(1,length(classes));

for i=1:length(classes)
    temp=data(Label==classes(i),:);
    % saved as mask
    mask{i} = randperm(size(temp,1));
end
