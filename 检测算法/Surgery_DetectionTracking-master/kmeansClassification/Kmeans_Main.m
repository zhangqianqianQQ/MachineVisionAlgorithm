function [ out, centroidOfInterestIndex ] = Kmeans_Main( vidPath, imPath, s, w )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

image = imread(imPath);
centroids = GetStartingCluster(image, s, w );
k = size(centroids,3);
display('[INFO] Reading Videos');
videoHistograms = VideoToHistogramList( vidPath, s, w );

maxIterations = 200;
epsilon = 0.05;
dists = zeros(1,k);

display('[INFO] Running k means');
for i = 1:maxIterations
    display(strcat('-----------Iteration:', num2str(i),'-------------------'));
    assignments = Kmeans_assign( videoHistograms, centroids );
    centroidsNew = Kmeans_update( videoHistograms, centroids, assignments );
    for j=1:k
        dists(j) = Distance1D(centroids(:,:,j),centroidsNew(:,:,j));
    end
    dist = norm(dists);
    display(dist);
    if (dist < epsilon)
        centroids = centroidsNew;
        break;
    else
        centroids = centroidsNew;
    end
end

display(dist);
out = centroids;

%Now ask user where the object they want to classify is located to find
%which centroid is closest to that object
height = size(image,1);
width = size(image,2);
boxes = ones(height/s,width/s);
imshow(OutlineRegion(image,boxes));
[x,y] = ginput(1);
i = floor(y/s)+1;
j = floor(x/s)+1;
histObjectInterest = SimpleHist1D(image((i-1)*s+1:i*s,(j-1)*s+1:j*s,:),w);

for j=1:k
    dists(j) = Distance1D(centroids(:,:,j),histObjectInterest);
end

[minVal, centroidOfInterestIndex] = min(dists);

end

