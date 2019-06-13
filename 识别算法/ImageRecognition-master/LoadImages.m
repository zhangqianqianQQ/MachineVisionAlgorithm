function [xTrain, yTrain] = LoadImages()
	xTrain = [];
    yTrain = [];
	for j = 1:5
		num = num2str(j);
		str = strcat('CIFAR10/small_data_batch_',num,'.mat');
		load(str);
        xTrain = vertcat(xTrain, data);
        yTrain = vertcat(yTrain, labels);
    end
end