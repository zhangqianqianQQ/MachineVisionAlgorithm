function [ out ] = Score1D( hist, train )
%  Score1D - Compute score for histogram given training set by computing EMD distance
%  to each image histogram and inversely weighting distance.
%--------------------------------------------------------------------------
%   Params: hist - histogram to compare to training histograms
%           train - training histograms
%
%   Returns: out - the score of a histogram compared to training images
%
%--------------------------------------------------------------------------

out = 0;
q = length(train(1,1,:));
for i=1:q
    out = out + exp(-(Distance1D(hist, train(:,:,i)))^2/2); 
end

out = out ./ q;

end