function[pixCorrectHisto, pixTotalHisto] = evaluatePixAccHierarchy_loop(maxProbs, maxInds, overlapList, superPixelLabelHistos, pixCorrectHisto, pixTotalHisto)
% [pixCorrectHisto, pixTotalHisto] = evaluatePixAccHierarchy_loop(maxProbs, maxInds, overlapList, superPixelLabelHistos, pixCorrectHisto, pixTotalHisto)
%
% Slow version of inner loop in evaluatePixAccHierarchy.
% Use the mex version instead.
%
% Copyright by Holger Caesar, 2015

superPixelCount = size(overlapList, 2);

% Compute maximum over regions (that contain a superpixel) and count pixels
for superPixelIdx = 1 : superPixelCount,
    % Retrieve relevant regions that overlap with this superpixel and
    % find the one with the highest score
    relRegions = find(overlapList(:, superPixelIdx) == 1);
    [~, maxInd] = max(maxProbs(relRegions));
    spLabel = maxInds(relRegions(maxInd));
    spHisto = superPixelLabelHistos(:, superPixelIdx);
    
    % Increment correct and total pixel counts (per label)
    pixCorrectHisto(spLabel) = pixCorrectHisto(spLabel) + spHisto(spLabel);
    pixTotalHisto = pixTotalHisto + spHisto;
end;