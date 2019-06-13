function [Features] =  LoadImages()
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
        % Feat = Feat';
        Features = vertcat(Features,Feat');
    end
end