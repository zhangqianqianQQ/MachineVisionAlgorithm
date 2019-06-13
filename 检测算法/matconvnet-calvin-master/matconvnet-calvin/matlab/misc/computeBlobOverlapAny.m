function[overlap] = computeBlobOverlapAny(propBlobsA, propBlobsB, imageSize)
% [overlap] = computeBlobOverlapAny(propBlobsA, propBlobsB, imageSize)
%
% Take Sel. Search regions and reconstruct whether blobs overlap at all.
% (result is a matrix).
%
% Copyright by Holger Caesar, 2015

if numel(imageSize) == 3,
    imageSize = imageSize(1:2);
end;
propCountA = numel(propBlobsA);
propCountB = numel(propBlobsB);

% Precompute blob inds
blobsIndsA = cell(propCountA, 1);
blobsIndsB = cell(propCountB, 1);
for i = 1 : propCountA,
    blob = propBlobsA(i);
    blobsIndsA{i} = int32(blobToImageInds(blob, imageSize));
end;
if isequal(propBlobsA, propBlobsB),
    blobsIndsB = blobsIndsA;
else
    for i = 1 : propCountB,
        blob = propBlobsB(i);
        blobsIndsB{i} = int32(blobToImageInds(blob, imageSize));
    end;
end;

overlap = computeBlobOverlapAnyPair(blobsIndsA, blobsIndsB); % Mex-version is 6 times faster for Barcelona dataset


% function[overlap] = computeBlobOverlapAnyPair(blobsIndsA, blobsIndsB) %#ok<DEFNU>
% % [overlap] = computeBlobOverlapAnyPair(blobsIndsA, blobsIndsB)
% %
% % Compute if two blobs overlap at all (boolean).
% % To be replaced by a mex function.
% 
% % Initialize
% propCountA = numel(blobsIndsA);
% propCountB = numel(blobsIndsB);
% overlap = zeros(propCountA, propCountB); %Dense is fine
% 
% for i = 1 : propCountA,
%     for j = 1 : propCountB,
%         overlap(i, j) = any(builtin('_ismemberhelper', blobsIndsA{i}, blobsIndsB{j}));
%     end;
% end;