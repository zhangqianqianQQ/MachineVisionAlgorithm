function [ segmentedImage, binaryImage ] = ColorSegments( regionMatrix )
%COLORSEGMENTS Summary of this function goes here
%   Detailed explanation goes here

uniqueRegionLabels = unique(regionMatrix);
uniqueRegionLabelCount = numel(uniqueRegionLabels);

labelColors = [];

for ii = 1 : uniqueRegionLabelCount
    
    rValue = randi(255);
    
    gValue = randi(255);
    
    bValue = randi(255);
    
    labelColors = [labelColors; rValue gValue bValue];
end

frequentLabel = mode(mode(regionMatrix));

[rows, cols] = size(regionMatrix);

segmentedImage = uint8(zeros(rows, cols, 3));

binaryImage = uint8(zeros(rows, cols, 1));

for ii = 1 : rows
    
    for jj = 1 : cols
        
        regionLabel = regionMatrix(ii, jj);
        
        colorIndex = find(uniqueRegionLabels == regionLabel);
        
        segmentedImage(ii, jj, 1) = labelColors(colorIndex, 1);
        
        segmentedImage(ii, jj, 2) = labelColors(colorIndex, 2);
        
        segmentedImage(ii, jj, 3) = labelColors(colorIndex, 3);
        
        if regionLabel == frequentLabel
            binaryImage(ii, jj) = 0;
        else
            binaryImage(ii, jj) = 255;
        end
        
    end
    
end




end

