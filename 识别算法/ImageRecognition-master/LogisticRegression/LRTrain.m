function [weights, loss] = LRTrain(xTrain, yTrain, regularizationRate, ...
                                initialLearningRate, stableLearningRate, ...
                                thresholdDifference)
	[dataSize, featureSize] = size(xTrain);
	labelSize = length(unique(yTrain));
	
    xTrain = [ones(dataSize, 1) xTrain];
	weights = zeros(labelSize,featureSize + 1);
    loss = zeros(labelSize,1);
	
    for label = 1 : labelSize
        % Take a large step initially.
        learningRate = initialLearningRate;
        output = (yTrain == (label-1));
        previousLoss = 1;
        iter = 0;
        while ((previousLoss - loss(label)) > thresholdDifference)
            if iter ~= 0
                previousLoss = loss(label);
            end
            iter = iter + 1;
            
            % Gradually decrease the step size for each iteration.
            % Let the learning rate stabilize at some point.
            if learningRate > stableLearningRate
                learningRate = learningRate/iter;
            end
            
            % initialization of the params
            gradient = zeros(featureSize + 1,1);
            loss(label) = 0;
            for i = 1 : dataSize
                hypothesis = xTrain(i,:) * weights(label,:)';
                prediction = sigmoid(hypothesis);
                y = output(i);
                
                % Keep a running count the value of the loss function
                % This loss function should decrease with each iteration
                regularizationTerm = regularizationRate * ((sum(gradient .^ 2)) / dataSize);
                regularizationTerm(1,:) = 0;
                loss(label) = loss(label) - ((y * log(prediction)) + ((1 - y) * log(1-prediction))) / dataSize;
                loss(label) = loss(label) + regularizationTerm;
                
                linearError = prediction - y;
                % Maintain a running sum of the gradient of the loss func
                regularize = regularizationRate .* gradient;
                regularize(1,:) = 0;
                gradient = gradient + (((xTrain(i,:)' .* linearError) + regularize) ./ dataSize);
            end
            loss
             % Update the parameters via the gradient descent update rule
            weights(label,:) = weights(label,:) - (learningRate .* gradient');	
        end
    end
end