function[blobSubY, blobSubX] = blobToImageSubs(blob)
% [blobSubY, blobSubX] = blobToImageSubs(blob)
%
% Convert a blob and an image to the indices of that blob in the image.
% These indices are relative to the size of the whole image. We don't need
% to know the image size for that!
% See "help blob" for more information.
%
% Copyright by Holger Caesar, 2014

% % For Matlab coder (not used)
% assert(isa(blob, 'struct'));
% assert(isa(blob.rect, 'double'));
% assert(all(size(blob.rect) == [1, 4]));
% assert(isa(blob.mask, 'logical'));
% assert(all(size(blob.mask) >= [1, 1]));
% assert(isa(blob.size, 'double'));
% assert(all(size(blob.size) == [1, 1]));

% Get all pix. coords for the mask
[blobSubY, blobSubX] = find(blob.mask);

% Make sure blobSub* are vectors (necessary when mask is a row vector)
blobSubY = blobSubY(:);
blobSubX = blobSubX(:);

% Translate from blob coords to image coords
blobSubY = blobSubY + blob.rect(1) - 1;
blobSubX = blobSubX + blob.rect(2) - 1;