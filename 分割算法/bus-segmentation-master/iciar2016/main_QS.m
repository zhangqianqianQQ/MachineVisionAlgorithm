clc;close all;clear all; warning('off','all');
addpath(genpath('./Libs'));
run('C:\MATLAB_libs\vlfeat\vlfeat-0.9.20\toolbox\vl_setup');
%%
% NC-FR , NC-PPB_NoItr , NC-DPAD
method = 'QS-DPAD-UDIAT'; %-UDIAT
inputPath = './data/Input/';
gtPath = './data/GT/';
outputPath = ['./results/' method '/'];
matPath = ['./mat/' method '.mat'];
fileList = getAllFiles(inputPath,'*.png');
if exist(outputPath, 'dir')
    rmdir(outputPath,'s');
end
mkdir(outputPath);


for i=1:numel(fileList)
    file = fileList{i};
    [~,name,ext] = fileparts(file);
    disp(['File #' num2str(i) ' of ' num2str(numel(fileList)) ...
        ' Processing ... ' file]);
    
    img = im2double(imread(file));
    imgSize(i) = numel(img);
    figure('Visible', 'off'); imshow(img,[]);
    saveas(gcf,[outputPath name '_0Input.jpg']); close;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%% Preprocessing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %-Adjust image intensity values
    img = imadjust(img);
    figure('Visible', 'off'); imshow(img,[]);
    saveas(gcf,[outputPath name '_1Pre1.jpg']); close;
    
    %-Inverse pixel values of input image 
    img = imcomplement(img);
    figure('Visible', 'off'); imshow(img,[]); 
    saveas(gcf,[outputPath name '_1Pre2.jpg']); close;
    
    %%% Image smoothing process
    
    %-DPAD
    stepsize = 0.2;
    nosteps = 100;
    wnSize = 5;
    img_DPAD =  dpad(img, stepsize, nosteps,'cnoise',wnSize,'big',wnSize,'aja');
    
%     %-PPB_NoItr
%     L = 1;
%     hW = 23;
%     hD = 7;
%     alpha = 0.92;
%     T = 0.2;
%     nbit = 4;
%     img = ppb_nakagami(img, L, hW, hD, alpha, T, nbit);
    
%     %-Frost filter
%     M_Radius = 3;
%     img = fcnFrostFilter(img,getnhood(strel('disk',M_Radius)));
    
    figure('Visible', 'off'); imshow(img,[]); 
    saveas(gcf,[outputPath name '_1Pre3.jpg']); close;
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%% Segmentation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %-Apply Quick Shift (QS) as segementation candidate 
    ratio = 0.8;
    kernelsize = 5;
    maxdist = 20;
    Iseg = vl_quickseg(img, ratio, kernelsize, maxdist);
    figure('Visible', 'off'); imshow(Iseg,[]); 
    saveas(gcf,[outputPath name '_2Seg.jpg']); close;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%% Postprocessing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %-Convert segemented (gray-scale) image into binary image by one-point
    %-thresholding using some scalar value after unit normalization
    IBW = (normalise(Iseg) >= 0.8);
    figure('Visible', 'off'); imshow(IBW,[]); 
    saveas(gcf,[outputPath name '_3Post1.jpg']); close;
    
    %-Remove boundary regions
    IBW = imclearborder(IBW);
    figure('Visible', 'off'); imshow(IBW,[]); 
    saveas(gcf,[outputPath name '_3Post2.jpg']); close;
    
    %-Select region with largest area
    stat=regionprops(IBW,'Area','PixelIdxList');
    [~,indMax] = max([stat.Area]);
    IBW2 = false(size(IBW));
    if(~isempty(indMax))
        IBW2(stat(indMax).PixelIdxList) = 1;
    end
    figure('Visible', 'off'); imshow(IBW2,[]); 
    saveas(gcf,[outputPath name '_3Post3.jpg']); close;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%% Results %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %-Compute quantative and qualitative results
    outPost{i} = double(IBW2);
    gtFile{i}= double(imread([gtPath name ext]));
    if max(max(gtFile{i}))==255
        gtFile{i} = gtFile{i}./255;
    end
    P = sum(sum(gtFile{i}));
    N = sum(sum(~gtFile{i}));
    conf_TP(i) = sum(sum(  gtFile{i}  &   outPost{i}));
    conf_FP(i) = sum(sum((~gtFile{i}) &   outPost{i}));
    conf_TN(i) = sum(sum((~gtFile{i}) & (~outPost{i})));
    conf_FN(i) = sum(sum(  gtFile{i}  & (~outPost{i})));
    statTPR(i) = conf_TP(i)/P;
    statFPR(i) = conf_FP(i)/N;
    statSPC(i) = 1 - statFPR(i);
    statDSC(i) = 2*conf_TP(i)/(2*conf_TP(i)+conf_FP(i)+conf_FN(i));
    statJAC(i) = conf_TP(i)/(conf_TP(i)+conf_FP(i)+conf_FN(i));
    statPRC(i) = conf_TP(i)/(conf_TP(i)+conf_FP(i));
    if(isnan(statPRC(i)))
        statPRC(i) = 0;
    end
    OutComp = PlotAnnotations_General(gtFile{i},outPost{i});
    figure('Visible', 'off'); imshow(OutComp,[]); 
    saveas(gcf,[outputPath name '_4Out.jpg']); close;
end

avgTPR = mean(statTPR);
avgFPR = mean(statFPR);
avgSPC = mean(statSPC);
avgDSC = mean(statDSC);
avgJAC = mean(statJAC);
avgPRC = mean(statPRC);
avgConf_TP = mean(conf_TP./imgSize);
avgConf_FP = mean(conf_FP./imgSize);
avgConf_TN = mean(conf_TN./imgSize);
avgConf_FN = mean(conf_FN./imgSize);

stdTPR = std(statTPR);
stdFPR = std(statFPR);
stdSPC = std(statSPC);
stdDSC = std(statDSC);
stdJAC = std(statJAC);
stdPRC = std(statPRC);
stdConf_TP = std(conf_TP./imgSize);
stdConf_FP = std(conf_FP./imgSize);
stdConf_TN = std(conf_TN./imgSize);
stdConf_FN = std(conf_FN./imgSize);

%%
save(matPath);