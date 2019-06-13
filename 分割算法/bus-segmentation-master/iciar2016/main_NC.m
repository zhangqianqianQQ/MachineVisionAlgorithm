clc;close all;clear all; warning('off','all');
addpath(genpath('./Libs'));
run('C:\MATLAB_libs\vlfeat\vlfeat-0.9.20\toolbox\vl_setup');
%%
% NC-FR , NC-PPB_NoItr , NC-DPAD
method = 'NC-DPAD-UDIAT';
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
    disp(['File #' num2str(i) ' / ' num2str(numel(fileList)) ' Processing ... ' name]);
    
    img = im2double(imread(file));
    [nr,nc,~] = size(img);
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
    stepsize = 0.01;
    nosteps = 200; % 10
    wnSize = 17; % 5
    img = dpad(img, stepsize, nosteps,'cnoise',5,'big',wnSize,'aja');
    
%     %-PPB_NoItr
%     L = 1;
%     hW = 23;
%     hD = 7;
%     alpha = 0.92;
%     T = 0.2;
%     nbit = 4;
%     img = ppb_nakagami(img, L, hW, hD, alpha, T, nbit);

%     %-Frost filter
%     M_Radius = 5; % 5 , 17
%     img = fcnFrostFilter(img,getnhood(strel('disk',M_Radius)));
    
    figure('Visible', 'off'); imshow(img,[]); 
    saveas(gcf,[outputPath name '_1Pre3.jpg']); close;
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%% Segmentation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    img = img(5:end-4,5:end-4);
    img = imresize(img,[nr,nc]);
    img = normalise(img);
%     img = im2bw(img,graythresh(img));
    img = double(img >= 0.8);
    img = imclearborder(img);
    img= imfill(img,'holes');
    figure('Visible', 'off'); imshow(img,[]); 
    saveas(gcf,[outputPath name '_2Seg1' '.jpg']); close;
    
    nbSegments = 4;
    [~,~,NcutEigenvectors,~,~,~] = NcutImage(img,nbSegments); 
    NC_Imgs = [];
    for j=1:nbSegments
        NC_Img = reshape(NcutEigenvectors(:,j),nr,nc);
        figure('Visible', 'off'); imshow(NC_Img,[]); 
        saveas(gcf,[outputPath name '_2Seg2_' num2str(j) '.jpg']); close;
        NC_Imgs = [NC_Imgs {NC_Img}];
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%% Postprocessing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ind = 1;
    for j=1:nbSegments
        [~, assignments] = vl_kmeans(NC_Imgs{j}(:)',2,'Initialization', 'plusplus','algorithm', 'elkan');
        for z=1:max(assignments)
            IBW = reshape(assignments == z,nr,nc);
        
            %-Convert segemented (gray-scale) image into binary image by one-point
            %-thresholding using some scalar value after unit normalization
            figure('Visible', 'off'); imshow(IBW,[]); 
            saveas(gcf,[outputPath name '_3Post1_' num2str(j) '_' num2str(z) '.jpg']); close;

            %-Remove boundary regions
            IBW = imclearborder(IBW);
            figure('Visible', 'off'); imshow(IBW,[]); 
            saveas(gcf,[outputPath name '_3Post2_' num2str(j) '_' num2str(z) '.jpg']); close;

            %-Select region with largest area
            if(max(IBW(:)) == 0)
                ValMax(ind) = -1;
                IBW2 = false(size(IBW));
            else
                stat = regionprops(IBW,'Area','PixelIdxList');
                [ValMax(ind),indMax] = max([stat.Area]);
                IBW2 = false(size(IBW));
                if(~isempty(indMax))
                    IBW2(stat(indMax).PixelIdxList) = 1;
                end
            end
            figure('Visible', 'off'); imshow(IBW2,[]); 
            saveas(gcf,[outputPath name '_3Post3_' num2str(j) '_' num2str(z) '.jpg']); close;
            NC_BW{ind} = IBW2;
            ind = ind +1;
        end
    end
    [~,indNCMax] = max(ValMax);
    IBW2 = NC_BW{indNCMax};
    
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