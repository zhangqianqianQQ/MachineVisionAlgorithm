% Script for loading images LoadImages.mat and retrieve HOG

%Resizes the image to 4 times its value
%Look at the HOG features obtained to understand need for this step
%Stores features in .mat file so we dont have to run this repeatedly
function [Features] = LoadImages()
	Features = [];
	for j = 1:2
		num = num2str(j);
		str = strcat('../CIFAR10/small_data_batch_',num,'.mat');
		load(str);
		Features = vertcat(Features,data);
    end
end