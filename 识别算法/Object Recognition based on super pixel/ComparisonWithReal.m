function [done] = ComparisonWithReal(IMG,NAME)

figure;
imshow(IMG);
hold on;
tmpName = extractBefore(NAME,'.jpg');
PATH_REAL = "Data/" + tmpName + ".txt";
fileID = fopen(PATH_REAL{1},'r');
formatSpec = ' %d ';
BoundingData = fscanf(fileID,formatSpec);

[realObjectCount,~] = size(BoundingData);
realObjectCount = (realObjectCount - 1)/4;

paintcolor = [0 1 0];   %rGreen
for i=1:realObjectCount
    rtopX = BoundingData(1 + (4*(i-1)),1);
    rtopY = BoundingData(2 + (4*(i-1)),1);
    rlowX = BoundingData(3 + (4*(i-1)),1);
    rlowY = BoundingData(4 + (4*(i-1)),1);
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
    
    rectangle('Position', [rtopX, rtopY, realWidth, realHeight], 'EdgeColor', paintcolor,'LineWidth',0.4);
end
Image = getframe(gcf);
FILENAME = sprintf('%s%s%s',"detection_",tmpName, ".png");
imwrite(Image.cdata, FILENAME);

done = true;
end

