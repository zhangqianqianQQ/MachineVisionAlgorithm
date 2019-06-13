function [ wConvol, wHidden, wBias ] = initWeights(imageDim, filterDim, ...
                                           numFilters, poolSize, numLabels)
    wConvol = 0.1 .* randn(filterDim, filterDim, numFilters);
    
    convDim = imageDim - filterDim + 1;
    poolDim = convDim / poolSize;
    hiddenSize = (poolDim ^ 2) * numFilters;
    wHidden = randn(numLabels, hiddenSize);
    
    
  
    wBias = zeros(numFilters,1);
end

