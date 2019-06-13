function H = getHOGDescriptor(hog, img)
% GETHOGDESCRIPTOR computes a HOG descriptor vector for the supplied image.
%   H = getHOGDescriptor(img)
%  
%   This function takes a 130 x 66 pixel gray scale image (128 x 64 with a 
%   1-pixel border for computing the gradients at the edges) and computes a 
%   HOG descriptor for the image, returning a 3,780 value column vector.
%
%   Parameters:
%     img - A grayscale image matrix with 130 rows and 66 columns.
%   Returns:
%     A column vector of length 3,780 containing the HOG descriptor.
%
%    The intent of this function is to implement the same design choices as
%    the original HOG descriptor for human detection by Dalal and Triggs.
%    Specifically, I'm using the following parameter choices:
%      - 8x8 pixel cells
%      - Block size of 2x2 cells
%      - 50% overlap between blocks
%      - 9-bin histogram
%
%     The above parameters give a final descriptor size of 
%     7 blocks across x 15 blocks high x 4 cells per block x 9 bins per hist
%     = 3,780 values in the final vector.
%
%    A couple other important design decisions:
%    - Each gradient vector splits its contribution proportionally between the
%      two nearest bins
%    - For the block normalization, I'm using L2 normalization.
%
%    Differences with OpenCV implementation:
%    - OpenCV uses L2 hysteresis for the block normalization.
%    - OpenCV weights each pixel in a block with a gaussian distribution
%      before normalizing the block.
%    - The sequence of values produced by OpenCV does not match the order
%      of the values produced by this code.

    
% Empty vector to store computed descriptor.
H = [];

% Verify the input image size matches the HOG parameters.
assert(isequal(size(img), hog.winSize))

% ===============================
%    Compute Gradient Vectors
% ===============================
% Compute the gradient vector at every pixel in the image.

% Create the operators for computing image derivative at every pixel.
hx = [-1,0,1];
hy = hx';

% Compute the derivative in the x and y direction for every pixel.
dx = filter2(hx, double(img));
dy = filter2(hy, double(img));

% Remove the 1 pixel border.
dx = dx(2 : (size(dx, 1) - 1), 2 : (size(dx, 2) - 1));
dy = dy(2 : (size(dy, 1) - 1), 2 : (size(dy, 2) - 1)); 

% Convert the gradient vectors to polar coordinates (angle and magnitude).
angles = atan2(dy, dx);
magnit = ((dy.^2) + (dx.^2)).^.5;

% =================================
%     Compute Cell Histograms 
% =================================
% Compute the histogram for every cell in the image. We'll combine the cells
% into blocks and normalize them later.

% Create a three dimensional matrix to hold the histogram for each cell.
histograms = zeros(hog.numVertCells, hog.numHorizCells, hog.numBins);

% For each cell in the y-direction...
for row = 0:(hog.numVertCells - 1)
    
    % Compute the row number in the 'img' matrix corresponding to the top
    % of the cells in this row. Add 1 since the matrices are indexed from 1.
    rowOffset = (row * hog.cellSize) + 1;
    
    % For each cell in the x-direction...
    for col = 0:(hog.numHorizCells - 1)
    
        % Select the pixels for this cell.
        
        % Compute column number in the 'img' matrix corresponding to the left
        % of the current cell. Add 1 since the matrices are indexed from 1.
        colOffset = (col * hog.cellSize) + 1;
        
        % Compute the indices of the pixels within this cell.
        rowIndeces = rowOffset : (rowOffset + hog.cellSize - 1);
        colIndeces = colOffset : (colOffset + hog.cellSize - 1);
        
        % Select the angles and magnitudes for the pixels in this cell.
        cellAngles = angles(rowIndeces, colIndeces); 
        cellMagnitudes = magnit(rowIndeces, colIndeces);
    
        % Compute the histogram for this cell.
        % Convert the cells to column vectors before passing them in.
        histograms(row + 1, col + 1, :) = getHistogram(cellMagnitudes(:), cellAngles(:), hog.numBins);
    end
    
end

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
