function denoise_function(fparams,dparams,iFrame,nframes,useOracle,iImages)
iDTemp = (dparams.iTemp-1)/2;
parfor ii=1:nframes-1
    tic
        if ((iFrame == -1) || (ii == iFrame)) 
           
            jjmin = max(ii-iDTemp,1);
           jjmax = min(ii+iDTemp,nframes-1);
           
            for  jj=jjmin:jjmax
                if (jj ~= ii) 
                    ComputeFlow(iImages,ii, jj, fparams,useOracle);
%                     WarpFrame(jj);
%                     GetOcclusionsMask(ii, jj, fparams); 
                 else 
                  
                    iwImages{ii} = iImages{ii}
                    if (useOracle)
                        awImages(ii) = aImages(ii);
                    mwImages(ii)=1.0;
                    end
                end
            end
        end
        disp("done with frame " + ii) 
        toc
end

end