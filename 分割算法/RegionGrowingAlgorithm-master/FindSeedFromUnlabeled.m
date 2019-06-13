function [seedRow, seedCol] = FindSeedFromUnlabeled( regionMatrix )
%FINDSEEDFROMUNLABELED Summary of this function goes here
%   Detailed explanation goes here

[seedRow, seedCol] = find(regionMatrix == 0, 1);

end

