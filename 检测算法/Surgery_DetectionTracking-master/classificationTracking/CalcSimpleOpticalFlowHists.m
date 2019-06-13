function [ newPositions, zerosInARow ] = CalcSimpleOpticalFlowHists( centroids, img1, train, neighborSize, windowSize, w, thresh, zerosInARow)
%  calcSimpleOpticalFlowHists - Used to track object of interest
%--------------------------------------------------------------------------
%   Params: centroids: n x 3 matrix where n is the number of centroids showing
%           img1: image to be looked at for new centroid position
%           train: training histograms
%           neighborSize: size of neighborhood to look at.  Should be odd
%           windowSize: size of windows in centroid neighborhood
%           w - the width of the bins for the RGB color
%               histograms
%           thresh: distance threshold
%           zerosInARow: zeros in a row
%
%   Returns: newPositions - new positions of centroid.  0 for x and y of 
%               centroid if its out of view bounds or doesn't
%               have a good enough match in the view
%            zerosInARow - number of frames straight where zeros
%               detected
%
%   Assumes: brightness constant, small motion changes betw frames
%--------------------------------------------------------------------------

newPositions = zeros(size(centroids,1), size(centroids,2));
imgWidth = size(img1,2);
imgHeight = size(img1,1);
for i = 1:size(centroids,1)
    currCentr = centroids(i,:);
    row = currCentr(1);
    col = currCentr(2);
%     if useOrigColor == 1
%         pixRef = [currCentr(4) currCentr(5) currCentr(6)]';
%     else
%         pixRef = double(refImg(row,col,:));
%         pixRef = pixRef(:);
%     end
    indent = floor(neighborSize / 2);
    bestDist = 0;
    for kRow = -indent:indent
        for kCol = -indent:indent
            testRow = max(1, row + kRow);
            testRow = min(imgHeight, testRow);
            testCol = max(1, col + kCol);
            testCol = min(imgWidth, testCol);
            hist = SimpleHist1D(img1(max(1,testRow - windowSize):min(imgHeight, testRow + windowSize),...
                max(1,testCol- windowSize):min(imgWidth, testCol + windowSize)...
                ,:), w);
            dist = Score1D(hist, train);
            %prefer points closer to old centroid so put penalty
            manhDist2center = (abs(testRow - centroids(i,1)) + ...
              abs(testCol - centroids(i,2))) / 2;
            %good vals is - 15, - 20, 
            if (dist > exp(thresh - 25 + manhDist2center))
                if (dist > bestDist)
                    newPositions(i,1) = testRow;
                    newPositions(i,2) = testCol;
                    bestDist = dist;
                end
            end
        end
    end
    if (newPositions(i,1) == 0)
        zerosInARow = zerosInARow + 1;
        if (zerosInARow <= 15)
            newPositions(i,1) = centroids(i,1);
            newPositions(i,2) = centroids(i,2);
        end
    else
        zerosInARow = 0;
    end
    %newPositions
end

end

