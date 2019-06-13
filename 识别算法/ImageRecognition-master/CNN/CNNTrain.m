function [ wConvol, wHidden, wBias ] = CNNTrain( xTrain, yTrain, ...
                                        learningRate, thresholdLoss)
    [dataSize, features] = size(xTrain);
    labelSize = length(unique(yTrain));
    
    actualOutput = zeros(dataSize,labelSize);
    for i = 1 : dataSize
        actualOutput(i, yTrain(i)) = 1;
    end
    
    imageDim = 32;
    filterDim = 9;
    numFilters = 10;
    poolSize = 2;
    convDim = imageDim - filterDim + 1;
    poolDim = convDim / poolSize;
    [ wConvol, wHidden, wBias ] = initWeights(imageDim, filterDim, ...
                                    numFilters, poolSize, labelSize);
                                
                         
    loss = 0;
    previousLoss = 10;
    
    while ((previousLoss - loss) > thresholdLoss)
        [hidden, output] = ForwardPropogation(wConvol, wHidden, wBias, xTrain);
        loss = findLoss(actualOutput, output);
        
        % Error In Output Layer
        % Dimension: (images, numlabels)
        errorOutput = (output - labels) .* sigmoidGradient(output);
        
        % Dimension: (numlabels, hidden)
        hiddenGradient = ((errorOutput' * hidden) ./ dataSize);
        
        % Backpropogate error
        % Dimension: (images, hidden)
        errorHidden = (errorOutput * wHidden) .* sigmoidGradient(hidden);
        
        % Expand to the pooling layer (backpropagation: converting from output layer into
        % pooling layer)
        
        
        
        pooling = reshape(errorHidden, poolDim, poolDim, numFilters, dataSize);
        
        % Perform Gradient Descent
        wHidden = wHidden - (learningRate * hiddenGradient);
        wConvol = wConvol - (learningRate * convolGradient);
        wBias = wBias - (learningRate * biasGradient);
    end;
end

