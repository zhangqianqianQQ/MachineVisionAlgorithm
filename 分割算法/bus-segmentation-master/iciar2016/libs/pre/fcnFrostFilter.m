function outputImage = fcnFrostFilter(inputImage,mask)

% fcnFrostFilter performs noise filtering on an image based
%   on using an adaptive filter proposed by Frost.
%
%   OUTPUTIMAGE = fcnFrostFilter(INPUTIMAGE) performs
%   filtering of an image using the Frost filter. It uses a square neighborhood of 5x5
%   pixels to estimate the gray-level statistics in default settings.
%   Supported data type for INPUTIMAGE are uint8, uint16, uint32, uint64,
%   int8, int16, int32, int64, single, double. OUTPUTIMAGE has the same
%   image type as INPUTIMAGE.
%
%   OUTPUTIMAGE = fcnFrostFilter(INPUTIMAGE,MASK) performs
%   the filtering with local statistics computed based on the neighbors as
%   specified in the locical valued matrix MASK.
% 
%   Details of the method are avilable in
% 
%   V. S. Frost, "A Model for Radar Images and Its Application to Adaptive 
%   Digital Filtering of Multiplicative Noise," IEEE Trans. Pattern Anal., 
%   Machine Intell., vol. 4, no. 2, pp. 157-166, Mar. 1982. 
%   [http://dx.doi.org/10.1109/TPAMI.1982.4767223]
%
%   2012 (c) Debdoot Sheet, Indian Institute of Technology Kharagpur, India
%       Ver 1.0     13 February 2012
%
% Example
% -------
% inputImage = imnoise(imread('cameraman.tif'),'speckle',0.01);
% outputImage1 = fcnFrostFilter(inputImage);
% outputImage2 = ...
% fcnFrostFilter(inputImage,getnhood(strel('disk',3,0)));
% figure, subplot 131, imshow(inputImage), subplot 132,
% imshow(outputImage1), subplot 133, imshow(outputImage2)
%

% 2012 (c) Debdoot Sheet, Indian Institute of Technology Kharagpur, India
% All rights reserved.
% 
% Permission is hereby granted to use, copy, modify, and distribute this code 
% (the source files) and its documentation for any purpose, provided that 
% the copyright notice in its entirety appear in all copies of this code, 
% and the original source of this code. Further Indian Institute of 
% Technology Kharagpur (IIT Kharagpur / IITKGP)  is acknowledged in any
% publication that reports research or any usage using this code. 
%
% In no circumstantial cases or events the Indian Institute of Technology
% Kharagpur or the author(s) of this particular disclosure be liable to any
% party for direct, indirectm special, incidental, or consequential 
% damages if any arising out of due usage. Indian Institute of Technology 
% Kharagpur and the author(s) disclaim any warranty, including but not 
% limited to the implied warranties of merchantability and fitness for a 
% particular purpose. The disclosure is provided hereunder "as in" 
% voluntarily for community development and the contributing parties have 
% no obligation to provide maintenance, support, updates, enhancements, 
% or modification.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Input argument check
iptcheckinput(inputImage,{'uint8','uint16','uint32','uint64','int8','int16','int32','int64','single','double'}, {'nonsparse','2d'}, mfilename,'I',1);

if nargin == 1
    mask = getnhood(strel('square',5));
elseif nargin == 2
    if ~islogical(mask)
        error('Mask of neighborhood specified must be a logical valued matrix');
    end
else
    error('Unsupported calling of fcnFirstOrderStatisticsFilter');
end

imageType = class(inputImage);

windowSize = size(mask);

inputImage = padarray(inputImage,[floor(windowSize(1)/2) floor(windowSize(2)/2)],'symmetric','both');

inputImage = double(inputImage);

[nRows,nCols] = size(inputImage);

outputImage = double(inputImage);

[xIndGrid yIndGrid] = meshgrid(-floor(windowSize(1)/2):floor(windowSize(1)/2),-floor(windowSize(2)/2):floor(windowSize(2)/2));

expWeight = exp(-(xIndGrid.^2 + yIndGrid.^2).^0.5);

for i=ceil(windowSize(1)/2):nRows-floor(windowSize(1)/2)
    for j=ceil(windowSize(2)/2):nCols-floor(windowSize(2)/2)
        localNeighborhood = inputImage(i-floor(windowSize(1)/2):i+floor(windowSize(1)/2),j-floor(windowSize(2)/2):j+floor(windowSize(2)/2));
        localNeighborhood = localNeighborhood(mask);
        localMean = mean(localNeighborhood(:));
        localVar = var(localNeighborhood(:));
        alpha = sqrt(localVar)/localMean;
        localWeight = alpha*(expWeight.^alpha);
        localWeightLin = localWeight(mask);
        localWeightLin = localWeightLin/sum(localWeightLin(:));
        outputImage(i,j) = sum(localWeightLin.*localNeighborhood);
    end
end

outputImage = outputImage(ceil(windowSize(1)/2):nRows-floor(windowSize(1)/2),ceil(windowSize(2)/2):nCols-floor(windowSize(2)/2));

outputImage = cast(outputImage,imageType);