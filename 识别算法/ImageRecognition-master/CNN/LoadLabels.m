%Function used to load labels and concatenate them

function [Labels] = LoadLabels()
Labels = [];
for j = 1:1
    num = num2str(j);
    str = strcat('../CIFAR10/small_data_batch_',num,'.mat');
    load(str);
    Labels = vertcat(Labels,labels);
end

end