function [hidden, output] = ForwardPropogation(weights1, weights2, xTrain)
    numSamples = size(xTrain,1);
    
    % Predict the value of the hiddenFeatures
    hidden = sigmoid(xTrain * weights1');
    hidden = [ones(numSamples, 1) hidden];
    
    % Calculate the probability of each output unit/Label
    output = sigmoid(hidden * weights2');
end