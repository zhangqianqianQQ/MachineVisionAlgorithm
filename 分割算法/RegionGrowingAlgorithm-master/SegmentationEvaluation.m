function [ sensitivity, specificity ] = SegmentationEvaluation( image, groundTruth, objectColor, backgroundColor )
%SEGMENTATIONEVALUATION Summary of this function goes here
%   https://en.wikipedia.org/wiki/Sensitivity_and_specificity

if size(image) ~= size(groundTruth)
    error('Images are not same size.');
end

[rows, cols] = size(image);

TP = 0; % True Positive
FP = 0; % False Positive
FN = 0; % False Negative
TN = 0; % True Negative

for ii = 1 : rows
    
    for jj = 1 : cols
        
        if image(ii, jj) == objectColor && groundTruth(ii, jj) == objectColor
            TP = TP + 1;
        elseif image(ii, jj) == objectColor && groundTruth(ii, jj) == backgroundColor
            FP = FP + 1;
        elseif image(ii, jj) == backgroundColor && groundTruth(ii, jj) == objectColor
            FN = FN + 1;
        elseif image(ii, jj) == backgroundColor && groundTruth(ii, jj) == backgroundColor
            TN = TN + 1;
        end
        
    end
    
end

    sensitivity = TP / (TP + FN);
    
    specificity = TN / (TN + FP);

end

