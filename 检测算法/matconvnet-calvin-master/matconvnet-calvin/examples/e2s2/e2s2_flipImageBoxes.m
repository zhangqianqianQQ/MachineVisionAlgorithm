function[image, boxes, blobMasks] = e2s2_flipImageBoxes(image, boxes, oriImSize, blobMasks)
% [image, boxes, blobMasks] = e2s2_flipImageBoxes(image, boxes, oriImSize, blobMasks)
%
% Flip the batch (image, blobs, masks) along the vertical axis.
%
% Copyright by Holger Caesar, 2015

image = fliplr(image);
boxes = [...
    boxes(:, 1), ...
    oriImSize(2) - boxes(:, 4) + 1, ...
    boxes(:, 3), ...
    oriImSize(2) - boxes(:, 2) + 1, ...
    ];
if exist('blobMasks', 'var'),
    blobMasks = cellfun(@(x) fliplr(x), blobMasks, 'UniformOutput', false);
end;

assert(all(boxes(:, 1) <= boxes(:, 3)));
assert(all(boxes(:, 2) <= boxes(:, 4)));