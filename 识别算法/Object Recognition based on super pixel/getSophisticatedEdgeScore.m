function [outputScore] = getSophisticatedEdgeScore(edgeImg, labels, labelIndices, spSet)

[~,labelCount] = size(spSet);
k = 0.4;
totalSize = 0;
edgeCount = 0;
for i=1:labelCount
    tmpLabel = spSet(1,i);
    locations = labelIndices{1,tmpLabel};
    [pixelSize,~] = size(locations);
    totalSize = totalSize + pixelSize;
    
    for a=1:pixelSize
        if edgeImg(locations(a,1),locations(a,2)) > 0
            edgeCount = edgeCount + 1;
        end
    end
end


outputScore = edgeCount / ((totalSize).^k);
end

