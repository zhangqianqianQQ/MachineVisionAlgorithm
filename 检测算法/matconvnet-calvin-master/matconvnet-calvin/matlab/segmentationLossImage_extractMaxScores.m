function[scoresImageSoftmax, mask] = segmentationLossImage_extractMaxScores(obj, labelCount, sampleCount, imageCount, masksThingsCell)
% [scoresImageSoftmax, mask] = segmentationLossImage_extractMaxScores(obj, labelCount, sampleCount, imageCount, [masksThingsCell])
%
% Inner loop of the SegmentationLossImage layer.
%
% Copyright by Holger Caesar, 2016

% Init
scoresImageSoftmax = nan(1, 1, labelCount, sampleCount, 'like', obj.scoresMapSoftmax);
mask = nan(sampleCount, 1, 'like', obj.scoresMapSoftmax); % contains the coordinates of the pixel with highest score per class

% Process each image/crop separately % very slow (!!)
for imageIdx = 1 : imageCount
    offset = (imageIdx-1) * labelCount;
    
    if ~isempty(masksThingsCell) && ~isempty(masksThingsCell{imageIdx})
        maskThings = masksThingsCell{imageIdx};
        if isa(obj.scoresMapSoftmax, 'gpuArray')
            maskThings = gpuArray(maskThings);
        end
    end
    
    for labelIdx = 1 : labelCount
        sampleIdx = offset + labelIdx;
        
        if obj.useScoreDiffs
            % Use pixel with highest score compared to all other labels
            s = obj.scoresMapSoftmax(:, :, labelIdx, imageIdx) - max(obj.scoresMapSoftmax(:, :, setdiff(1:labelCount, labelIdx), imageIdx), [], 3);
        else
            % Use pixel with overall highest score
            s = obj.scoresMapSoftmax(:, :, labelIdx, imageIdx);
        end
        
        % Remove things such that the highest score lies on stuff
        if ~isempty(masksThingsCell) && ~isempty(masksThingsCell{imageIdx})
            s = bsxfun(@times, s, ~maskThings);
        end
        
        [~, ind] = max(s(:)); % always take first pix with max score
        mask(sampleIdx, 1) = ind;
        [y, x] = ind2sub(size(s), ind);
        scoresImageSoftmax(1, 1, :, sampleIdx) = obj.scoresMapSoftmax(y, x, :, imageIdx);
    end
end