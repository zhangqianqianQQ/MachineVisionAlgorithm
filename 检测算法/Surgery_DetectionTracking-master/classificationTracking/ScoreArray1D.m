function [ out ] = ScoreArray1D( histArray, train, thresh )
%  Score1D - Compute score for histogram given training set by computing EMD distance
%  to each image histogram and inversely weighting distance.
%--------------------------------------------------------------------------
%   Params: hist - histogram to compare to training histograms
%           train - training histograms
%           thresh - the distance threshold cutoff
%
%   Returns: out - binary score video
%
%--------------------------------------------------------------------------
height = length(histArray(1,1,:,1));
width = length(histArray(1,1,1,:));
out = false(height,width);

for X = 1:width
    for Y = 1:height
        out(Y,X) = (Score1D(histArray(:,:,Y,X),train) > exp(thresh));
    end
end

end