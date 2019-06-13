function [histograms, xoffset, yoffset] = getHistogramsForImage(hog, img)
%GETHISTOGRAMSFORIMAGE Calculats histograms for ALL cells in an image.
%  This function is part of a technique for optimizing the process of 
%  computing HOG descriptors over a search image. If we use a window stride
%  which is a multiple of the cell size, then we only need to calculate the
%  histograms for each cell once. Later, during the search process, we
%  select the cells for a given detection window, then apply block
%  normalization to create the final descriptor.
%
%  Parameters:
%    hog            - Structure defining the HOG detector. 
%      hog.cellSize - Pixel dimension of a cell (e.g., 8px).
%      hog.numBins  - Number of histogram bins to use (e.g., 9).
%    img            - The input image to be searched.
%   
%  Returns:
%    histograms - 3D matrix of histograms for all cells in the image:
%                 The first two dimensions index the matrix by cell number,
%                 and the third dimension contains the histograms.
%                 For example, the histogram for the cell at (3, 5) is 
%                 given by histograms(3, 5, :)
%    xoffset,   - If the image dimensions are not even multiples of the 
%    yoffset      cell size, then we will first crop the image. We try to
%                 center the crop window within the image. xoffset and 
%                 yoffset are the coordinates of the top-left-corner of the
%                 crop window relative to the original image.
%
%    TODO - It would probably be simpler and cleaner to require that all
%           input images are multiples of the cell size.


% =============================
%       Crop The Image
% =============================

[imgHeight, imgWidth] = size(img);

% Compute the number of cells horizontally and vertically for the image.
numHorizCells = floor((imgWidth - 2) / hog.cellSize);
numVertCells = floor((imgHeight - 2) / hog.cellSize);

% Compute the new image dimensions.
newWidth = (numHorizCells * hog.cellSize) + 2;
newHeight = (numVertCells * hog.cellSize) + 2;

% Divide the left-over pixels in half to center the crop region.
xoffset = round((imgWidth - newWidth) / 2) + 1;
yoffset = round((imgHeight - newHeight) / 2) + 1;

% Crop the image.
img = img(yoffset : (yoffset + newHeight - 1), xoffset : (xoffset + newWidth - 1));

% ===============================
%    Compute Gradient Vectors
% ===============================
% Compute the gradient vector at every pixel in the image.

% Create the operators for computing image derivative at every pixel.
hx = [-1,0,1];
hy = -hx';

% Compute the derivative in the x and y direction for every pixel.
dx = filter2(hx, double(img));
dy = filter2(hy, double(img));

% Remove the 1 pixel border.
dx = dx(2:(newHeight - 1), 2:(newWidth - 1));
dy = dy(2:(newHeight - 1), 2:(newWidth - 1));

% Convert the gradient vectors to polar coordinates (angle and magnitude).
angles = atan2(dy, dx);
magnit = ((dy.^2) + (dx.^2)).^.5;

% =================================
%     Compute Cell Histograms 
% =================================
% Compute the histogram for every cell in the image. We'll combine the cells
% into blocks and normalize them later.

% Create a three dimensional matrix to hold the histogram for each cell.
histograms = zeros(numVertCells, numHorizCells, hog.numBins);

% For each cell in the y-direction...
for row = 0:(numVertCells - 1)
    
    % Compute the row number in the 'img' matrix corresponding to the top
    % of the cells in this row. Add 1 since the matrices are indexed from 1.
    rowOffset = (row * hog.cellSize) + 1;
    
    % For each cell in the x-direction...
    for col = 0:(numHorizCells - 1)
    
        % Select the pixels for this cell.
        
        % Compute column number in the 'img' matrix corresponding to the left
        % of the current cell. Add 1 since the matrices are indexed from 1.
        colOffset = (col * hog.cellSize) + 1;
        
        % Compute the indices of the pixels within this cell.
        rows = rowOffset : (rowOffset + hog.cellSize - 1);
        cols = colOffset : (colOffset + hog.cellSize - 1);
        
        % Select the angles and magnitudes for the pixels in this cell.
        cellAngles = angles(rows, cols); 
        cellMagnitudes = magnit(rows, cols);
    
        % Compute the histogram for this cell.
        % Convert the cells to column vectors before passing them in.
        histograms(row + 1, col + 1, :) = getHistogram(cellMagnitudes(:), cellAngles(:), hog.numBins);
    end
    
end

end
