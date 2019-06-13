function [ Model1 ] = LRTest()

    % Load the Training Data
    [Features] = LoadImages();
    % Load The Image Labels
    [yTrain] = LoadLabels();
    
    % Learning Parameters. Tweak these values to get optimum accuracy
    varianceThreshold = 0.95;
    regularizationRate = 0.3;
    initialLearningRate = 10;
    stableLearningRate = 0.5;
    thresholdDifference = 0.0004;
    
     % Extract Features From the Images
    [xTrain, projection] = BestFeats(Features, varianceThreshold);
    
    % Train the classifier using one vs all methodology
    [weights, ~] = LRTrain(xTrain, yTrain, regularizationRate, ...
                        initialLearningRate, stableLearningRate, ...
                        thresholdDifference);
    
    Model1 = struct('weights', weights, 'projection', projection);
    save('Model1.mat', 'Model1');
    
end