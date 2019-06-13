function [edgeResponse, commonSize] = calculateGradientEdgeCost(edgeImg, labels,labelIndices, labOne, labTwo)
edgeResponse = 0;
commonSize = 0;
% Find common border..

[rC,cC] = size(labels);
temp = labelIndices{1,labOne};
rowArr = temp(:,1);
colArr = temp(:,2);
[realSize,~] = size(rowArr);

totalResp  = 0;
commonSize = 0;
for i=1:realSize
    xCor = rowArr(i,1);
    yCor = colArr(i,1);
    
    if xCor + 1 <= rC
        if labels(xCor+1,yCor) == labTwo % Common border!
            commonSize = commonSize + 1;
            totalResp = totalResp + abs(edgeImg(xCor,yCor)-edgeImg(xCor+1,yCor));
        end
    end
    
    if xCor - 1 > 0
         if labels(xCor-1,yCor) == labTwo % Common border!
            commonSize = commonSize + 1;
            totalResp = totalResp + abs(edgeImg(xCor,yCor) - edgeImg(xCor-1,yCor));
        end
    end
    
    if yCor + 1 <= cC
         if labels(xCor,yCor+1) == labTwo % Common border!
            commonSize = commonSize + 1;
            totalResp = totalResp + abs(edgeImg(xCor,yCor) - edgeImg(xCor,yCor+1));
        end
    end
    
    if yCor - 1 > 0
        if labels(xCor,yCor-1) == labTwo % Common border!
            commonSize = commonSize + 1;
            totalResp = totalResp + abs(edgeImg(xCor,yCor-1)-edgeImg(xCor,yCor) );
        end
    end
end

if commonSize ~=0
    edgeResponse = totalResp / commonSize;
end

end

