function [ centroids ] = Kmeans_update( data, centroids, assignments )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

for i = 1:size(centroids,3);
    pos = find(assignments == i);
    newCenter = zeros(size(centroids,1), size(centroids,2));
    for j = pos
        newCenter(:,:) = newCenter(:,:) + data(:,:,j);
    end
    newCenter = newCenter ./ length(pos);
    centroids(:,:,i) = newCenter;
end

end
