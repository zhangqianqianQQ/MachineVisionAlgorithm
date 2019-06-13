function [OutImg,OutImgIdx] = PCA_output(InImg, InImgIdx, PatchSize, NumFilters, V)

ImgZ = length(InImg);
mag = (PatchSize-1)/2;
OutImg = cell(NumFilters*ImgZ,1); 
cnt = 0;
for i = 1:ImgZ
    [ImgX, ImgY, NumChls] = size(InImg{i});
    img = zeros(ImgX+PatchSize-1,ImgY+PatchSize-1, NumChls);
    img((mag+1):end-mag,(mag+1):end-mag,:) = InImg{i};     
    im = im2col_mean_removal(img,[PatchSize PatchSize]); % collect all the patches of the ith image in a matrix, and perform patch mean removal
    for j = 1:NumFilters
        cnt = cnt + 1;
        OutImg{cnt} = reshape(V(:,j)'*im,ImgX,ImgY);  % convolution output
    end
    InImg{i} = [];
end
OutImgIdx = kron(InImgIdx,ones(NumFilters,1)); 










