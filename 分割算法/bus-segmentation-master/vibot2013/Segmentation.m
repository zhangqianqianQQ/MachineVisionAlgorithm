function [all_images]=Segmentation(FileName)
[~,name,~] = fileparts(FileName);
I = double(imread(['./Results/Step1_PreProcess/' name '_Pre.jpg']));
[Inr,Inc] = size(I);
I = imresize(I,[160,160],'bicubic');
%- compute the edges imageEdges, the similarity matrix W based on Intervening Contours, the Ncut eigenvectors and discrete segmentation
nbSegments = 10;
tic;
[SegLabel,~,NcutEigenvectors,~,~,~]= NcutImage(I,nbSegments);
%- display the segmentation
bw = edge(SegLabel,0.01);
showmask(I,imdilate(bw,ones(2,2)));
%- display Ncut eigenvectors
[nr,nc,~] = size(I); 
%- display Ncut eigenvectors 
all_images=[];
for i=1:nbSegments
    IMG=reshape(NcutEigenvectors(:,i),nr,nc);
    IMG = imresize(IMG,[Inr,Inc],'bicubic');
    imwrite(IMG,['./Results/Step2_Segmentation/' name '_Seg' num2str(i) '.jpg'],'jpg');
    all_images=[all_images {IMG}];
end

