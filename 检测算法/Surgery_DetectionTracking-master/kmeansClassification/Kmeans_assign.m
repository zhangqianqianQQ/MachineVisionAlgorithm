function [ assignments ] = Kmeans_assign( data, centroids )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
N = length(data(1,1,:));
K = length(centroids(1,1,:));
distances = zeros(1,K);
assignments = zeros(1,N);

for i=1:N
    for j=1:K
        distances(j) = Distance1D(data(:,:,i),centroids(:,:,j));
    end
    poss = find(distances == min(distances));
    assignments(i) = poss(1);
end

end

