function [ Model2 ] = NNTest()

    % Extract Features From the Images
    [Features] = LoadImages();
    % Load The Image Classes
    [yTrain] = LoadLabels();
    
    % Tweak these parameters to get optimum accuracy
    varianceThreshold = 0.90;
    thresholdDifference = 0.0004;
    regularizationRate = 6.5;
    learningRate = 1;
    hiddenNodes = 175;
    
    [xTrain, projection] = BestFeats(Features, varianceThreshold);
    
    % Train the Neural Net.
    [ weights1, weights2, ~ ] = NNTrain(xTrain, yTrain, hiddenNodes, ...
                                    learningRate, regularizationRate, ...
                                    thresholdDifference);
    Model2 = struct('weights1', weights1, 'weights2', weights2, ...
             'projection', projection);
    save('Model2.mat', 'Model2');
      
end