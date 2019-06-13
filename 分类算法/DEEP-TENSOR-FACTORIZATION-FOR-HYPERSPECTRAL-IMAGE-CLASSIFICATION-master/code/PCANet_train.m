function [f,V] = PCANet_train(InImg,PCANet,IdtExt)

if length(PCANet.NumFilters)~= PCANet.NumStages;
    display('Length(PCANet.NumFilters)~=PCANet.NumStages')
    return
end

NumImg = length(InImg);

V = cell(PCANet.NumStages,1); 
OutImg = InImg; 
ImgIdx = (1:NumImg)';
clear InImg; 

for stage = 1:PCANet.NumStages
    display(['Computing PCA filter bank and its outputs at stage ' num2str(stage) '...'])
    
    V{stage} = PCA_FilterBank(OutImg, PCANet.PatchSize(stage), PCANet.NumFilters(stage)); % compute PCA filter banks
    
    if stage ~= PCANet.NumStages % compute the PCA outputs only when it is NOT the last stage
        [OutImg,ImgIdx] = PCA_output(OutImg, ImgIdx, ...
            PCANet.PatchSize(stage), PCANet.NumFilters(stage), V{stage});  
    end
end

if IdtExt == 1 % enable feature extraction
    %display('PCANet training feature extraction...') 
    
    f = cell(NumImg,1); % compute the PCANet training feature one by one 
    
    for idx = 1:NumImg
        if 0==mod(idx,100); display(['Extracting PCANet feasture of the ' num2str(idx) 'th training sample...']); end
        OutImgIndex = ImgIdx==idx; % select feature maps corresponding to image "idx" (outputs of the-last-but-one PCA filter bank) 
        
        [OutImg_i,ImgIdx_i] = PCA_output(OutImg(OutImgIndex), ones(sum(OutImgIndex),1),...
            PCANet.PatchSize(end), PCANet.NumFilters(end), V{end});  % compute the last PCA outputs of image "idx"
        
        f{idx} = HashingHist(PCANet,ImgIdx_i,OutImg_i);
        OutImg(OutImgIndex) = cell(sum(OutImgIndex),1); 
       
    end
    
else  % disable feature extraction
    f = [];
end







