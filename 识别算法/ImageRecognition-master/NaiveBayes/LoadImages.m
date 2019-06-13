% Script for loading images LoadImages.mat and retrieve HOG

%Resizes the image to 4 times its value
%Look at the HOG features obtained to understand need for this step
%Stores features in .mat file so we dont have to run this repeatedly
function LoadImages()
	Features = [];
	for j = 1:5
		num = num2str(j);
		str = strcat('../CIFAR10/small_data_batch_',num,'.mat');
		load(str);
		Feat = [];
		for i = 1:size(data,1)
			image = reshape(data(i,:),[32,32,3]);
			image = imresize(image,4);
			feat = extract_feature(image);
			Feat = horzcat(Feat,feat);
		end
		Features{j} = Feat;
	end
	save('HOG_Features.mat','Features');
end