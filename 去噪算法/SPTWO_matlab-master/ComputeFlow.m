function ComputeFlow(iImages,ii,  jj,fparams,useOracle)
tic
if(useOracle)
    aImages = iImages; 
   gray1 = rgb2gray(aImages{ii});
else
     gray1 = rgb2gray(iImages{ii});
   
end
if(useOracle)
    aImages = iImages; 
    gray2 = rgb2gray(aImages{jj});
   
else
    gray2 = rgb2gray(iImages{jj});
     imshow(gray2);
     title("frame number " + jj);
end
[width,height] = size(gray1);
     Dual_TVL1_optic_flow_multiscale(gray1,gray2,iImages{ii},iImages{jj},height,width,fparams);
     
toc
end
