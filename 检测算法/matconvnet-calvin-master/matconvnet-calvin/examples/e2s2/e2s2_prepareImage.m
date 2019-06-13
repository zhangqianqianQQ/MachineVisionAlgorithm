function[image, oriImSize] = e2s2_prepareImage(net, image, maxImageSize)
% [image, oriImSize] = e2s2_prepareImage(net, image, maxImageSize)
%
% Resize the image and subtract the mean image.
%
% Copyright by Holger Caesar, 2015

% Resize image
oriImSize = size(image);
resizeFactor = maxImageSize / max(oriImSize(1:2));
targetSize = ceil(oriImSize(1:2) .* resizeFactor); % ceil corresponds to Matlab's imresize behavior
image = imresize(image, resizeFactor);
assert(size(image, 1) == targetSize(1) && size(image, 2) == targetSize(2));

if numel(net.meta.normalization.averageImage) == 3,
    % Subtract fixed number from each channel
    image(:, :, 1) = image(:, :, 1) - net.meta.normalization.averageImage(1);
    image(:, :, 2) = image(:, :, 2) - net.meta.normalization.averageImage(2);
    image(:, :, 3) = image(:, :, 3) - net.meta.normalization.averageImage(3);
else
    % Resize averageImage and subtract it from each image
    % Note: This cannot be done on the gpu as Matlab's gpu-compatible
    % imresize function can only resize by a constant factor and the image
    % might not be square.
    averageImage = net.meta.normalization.averageImage ./ 255;
    averageImage = imresize(averageImage, targetSize);
    image = image - averageImage;
end;