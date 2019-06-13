function[overlaps] = computeBlobOverlapSum(propBlobsA, propBlobsB, imageSize)
% [overlaps] = computeBlobOverlapSum(propBlobsA, propBlobsB, imageSize)
%
% Take Sel. Search regions and reconstruct which regions overlap by how many pixels.
% (result is a matrix)
%
% Copyright by Holger Caesar, 2015

if numel(imageSize) == 3,
    imageSize = imageSize(1:2);
end;
propCountA = numel(propBlobsA);
propCountB = numel(propBlobsB);
overlaps = zeros(propCountA, propCountB); %Dense is fine

% Precompute blob inds
blobsIndsA = cell(propCountA, 1);
for i = 1 : propCountA,
    blob = propBlobsA(i);
    blobsIndsA{i} = blobToImageInds(blob, imageSize);
end;

blobsIndsB = cell(propCountB, 1);
for i = 1 : propCountB,
    blob = propBlobsB(i);
    blobsIndsB{i} = blobToImageInds(blob, imageSize);
end;

for i = 1 : propCountA,
    for j = 1 : propCountB,
        % Compute the intersection / union
        % (Faster than ismember())
        overlaps(i, j) = sum(builtin('_ismemberhelper', blobsIndsA{i}, blobsIndsB{j}));
%         assert(overlap == sum(ismember(blobsIndsA{i}, blobsIndsB{j})));
%         assert(sum(ismember(blobsIndsA{i}, blobsIndsB{j})) == sum(ismember(blobsIndsA{j}, blobsIndsB{i})));
    end;
end;