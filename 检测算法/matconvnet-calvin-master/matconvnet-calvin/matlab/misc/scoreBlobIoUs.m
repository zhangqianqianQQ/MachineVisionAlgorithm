function[ious] = scoreBlobIoUs(blobsA, blobsB)
% [ious] = scoreBlobIoUs(blobsA, blobsB)
%
% Score the intersection over union for each combination of blobs in a and b
%
% Copyright by Holger Caesar, 2014

% % Matlab Coder (no significant speedups)
% assert(isstruct(blobsA));
% assert(size(blobsA, 2) == 1);
% assert(isa(blobsA(1).rect, 'double'));
% assert(isa(blobsA(1).mask, 'logical'));
% assert(isa(blobsA(1).size, 'double'));
% assert(size(blobsA(1).rect, 2) == 4);
% assert(size(blobsA(1).mask, 1) >= 1);
% assert(size(blobsA(1).mask, 2) >= 1);
% 
% assert(isstruct(blobsB));
% assert(size(blobsB, 2) == 1);
% assert(isa(blobsB(1).rect, 'double'));
% assert(isa(blobsB(1).mask, 'logical'));
% assert(isa(blobsB(1).size, 'double'));
% assert(size(blobsB(1).rect, 2) == 4);
% assert(size(blobsB(1).mask, 1) >= 1);
% assert(size(blobsB(1).mask, 2) >= 1);

% Init
nA = numel(blobsA);
nB = numel(blobsB);
ious = zeros(nA, nB);

for aIdx = 1 : nA,
    for bIdx = 1 : nB,
        
        blobA = blobsA(aIdx);
        blobB = blobsB(bIdx);
        
        aRect = blobA.rect;
        bRect = blobB.rect;
        
        if isBoxIntersect(aRect, bRect),
            % If both boxes intersect, compute the IoU
            intersectionRect = [max(aRect(1:2), bRect(1:2)), min(aRect(3:4), bRect(3:4))];
            
            aMaskCutRect = [intersectionRect(1:2) - aRect(1:2) + 1, intersectionRect(3:4) - aRect(1:2) + 1];
            bMaskCutRect = [intersectionRect(1:2) - bRect(1:2) + 1, intersectionRect(3:4) - bRect(1:2) + 1];
            
            aMaskCut = blobA.mask(aMaskCutRect(1):aMaskCutRect(3), aMaskCutRect(2):aMaskCutRect(4));
            bMaskCut = blobB.mask(bMaskCutRect(1):bMaskCutRect(3), bMaskCutRect(2):bMaskCutRect(4));
            
            intersection = sum(aMaskCut(:) & bMaskCut(:));
            union = blobA.size + blobB.size - intersection;
            iou = intersection / union;
        else
            % If there is no intersection, set IoU to 0
            iou = 0;
        end;
        
        % Save iou
        ious(aIdx, bIdx) = iou;
    end;
end;