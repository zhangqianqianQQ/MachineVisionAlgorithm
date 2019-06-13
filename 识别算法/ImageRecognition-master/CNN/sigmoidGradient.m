function [ gradient ] = sigmoidGradient(z)
     gradient = sigmoid(z) .* (1 - sigmoid(z));
end

