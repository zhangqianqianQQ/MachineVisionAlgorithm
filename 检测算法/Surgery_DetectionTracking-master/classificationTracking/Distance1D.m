function [ out ] = Distance1D( hist1, hist2 )
%  Distance1D - Compute Distance between two RGB histograms by computing EMD distance for each color
%--------------------------------------------------------------------------
%   Params: hist1 - histogram 1
%           hist2 - histogram 2
%
%   Returns: out - the Earthmover's Distance between the two histograms.
%
%--------------------------------------------------------------------------

dR = EMD1D(hist1(:,1),hist2(:,1));
dG = EMD1D(hist1(:,2),hist2(:,2));
dB = EMD1D(hist1(:,3),hist2(:,3));

out = dR + dG + dB;

end
