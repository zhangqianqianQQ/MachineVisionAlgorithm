function [ Y ] = classify2( Model, X )

    % Extract Features from the test data
    data = getImages(X);
    
    weights1 = Model.weights1;
    weights2 = Model.weights2;
    projection = Model.projection;
    
    % Project the test data on the new dimension
    xTest = getFeatures(data, projection);
    
    % Classify the images
    [Y, ~] = NNClassify(weights1, weights2, xTest);
end

function [Features] =  getImages(data)
    Features = [];
    for i = 1:size(data,1)
        image = reshape(data(i,:),[32,32,3]);
        image = imresize(image,4);
        feat = extract_feature(image);
        Features = horzcat(Features,feat);
    end
    Features = Features';
end

function [Feats] = getFeatures(Features, projection)
    featureSize = size(Features,2);
    
    % Perform Mean Normalization on the Feature Matrix.
    % Each pixel can have intensity values from 0 - 255
    for i = 1 : featureSize
        Features(:,i) = Features(:,i) - mean(Features(:,i));
    end
    
    % Project the Features on the new dimension
    Feats = projection * Features';
    Feats = Feats';
end
