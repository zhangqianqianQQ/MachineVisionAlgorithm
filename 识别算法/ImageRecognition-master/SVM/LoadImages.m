function [Features] = LoadImages()
	Features = [];
	for j = 1:5
		num = num2str(j);
		str = strcat('../CIFAR10/small_data_batch_',num,'.mat');
		load(str);
		Features = vertcat(Features,data);
    end
end