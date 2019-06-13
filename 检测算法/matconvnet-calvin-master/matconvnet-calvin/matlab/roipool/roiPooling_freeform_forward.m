function[rois, masks] = roiPooling_freeform_forward(rois, masks, blobMasks, combineFgBox)
% [rois, masks] = roiPooling_freeform_forward(rois, masks, blobMasks, combineFgBox)
%
% Freeform pooling forward pass.
%
% This is an extension to the roiPool layer and MUST come after it in a
% network. It applies a each blob's freeform mask to the activations and
% masks of roi pooling.
%
% Depending on the options, it either keeps the entire box, just the
% foreground or both.
%
% Copyright by Holger Caesar, 2015

% Store a copy of the box features if we still need them
if combineFgBox,
    roisBox = rois;
    masksBox = masks;
end;

% Perform freeform pooling and update mask for backpropagation
assert(numel(blobMasks) == size(rois, 4));
blobMasksMat = cat(4, blobMasks{:});
blobMasksNanMat = double(~blobMasksMat);
blobMasksNanMat(blobMasksNanMat(:) == 0) = nan;
rois  = bsxfun(@times, rois,  blobMasksMat);
masks = bsxfun(@times, masks, blobMasksNanMat);

% Debug: To visualize each blob (requires an update)
% figure(1); imagesc(blobMaskOri); figure(2); imagesc(blobMask); nonEmptyChannel = maxInd(squeeze(sum(sum(rois(:, :, :, blobIdx), 1), 2))); figure(3); imagesc(rois(:, :, nonEmptyChannel, blobIdx)); figure(4); imagesc(masks(:, :, nonEmptyChannel, blobIdx))

% Concatenate fg and box
if combineFgBox,
    rois  = cat(3, rois, roisBox);
    masks = cat(3, masks, masksBox);
end;