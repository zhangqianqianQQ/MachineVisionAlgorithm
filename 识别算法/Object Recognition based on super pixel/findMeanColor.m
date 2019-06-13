function [meanCluster,pixelCount] = findMeanColor(img,labels,labelCount)

[rC,cC] = size(labels);

for i=1:labelCount
    meanCluster{1,i} = [0 0 0]; 
end

pixelCount = zeros(1,labelCount);

for r=1:rC
    for c=1:cC
        dataRed   = img(r,c,1) * 256;
        dataGreen = img(r,c,2) * 256;
        dataBlue  = img(r,c,3) * 256;
        labID = labels(r,c)+1;
        meanCluster{1,labID} = meanCluster{1,labID} + [dataRed dataGreen dataBlue];
        pixelCount(1,labID) = pixelCount(1,labID) + 1; 
    end
end

for i=1:labelCount
    meanCluster{1,i} = meanCluster{1,i} / pixelCount(1,i);
end

end

