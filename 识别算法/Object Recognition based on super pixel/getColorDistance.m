function colortextureDistance= getColorDistance(image, labels,colorHists, orientations, label1 , label2)   
    

    distanceColor = norm(colorHists{1,label1} - colorHists{1,label2},1);
   

    
    distanceTexture = norm((orientations{1,label1} - orientations{1,label2}),1);
    colortextureDistance = distanceColor + distanceTexture;
end

