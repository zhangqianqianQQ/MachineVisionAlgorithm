% BEWARE: TAKES QUITE A BIT TIME, ENJOY YOUR COFFEE WHILE RUNNING THIS LAD
% Takes labelGraph which is the graph obtained from getLabelGraph method.
% labelCount is the label count value. This method returns a distanceMatrix
% with labelCount x labelCount size. It's a symmetric matrix divided with
% diagonal zeros.
%

function [distanceMatrix] = getGraphDistance(labelGraph,labelCount)

distanceMatrix = zeros(labelCount,labelCount);

for i=1:labelCount
    for j=(1+i):labelCount
        if distanceMatrix(i,j) == 0
            path = shortestpath(labelGraph,i,j);
            [~,dist]=size(path);
            distanceMatrix(i,j) = dist;
            distanceMatrix(j,i) = dist;
        end
    end
end


