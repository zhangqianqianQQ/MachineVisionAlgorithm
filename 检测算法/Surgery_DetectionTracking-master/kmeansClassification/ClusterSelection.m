function [ goodClusters ] = ClusterSelection( clusters, image, s, w )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
height = length(image(:,1,1));
width = length(image(1,:,1));
discHeight = height/s;
discWidth = width/s;
numClusters = size(clusters,3);
windowClusters = zeros(discHeight,discWidth);
dists = zeros(1,numClusters);
boxedImage = OutlineRegion(image,ones(discHeight,discWidth));


for i=1:discHeight
    for j=1:discWidth
        hist = SimpleHist1D(image((i-1)*s+1:i*s,(j-1)*s+1:j*s,:),w);
        for k=1:numClusters
            dists(k) = Distance1D(hist,clusters(:,:,k));
        end
        [dist,windowClusters(i,j)] = min(dists); %#ok<ASGLU>
    end
end

display(windowClusters);
goodClusters = [];
response = '';

binaryImage = zeros(discHeight,discWidth);
for i=1:length(goodClusters)
    binaryImage = binaryImage + (windowClusters == goodClusters(i));
end
currentImage = DeleteWindowsImage(boxedImage,binaryImage);
imshow(currentImage);
    
while (not(strcmp(response,'done')))
    [x,y] = ginput(1);
    i = floor(y/s)+1;
    j = floor(x/s)+1;
    if (any(windowClusters(i,j)==goodClusters))
        goodClusters = goodClusters(goodClusters ~= windowClusters(i,j));
    else
        goodClusters = [goodClusters windowClusters(i,j)]; %#ok<AGROW>
        display(goodClusters);
    end
    binaryImage = zeros(discHeight,discWidth);
    for i=1:length(goodClusters)
        binaryImage = binaryImage + (windowClusters == goodClusters(i));
    end
    currentImage = DeleteWindowsImage(boxedImage,binaryImage);
    imshow(currentImage);
    response = input('more, or done?', 's');
end


end

