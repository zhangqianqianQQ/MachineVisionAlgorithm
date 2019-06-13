function [ weights1, weights2, loss ] = NNTrain(xTrain, yTrain, ...
                                        hiddelLayerSize, learningRate, ...
                                        regularizationRate, thresholdDifference)
    [dataSize, featureSize] = size(xTrain);
    labelSize = length(unique(yTrain));
    xTrain = [ones(dataSize, 1) xTrain];
    
    % Find the actual Output for each ouput unit of the Neural Network.
    actualOutput = zeros(dataSize, labelSize);
    for i = 1 : dataSize
        actualOutput(i, yTrain(i) + 1) = 1;
    end;
    
    % Tweak these params to alter the model parameters
    weights1 = randInitializeWeights(featureSize, hiddelLayerSize);
    weights2 = randInitializeWeights(hiddelLayerSize, labelSize);
    previousLoss = 10;
    loss = 0;
    
    while ((previousLoss - loss) > thresholdDifference)
        if loss ~= 0
            previousLoss = loss;
        end
        
        % Calculate the value of the hidden and output layers.
        [hidden, predictedOutput] = ForwardPropogation(weights1, weights2, xTrain);
        
        % Calculate the loss function.
        % In the regularization Term, don't regularize the bias component.
        logisticError = (actualOutput .* log(predictedOutput)) + ((1 - actualOutput) .* log(1 - predictedOutput));
        temp1 = weights1 .^ 2;
        temp1(:,1) = 0;
        temp2 = weights2 .^ 2;
        temp2(:,1) = 0;
        regularizationTerm = (regularizationRate / (2 * dataSize)) * (sum(temp1(:)) + sum(temp2(:)));
        loss = (-1/dataSize) * sum(logisticError(:)) + regularizationTerm
        
        % Calulcate error in estimating output unit.
        errorOutput = (predictedOutput - actualOutput) .* sigmoidGradient(predictedOutput);
        
        % Calculate error in estimating Hidden unit.
        errorHidden = (errorOutput * weights2) .* sigmoidGradient(hidden);
        errorHidden(:,1) = [];
        
        % Calculate Gradient for the weights.
        % Do not regularize the bias term.
        regularizationTerm1 = (regularizationRate / dataSize) .* (weights1);
        regularizationTerm1(:,1) = 0;
        grad1 = ((errorHidden' * xTrain) ./ dataSize) + regularizationTerm1;
        regularizationTerm2 = (regularizationRate / dataSize) .* (weights2);
        regularizationTerm2(:,1) = 0;
        grad2 = ((errorOutput' * hidden) ./ dataSize) + regularizationTerm2;
        
        % Update the weights via the gradient descent update rule.
        weights1 = weights1 - learningRate * grad1;
        weights2 = weights2 - learningRate * grad2;
    end
end

