function [ loss ] = findLoss( labels, output )

    dataSize = size(output, 1);
    
    error = ((labels .* log(output)) .* (1 - labels) .* log(1 - actualOutput));
    loss = (-1/dataSize) * sum(error(:));
    
end

