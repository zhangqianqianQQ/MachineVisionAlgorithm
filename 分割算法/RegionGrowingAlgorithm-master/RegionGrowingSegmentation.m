function [ segmentedImage, binaryImage, regionMatrix ] = RegionGrowingSegmentation( image, neighborhoodType )
%REGIONGROWINGSEGMENTATION Region Growing algorithm for segmenting an image
%   partition of an image into a set of non-overlapped regions whose union is the entire image
%
% image: Color or grayscale image
%
% neighborhood: 4 or 8 neighbor pixel connectivity. Default set to 8.
%

% If neighborhood is not given, we set it to 8
if nargin < 2
    neighborhoodType = 8;
end

% image = double(image);

% Getting size of the image
[imageRowCount, imageColCount, imageChannelCount] = size(image);

% Same size as image, we mark visited pixels
visitedMatrix = zeros(imageRowCount, imageColCount);

% Same size as image, we mark region labels
regionMatrix = zeros(imageRowCount, imageColCount);

% Region Label Counter
currentRegionLabel = 1;

imageGray = image;

% If image is color image, we convert it to grayscale
if imageChannelCount > 1
    imageGray = rgb2gray(image);
end

% We decided to find seeds in histogram peaks

% We get histogram of the image
[counts, x] = imhist(imageGray);

% We find peak points of histogram with threshold 100
[maxPeaks, ~] = peakdet(counts, 100, x);

% Peaks are sorted according to most frequent ones in descending order
maxPeaksSorted = sortrows(maxPeaks, -2);

% We get value column, removing frequency column
maxPeaksSorted = maxPeaksSorted(:, 1);

peakCount = numel(maxPeaksSorted);
display('peak count:');
display(peakCount);

% Loop while there is no unlabeled region in region matrix
while(~isempty(find(regionMatrix == 0, 1)))

% Getting unlabled seed in image
[seedRow, seedCol] = FindSeed(imageGray, regionMatrix, maxPeaksSorted);

% If no seed found
if seedRow == -1 || seedCol == -1
    
%     tic;
%     display('CheckFixUnlabeledRegions');
%     regionMatrix = CheckFixUnlabeledRegions(regionMatrix);
%     toc;
    
    [seedRow, seedCol] = FindSeedFromUnlabeled(regionMatrix);
    
    if isempty(seedRow) || isempty(seedCol)
        break;
%         segmentedImage = 0;
%         display(regionMatrix);
%         imagesc(regionMatrix);
%         return;
    end
    
%     [I, J] = find(regionMatrix == 0);
%     
%     %error('We need to handle this part');
%     segmentedImage = 0;
%     display(regionMatrix);
%     imagesc(regionMatrix);
%     return;
end

% Region keeping t
currentRegion = 0;

if imageChannelCount > 1
    currentRegion = [ image(seedRow, seedCol, 1), image(seedRow, seedCol, 2), image(seedRow, seedCol, 3) ]; 
else
    currentRegion = [ image(seedRow, seedCol) ];
end

% Marking seed point as visited
visitedMatrix(seedRow, seedCol) = 1;

% Marking seed with current region label
regionMatrix(seedRow, seedCol) = currentRegionLabel;

% Initial Threshold for adding neighbors to region
threshold = mean(std(double(image)));
if imageChannelCount > 1
    threshold = [threshold(:, :, 1), threshold(:, :, 2), threshold(:, :, 3)];
end

% Using Java.Util's ArrayDeque data structure for queue
import java.util.ArrayDeque
neighborList = ArrayDeque();
addedNeighborList = ArrayDeque();

% We first adding neighbors 
AddNeighbors(imageRowCount, imageColCount, seedRow, seedCol, neighborhoodType, neighborList, visitedMatrix);

while ~neighborList.isEmpty()
    
    %neighborListTemp = neighborList.clone();
    
    while ~neighborList.isEmpty()
        
        neighborData = neighborList.pop();
        
        neighborRow = neighborData(1);
        neighborCol = neighborData(2);
        
        if imageChannelCount > 1
            currentPixel = [ image(neighborRow, neighborCol, 1), image(neighborRow, neighborCol, 2), image(neighborRow, neighborCol, 3) ]; 
        else
            currentPixel = [ image(neighborRow, neighborCol) ];
        end
        
        if visitedMatrix(neighborRow, neighborCol) == 1
            continue;
        else
            visitedMatrix(neighborRow, neighborCol) = 1;
        end
        
        regionMean = mean(currentRegion);
        
        diff = abs( double(currentPixel) - double(regionMean) );
        
        if diff <= threshold
            
            currentRegion = [currentRegion; currentPixel];
            
            regionMatrix(neighborRow, neighborCol) = currentRegionLabel;
            
            addedNeighborList.add([neighborRow, neighborCol]);
            
        end
        
    end
    
    while ~addedNeighborList.isEmpty()
        
        addedNeighborData = addedNeighborList.pop();
        
        AddNeighbors(imageRowCount, imageColCount, addedNeighborData(1), addedNeighborData(2), neighborhoodType, neighborList, visitedMatrix);
        
    end
    
    if imageChannelCount > 1
                 threshold = 1.6503 * mean(std(double(currentRegion)));
%         threshold = 78;
    else
                 threshold =  1.6503 * std(double(currentRegion));
%         threshold = 78;
    end
    
end


currentRegionLabel = currentRegionLabel + 10;

end

% medfilt2(regionMatrix, [5 5]);

[ segmentedImage, binaryImage ] = ColorSegments(regionMatrix);
ele = [5 5];
segmentedImage(:, :, 1) = medfilt2(segmentedImage(:, :, 1), ele);

segmentedImage(:, :, 2) = medfilt2(segmentedImage(:, :, 2), ele);

segmentedImage(:, :, 3) = medfilt2(segmentedImage(:, :, 3), ele);

se = strel('disk', 3);

segmentedImage(:, :, 1) = imclose(segmentedImage(:, :, 1), se);
segmentedImage(:, :, 2) = imclose(segmentedImage(:, :, 2), se);
segmentedImage(:, :, 3) = imclose(segmentedImage(:, :, 3), se);
% 
% segmentedImage(:, :, 1) = imopen(segmentedImage(:, :, 1), se);
% segmentedImage(:, :, 2) = imopen(segmentedImage(:, :, 2), se);
% segmentedImage(:, :, 3) = imopen(segmentedImage(:, :, 3), se);

 binaryImage = medfilt2(binaryImage);
figure,
% subplot(1, 3, 1);
imshow(image);
% subplot(1, 3, 2);
figure,
imshow(segmentedImage);
% subplot(1, 3, 3);
figure,
imshow(binaryImage);

% display(regionMatrix);
% imagesc(regionMatrix);

end

