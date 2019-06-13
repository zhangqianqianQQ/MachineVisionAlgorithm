function [ prediction, value ] = LRClassify( weights, xTest )
    [dataSize, ~] = size(xTest);
    
    % Add the column of ones for the bias feature
    xTest = [ones(dataSize, 1) xTest];
    
    % Find the probability of the image being in each class
    probability = sigmoid(xTest * weights');
    
    % Find the best class label for the image
    % The best class is one with the highest probability
    [value, index] =  max(probability, [], 2);
    prediction = index - 1;
end
