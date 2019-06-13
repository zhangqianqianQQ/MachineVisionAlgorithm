function H = getHistogram(magnitudes, angles, numBins)
% GETHISTOGRAM Computes a histogram for the supplied gradient vectors.
%   H = getHistogram(magnitudes, angles, numBins)
%   
%   This function takes the supplied gradient vectors and places them into a
%   histogram with 'numBins' based on their unsigned orientation. 
%
%   "Unsigned" orientation means that, for example, a vector with angle 
%   -3/4 * pi will be treated the same as a vector with angle 1/4 * pi. 
%
%   Each gradient vector's contribution is split between the two nearest bins,
%   in proportion to the distance between the two nearest bin centers.
%   
%   A gradient's contribution to the histogram is equal to its magnitude;
%   the magnitude is divided between the two nearest bin centers.
%
%   Parameters:
%     magnitudes - A column vector storing the magnitudes of the gradient 
%                  vectors.
%     angles     - A column vector storing the angles in radians of the 
%                  gradient vectors (ranging from -pi to pi)
%     numBins    - The number of bins to place the gradients into.
%   Returns:
%     A row vector of length 'numBins' containing the histogram.

% Compute the bin size in radians. 180 degress = pi.
binSize = pi / numBins;

% The angle values will range from 0 to pi.
minAngle = 0;

% Make the angles unsigned by adding pi (180 degrees) to all negative angles.
angles(angles < 0) = angles(angles < 0) + pi;

% The gradient angle for each pixel will fall between two bin centers.
% For each pixel, we split the bin contributions between the bin to the left
% and the bin to the right based on how far the angle is from the bin centers.

% For each pixel's gradient vector, determine the indeces of the bins to the
% left and right of the vector's angle.
%
% The histogram needs to wrap around at the edges--vectors on the far edges of
% the histogram (i.e., close to -pi or pi) will contribute partly to the bin
% at that edge, and partly to the bin on the other end of the histogram.
% For vectors with an orientation close to 0 radians, leftBinIndex will be 0. 
% Likewise, for vectors with an orientation close to pi radians, rightBinIndex
% will be numBins + 1. We will fix these indeces after we calculate the bin
% contribution amounts.
leftBinIndex = round((angles - minAngle) / binSize);
rightBinIndex = leftBinIndex + 1;

% For each pixel, compute the center of the bin to the left.
leftBinCenter = ((leftBinIndex - 0.5) * binSize) - minAngle;

% For each pixel, compute the fraction of the magnitude
% to contribute to each bin.
rightPortions = angles - leftBinCenter;
leftPortions = binSize - rightPortions;
rightPortions = rightPortions / binSize;
leftPortions = leftPortions / binSize;

% Before using the bin indeces, we need to fix the '0' and '10' values.
% Recall that the histogram needs to wrap around at the edges--bin "0" 
% contributions, for example, really belong in bin 9.
% Replace index 0 with 9 and index 10 with 1.
leftBinIndex(leftBinIndex == 0) = numBins;
rightBinIndex(rightBinIndex == (numBins + 1)) = 1;

% Create an empty row vector for the histogram.
H = zeros(1, numBins);

% For each bin index...
for i = 1:numBins
    % Find the pixels with left bin == i
    pixels = (leftBinIndex == i);
        
    % For each of the selected pixels, add the gradient magnitude to bin 'i',
    % weighted by the 'leftPortion' for that pixel.
    H(1, i) = H(1, i) + sum(leftPortions(pixels)' * magnitudes(pixels));
    
    % Find the pixels with right bin == i
    pixels = (rightBinIndex == i);
        
    % For each of the selected pixels, add the gradient magnitude to bin 'i',
    % weighted by the 'rightPortion' for that pixel.
    H(1, i) = H(1, i) + sum(rightPortions(pixels)' * magnitudes(pixels));
end    

end