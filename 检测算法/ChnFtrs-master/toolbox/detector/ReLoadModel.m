clear all
clc

load('.\models\AcfInriaDetector.mat');
f = fopen('.\models\DetectorData.dll','wb');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%write detector.opts
%detector.opts.pPyramid.pChns
fwrite(f,detector.opts.pPyramid.pChns.shrink,'int'); 
fwrite(f,detector.opts.pPyramid.pChns.pColor.enabled,'int'); 
fwrite(f,detector.opts.pPyramid.pChns.pColor.smooth,'int');
[h,w]=size(detector.opts.pPyramid.pChns.pColor.colorSpace);
fwrite(f,w,'int');
for i = 1:w
    fwrite(f,detector.opts.pPyramid.pChns.pColor.colorSpace(i),'char');
end

fwrite(f,detector.opts.pPyramid.pChns.pGradMag.enabled,'int'); 
fwrite(f,detector.opts.pPyramid.pChns.pGradMag.colorChn,'int'); 
fwrite(f,detector.opts.pPyramid.pChns.pGradMag.normRad,'int'); 
fwrite(f,detector.opts.pPyramid.pChns.pGradMag.normConst,'double');
fwrite(f,detector.opts.pPyramid.pChns.pGradMag.full,'int');

fwrite(f,detector.opts.pPyramid.pChns.pGradHist.enabled,'int'); 
%fwrite(f,detector.opts.pPyramid.pChns.pGradHist.binSize,'int'); 
fwrite(f,detector.opts.pPyramid.pChns.pGradHist.nOrients,'int'); 
fwrite(f,detector.opts.pPyramid.pChns.pGradHist.softBin,'int');
fwrite(f,detector.opts.pPyramid.pChns.pGradHist.useHog,'int');
fwrite(f,detector.opts.pPyramid.pChns.pGradHist.clipHog,'double');

%fwrite(f,detector.opts.pPyramid.pChns.pCustom.clipHog,'double');
fwrite(f,detector.opts.pPyramid.pChns.complete,'int');

%detector.opts.pPyramid.其它
fwrite(f,detector.opts.pPyramid.nPerOct,'int');
fwrite(f,detector.opts.pPyramid.nOctUp,'int');
fwrite(f,detector.opts.pPyramid.nApprox,'int');
[h,w]=size(detector.opts.pPyramid.lambdas);
fwrite(f,w,'int');
for i = 1:w
    fwrite(f,detector.opts.pPyramid.lambdas(i),'double');
end
fwrite(f,detector.opts.pPyramid.pad(1),'int');
fwrite(f,detector.opts.pPyramid.pad(2),'int');
fwrite(f,detector.opts.pPyramid.minDs(1),'int');
fwrite(f,detector.opts.pPyramid.minDs(2),'int');
fwrite(f,detector.opts.pPyramid.smooth,'int');
fwrite(f,detector.opts.pPyramid.concat,'int');
fwrite(f,detector.opts.pPyramid.complete,'int');

%detector.opts.其它
fwrite(f,detector.opts.modelDs(1),'int');
fwrite(f,detector.opts.modelDs(2),'int');
fwrite(f,detector.opts.modelDsPad(1),'int');
fwrite(f,detector.opts.modelDsPad(2),'int');
%%detector.opts.pNms
[h,w]=size(detector.opts.pNms.type);
fwrite(f,w,'int');
for i = 1:w
    fwrite(f,detector.opts.pNms.type(i),'char');
end

fwrite(f,detector.opts.pNms.overlap,'double');

[h,w]=size(detector.opts.pNms.ovrDnm);
fwrite(f,w,'int');
for i = 1:w
    fwrite(f,detector.opts.pNms.ovrDnm(i),'char');
end


%detector.opts.其它
fwrite(f,detector.opts.stride,'int');
fwrite(f,detector.opts.cascThr,'double');
fwrite(f,detector.opts.cascCal,'double');
[h,w]=size(detector.opts.nWeak);
fwrite(f,w,'int');
for i = 1:w
    fwrite(f,detector.opts.nWeak(i),'int');
end

%%detector.opts.pBoost
fwrite(f,detector.opts.pBoost.pTree.nBins,'int');
fwrite(f,detector.opts.pBoost.pTree.maxDepth,'int');
fwrite(f,detector.opts.pBoost.pTree.minWeight,'double');
fwrite(f,detector.opts.pBoost.pTree.fracFtrs,'double');
fwrite(f,detector.opts.pBoost.pTree.nThreads,'int');

fwrite(f,detector.opts.pBoost.nWeak,'int');
fwrite(f,detector.opts.pBoost.discrete,'int');
fwrite(f,detector.opts.pBoost.verbose,'int');

%detector.opts.其它
fwrite(f,detector.opts.seed,'int');
%fwrite(f,detector.opts.name,'char');
%fwrite(f,detector.opts.posGtDir,'char');
%fwrite(f,detector.opts.posImgDir,'char');
%fwrite(f,detector.opts.negImgDir,'char');
%fwrite(f,detector.opts.posWinDir,'char');
%fwrite(f,detector.opts.negWinDir,'char');
      %imreadf: @imread
      % imreadp: {}

%%detector.opts.pLoad
%%??????????

%detector.opts.其它
if isempty(detector.opts.nPos)
    detector.opts.nPos = 100;
end
fwrite(f,detector.opts.nPos,'int');
fwrite(f,detector.opts.nNeg,'int');
fwrite(f,detector.opts.nPerNeg,'int');
fwrite(f,detector.opts.nAccNeg,'int');

%%detector.opts.pJitter
fwrite(f,detector.opts.pJitter.flip,'int');

fwrite(f,detector.opts.winsSave,'int');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%write detector.opts



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%write detector.clf
[h,w]=size(detector.clf.fids);
fwrite(f,h,'int');
fwrite(f,w,'int');
for j = 1:w
  for i = 1:h
        fwrite(f,detector.clf.fids(i,j),'unsigned int');
  end
end

[h,w]=size(detector.clf.thrs);
fwrite(f,h,'int');
fwrite(f,w,'int');
 
for j = 1:w
        for i = 1:h
        fwrite(f,detector.clf.thrs(i,j),'float');
    end
end

[h,w]=size(detector.clf.child);
fwrite(f,h,'int');
fwrite(f,w,'int');
for j = 1:w
    for i = 1:h
        fwrite(f,detector.clf.child(i,j),'unsigned int');
    end
end

[h,w]=size(detector.clf.hs);
fwrite(f,h,'int');
fwrite(f,w,'int');
for j = 1:w
   for i = 1:h
        fwrite(f,detector.clf.hs(i,j),'float');
    end
end

[h,w]=size(detector.clf.weights);
fwrite(f,h,'int');
fwrite(f,w,'int');
for i = 1:h
    for j = 1:w
        fwrite(f,detector.clf.weights(i,j),'double');
    end
end

[h,w]=size(detector.clf.depth);
fwrite(f,h,'int');
fwrite(f,w,'int');
for i = 1:h
    for j = 1:w
        fwrite(f,detector.clf.depth(i,j),'unsigned int');
    end
end

[h,w]=size(detector.clf.errs);
fwrite(f,h,'int');
fwrite(f,w,'int');
for i = 1:h
    for j = 1:w
        fwrite(f,detector.clf.errs(i,j),'double');
    end
end

[h,w]=size(detector.clf.losses);
fwrite(f,h,'int');
fwrite(f,w,'int');
for i = 1:h
    for j = 1:w
        fwrite(f,detector.clf.losses(i,j),'double');
    end
end

 fwrite(f,detector.clf.treeDepth,'int');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%write detector.clf



fclose(f);

detector