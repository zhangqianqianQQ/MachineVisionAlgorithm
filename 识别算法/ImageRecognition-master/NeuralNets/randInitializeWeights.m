function weight = randInitializeWeights(inputs, outputs)
    % Initialize the weights randomly.
    % This will break the symmetry while training the neural network.
    epsilon = 0.12;
    weight = rand(outputs, inputs + 1) * (2 * epsilon) - epsilon;
end

