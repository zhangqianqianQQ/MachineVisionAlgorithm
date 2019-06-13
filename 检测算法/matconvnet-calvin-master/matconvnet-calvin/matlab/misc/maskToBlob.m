function[blob] = maskToBlob(iMask)
% [blob] = maskToBlob(mask)
%
% Convert a mask (of the whole image) to a blob (only the relevant region).
% See "help blob" for more information.
%
% Copyright by Holger Caesar, 2014

[pixelIndsY, pixelIndsX] = find(iMask == true);

minY = min(pixelIndsY);
maxY = max(pixelIndsY);
minX = min(pixelIndsX);
maxX = max(pixelIndsX);

sizeY = maxY - minY + 1;
sizeX = maxX - minX + 1;

rect = [minY, minX, maxY, maxX];
mask = false(sizeY, sizeX);
inds = sub2ind(size(mask), pixelIndsY-minY+1, pixelIndsX-minX+1);
mask(inds) = true;

% Create struct
blob.rect = rect;
blob.mask = mask;
blob.size = sum(mask(:));