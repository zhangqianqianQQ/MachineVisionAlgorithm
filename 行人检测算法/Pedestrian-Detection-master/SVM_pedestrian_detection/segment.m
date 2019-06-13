%%
function [bwfil] = segment ( img )
% segment an image into binary 1-0, 1 -- foreground  0 -- background
% eliminate the sliding window
% input - grayscale image
% output - binary image
img = preprocess(img);

mw = edge(img, 'Sobel', 0.1);

%clear borders
mw = imclearborder(mw);
se90 = strel('line', 3, 90);
se0 = strel('line', 3, 0);

bw = imdilate(mw, [se90 se0]);
bwfil = imfill(bw, 'holes');

bwfil = bwareaopen(bwfil, 30);

seD = strel('diamond', 1);
imshow(bwfil)
end

% mask = zeros(size(imx));
% mask(71:130,335:361) = 1;
% bw = activecontour(imx, mask, 100, 'edge');