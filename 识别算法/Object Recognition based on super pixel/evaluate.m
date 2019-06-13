function [precision,recall] = evaluate(NAME,boundingBoxes, threshold)
tmpName = extractBefore(NAME,'.jpg');
PATH_REAL = "Data/" + tmpName + ".txt";
fileID = fopen(PATH_REAL{1},'r');
formatSpec = ' %d ';
BoundingData = fscanf(fileID,formatSpec);

[realObjectCount,~] = size(BoundingData);
realObjectCount = (realObjectCount - 1)/4;
correctObjects  = 0;
[~,detectedCount] = size(boundingBoxes);

for i=1:detectedCount
    ourBox = boundingBoxes{1,i};
    topX = ourBox(1,1);
    topY = ourBox(1,2);
    lowX = ourBox(1,3);
    lowY = ourBox(1,4);
    for b=1:realObjectCount
        rtopX = BoundingData(1 + (4*(b-1)),1);
        rtopY = BoundingData(2 + (4*(b-1)),1);
        rlowX = BoundingData(3 + (4*(b-1)),1);
        rlowY = BoundingData(4 + (4*(b-1)),1);
        width = 0;
        if lowX > topX
            width =  lowX-topX;
        else
             width =  topX-lowX;
        end
        height = 0;
        if lowY > topY
            height =  lowY-topY ;
        else
             height =  topY-lowY;
        end
        
        realWidth = 0;
        if rlowX > rtopX
            realWidth =  rlowX-rtopX;
        else
             realWidth =  rtopX-rlowX;
        end
        realHeight = 0;
        if rlowY > rtopY
            realHeight =   rlowY-rtopY ;
        else
             realHeight =  rtopY-rlowY;
        end
        
        ourBox  = [ topX,   topY, width ,height  ];
        realBox = [ rtopX, rtopY,realWidth ,realHeight];
        overlapRatio = bboxOverlapRatio(ourBox,realBox);
        if overlapRatio > threshold
            correctObjects = correctObjects + 1;
            break;
        end
    end
end


recall = correctObjects /realObjectCount ;
precision = correctObjects /detectedCount ;
end

