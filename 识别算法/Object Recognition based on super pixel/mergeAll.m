function [sets , scores] = mergeAll(I,labels,numlabels,iterationCount)

    graph = getLabelGraph(labels, numlabels+1);
    
    
    graphDistances= getGraphDistance(graph,numlabels);
    
    labelIndices = cell(1,numlabels);
    for i = 1:numlabels
        [row,col] = find(labels == i);
        labelIndices{1,i} = [row,col];
    end
    

    %GET GRADIENT OF IMAGE FOR COLOR-TEXTURE DISTANCE
    sigma = 0.5;

    Wx = floor((5/2)*sigma); 
    if Wx < 1
      Wx = 1;
    end
    x = -Wx:Wx;

    % Evaluate 1D Gaussian filter (and its derivative).
    g = exp(-(x.^2)/(2*sigma^2));
    gp = -(x/sigma).*exp(-(x.^2)/(2*sigma^2));

    gradient = cell(2,3);

    gradient{1,1} = convolve2(convolve2(I(:,:,1),-gp,'same'),g','same');
    gradient{2,1} = convolve2(convolve2(I(:,:,1),g,'same'),-gp','same');

    gradient{1,2}= convolve2(convolve2(I(:,:,2),-gp,'same'),g','same');
    gradient{2,2} = convolve2(convolve2(I(:,:,2),g,'same'),-gp','same');

    gradient{1,3} = convolve2(convolve2(I(:,:,3),-gp,'same'),g','same');
    gradient{2,3} = convolve2(convolve2(I(:,:,3),g,'same'),-gp','same');

    irfx = gradient{1,1};
    irfy = gradient{2,1};
    
    igfx = gradient{1,2};
    igfy = gradient{2,2};
    
    ibfx = gradient{1,3};
    ibfy = gradient{2,3};
    
    %%%%%%%%

    orientations = cell(3,8);
    i = 1;
    for angle = 0:45:315
        orientations{1,i} = cos(angle*(pi/180))*irfx+sin(angle*(pi/180))*irfy;
        orientations{2,i} = cos(angle*(pi/180))*igfx+sin(angle*(pi/180))*igfy;
        orientations{3,i} = cos(angle*(pi/180))*ibfx+sin(angle*(pi/180))*ibfy;
        i = i + 1;
    end
    
    edges = -25:5:25;
    oHists = cell(numlabels,3,8);

    
    for l = 1:numlabels
        for o = 1:8
            for color = 1:3
                oHists{l,color, o} = histcounts(orientations{1,o}(labels == l),edges);
                oHists{l,color,o} = oHists{l,color, o} / sum(oHists{l,color, o});
            end
        end
    end
    
    ohists = cell(1,numlabels);
   
    
    for l = 1:numlabels
        ohists{1,numlabels} = zeros(24,10);
        for i = 1:8
            for j = 1:3
                for k = 1:10
                    ohists{1,l}((i-1) * 3 + j ,k) = oHists{l,j,i}(1,k);
                end
            end
        end
    end

    
    
    %GET COLOR HISTOGRAMS
    
    colorHists = cell(1,numlabels);
    
for l = 1:numlabels 
    
    [row1,col1] = find(labels == l);
    edges = 0:1/20:1;
    
   
    rc1 = cat(2, row1,col1);

    
    
    ir1 = zeros(size(rc1,1) ,1);
    ig1 = zeros(size(rc1,1) ,1);
    ib1 = zeros(size(rc1,1), 1);
   
    
    
    for i = 1:size(rc1,1)
        ir1(i,1) = I(rc1(i,1),rc1(i,2) ,1);
        ig1(i,1) = I(rc1(i,1),rc1(i,2) ,2);
        ib1(i,1) = I(rc1(i,1),rc1(i,2) ,3);
    end
     
    
    r1 = histcounts(ir1,edges);
    r1= r1 / sum(r1);
    g1 = histcounts(ig1,edges);
    g1= g1 / sum(g1);
    b1 = histcounts(ib1,edges);
    b1= b1 / sum(b1);
    
    colorHists{1,l} = cat(1, r1 , g1 , b1);
    
    sets = cell(1,numlabels);
    
    for i = 1:numlabels
        sets{1,i} = i;
    end

    
end   

 edgeImg = edge(rgb2gray(I),'Prewitt');
%[edgeImg, ~] = imgradient(rgb2gray(I),'prewitt');
  
scores = cell(1,2);
scoreCount = 1;
    
for i = 1:iterationCount
    [sets, lastMerged,~] = mergePixels(I,edgeImg, labels ,numlabels , graphDistances ,colorHists, ohists , sets , labelIndices);
    %score = scoreSet(edgeImg, labels, numlabels,lastMerged , labelIndices);
    score = getSophisticatedEdgeScore(edgeImg, labels, labelIndices, lastMerged);
    fprintf("Score: %f \n" , score);
    if(score > 0)
        scores{1,1}(1,scoreCount) = score;
        scores{1,2}{1,scoreCount} = lastMerged;
        scoreCount = scoreCount + 1;
    end
end

end

