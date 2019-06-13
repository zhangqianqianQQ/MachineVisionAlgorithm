function lcd = getLowComplexityDistance(image,labels,graphDistances,colorHists,gradient,labelSet1,labelSet2,edgeImg , labelIndices)
Dmax = -Inf;
Dg = Inf;
De = 0;

lsum = 0;
for i = labelSet1
    for j = labelSet2
        Dmax = max(Dmax, getColorDistance(image,labels,colorHists,gradient,i,j));
        Dg = min(Dg, graphDistances(i,j));
        [de, l] = calculateGradientEdgeCost(edgeImg, labels, labelIndices, i,j);
        lsum = l + lsum;
        De = De + l * de;
    end
end

if(lsum == 0)
    De = 0;
else
    De = De/lsum;
end

lcd = Dg + Dmax + De;


end

