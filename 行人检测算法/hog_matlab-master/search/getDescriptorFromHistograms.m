function H = getDescriptorFromHistograms(hog, histograms)
%GETDESCRIPTORFROMHISTOGRAMS Get descriptor using pre-calculated histograms
%  This function takes the pre-computed histograms for an image, and
%  performs the final step, block normalization, to produce the final
%  descriptor. 
%
%  This function is part of a technique for optimizing the process of 
%  computing HOG descriptors over a search image. If we use a window stride
%  which is a multiple of the cell size, then we only need to calculate the
%  histograms for each cell once. During the search process, select the 
%  cells for a given detection window, then apply block normalization 
%  (using this function) to create the final descriptor.
%
%  Parameters:
%    hog                 - Structure defining the HOG detector. 
%      hog.numHorizCells - Number of cells across in the descriptor.
%      hog.numVertCells  - Number of cells up and down in the descriptor.
%    histograms          - The histograms for the HOG descriptor.
%
%  Returns:
%    H  - A fully computed HOG descriptor.
%

% Empty vector to store computed descriptor.
H = [];

% ===================================
%       Block Normalization
% ===================================    

% Take 2 x 2 blocks of cells and normalize the histograms within the block.
% Normalization provides some invariance to changes in contrast, which can
% be thought of as multiplying every pixel in the block by some coefficient.

% For each cell in the y-direction...
for row = 1:(hog.numVertCells - 1)    
    % For each cell in the x-direction...
    for col = 1:(hog.numHorizCells - 1)
    
        % Get the histograms for the cells in this block.
        blockHists = histograms(row : row + 1, col : col + 1, :);
        
        % Put all the histogram values into a single vector (nevermind the 
        % order), and compute the magnitude.
        % Add a small amount to the magnitude to ensure that it's never 0.
        magnitude = norm(blockHists(:)) + 0.01;
    
        % Divide all of the histogram values by the magnitude to normalize 
        % them.
        normalized = blockHists / magnitude;
        
        % Append the normalized histograms to our descriptor vector.
        H = [H; normalized(:)];
    end
end
    
end
