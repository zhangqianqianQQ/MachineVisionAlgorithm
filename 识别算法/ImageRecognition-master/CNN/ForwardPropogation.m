function [hidden, output] = ForwardPropogation(wConvol, wHidden, wBias, xTrain)
    % Dimension: (numImages, numFeatures)
    xTrain = xTrain(:, 1: 1024);
    numImages = size(xTrain,1);
    
    % wConvol is (filterDim, filterDim, numFilters) dimension
    numFilters = size(wConvol,3);
    filterDim = size(wConvol,2);
    
    imageDim = 32;
    convDim = imageDim - filterDim + 1;
    poolSize = 2;
    poolDim = convDim / poolSize;
    
    convolutions = zeros(convDim, convDim, numFilters, numImages);
    pooling = zeros(poolDim, poolDim, numFilters, numImages);
    images = reshape(xTrain, imageDim, imageDim,[]);
    
    for imageNum = 1: numImages
        for filterNum = 1: numFilters
            % Convolution Layer
            convolvedImage = zeros(convDim, convDim);
            filter = wConvol(:,:,filterNum);
            filter = rot90(squeeze(filter),2);
            im = squeeze(images(:,:,imageNum));
            for i = 1 : convDim
                for j = 1 : convDim
                    temp = double(im(i:i+filterDim-1,j:j+filterDim-1));
                    temp = temp .* filter;
                    convolvedImage(i,j) = sum(temp(:));
                    bias = wBias(filterNum);
                    convolvedImage(i,j) = sigmoid(convolvedImage(i,j) + bias);
                end
            end
            convolutions(:,:,filterNum, imageNum) = convolvedImage;
            
            % Pooling Layer
            pooledImage = zeros(poolDim, poolDim);
            for i = 1 : poolDim
                for j = 1 : poolDim
                    x = ((i-1) * poolSize) + 1;
                    y = ((j-1) * poolSize) + 1;
                    temp = convolvedImage(x:x+poolSize-1, y:y+poolSize-1);
                    pooledImage(i,j) = max(temp(:));
                end
            end
            pooling(:,:,filterNum, imageNum) = pooledImage;
        end
    end
    
    % Hidden Layer
    % Dimension is (hiddenSize, numImages)
    hidden = reshape(pooling,[],numImages);
    
    
    % Output Layer 
    % Calculate the probability of each output unit/Label
    output = sigmoid(wHidden * hidden);
    output = output';
    hidden = hidden';
    
end