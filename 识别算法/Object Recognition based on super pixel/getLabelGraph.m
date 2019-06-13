function [graphG] = getLabelGraph(labels,labelCount)

allMatrix = zeros(labelCount, labelCount);
[rowCount,columnCount] = size(labels);

for r=1:rowCount-1
    for c=1:columnCount-1
        tmpCurr = labels(r,c);
        tmpNext = labels(r,c+1);
        
        if tmpCurr ~= tmpNext
            allMatrix(tmpCurr, tmpNext) = 1;
            allMatrix(tmpNext, tmpCurr) = 1;
        end
        
        tmpCurr = labels(r,c);
        tmpNext = labels(r+1,c);
        
        if tmpCurr ~= tmpNext
            allMatrix(tmpCurr, tmpNext) = 1;
            allMatrix(tmpNext, tmpCurr) = 1;
        end
    end
end

names = cell(labelCount,1);

for i=1:labelCount
    names{i} =  int2str(i);
end

graphG = graph(allMatrix);
graphG.Nodes.Name = names;
end

