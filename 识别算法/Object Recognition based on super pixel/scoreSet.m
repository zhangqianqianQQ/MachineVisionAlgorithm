function score = scoreSet(edgeImg, labels, numlabels,labelSet , labelIndices)

k = 0.7;
totalCost = 0;
lsum = 0;

for i = labelSet
    for j = 1:numlabels
        if(isempty(find(labelSet == j, 1)))
            [de , l] = calculateGradientEdgeCost(edgeImg, labels,labelIndices, i, j);
            lsum = lsum + l;
            totalCost = totalCost + double(de*l);
        end
    end
end



score = totalCost / (lsum.^k);

end