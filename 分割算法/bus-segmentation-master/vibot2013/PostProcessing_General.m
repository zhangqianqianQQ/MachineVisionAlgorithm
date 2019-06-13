% - This function is used to segment the output of the normalized cut
% - and measuring the accuracy of the segmentation
% - The function has three input arguments:-
% - all_images(the normalized cut eigenvectors output).
% - measurements.
% This function is working as following:-
% - 1- Applying image normalization to convert all intensity values from ;
%- (0-255)
% - 2- Applying Kmeans clustering 
% - 3- Checking if the image is easy to segment just subtract the maximum
% - value by the minimum value, if the result is less than zero apply Otsu
% - threshold and get the image, if the result is greater than zero traces
% - the exterior boundaries of objects, in case the length of the contour
% - is less than one the image is already segmented, else extract the
% - minimum contour and plot it and this is the segmented lesion
function [OutImage]=PostProcessing_General(all_images,FileName)
%--------------------------------------------------------------------------
% - Intialize the Area variable
AREA=[];
%--------------------------------------------------------------------------
for N=1:length(all_images)
    %----------------------------------------------------------------------
    % - This is to read the Image from the normalized cut.
    IN_IMG=double(cell2mat(all_images(N)));
    %----------------------------------------------------------------------
    % - Image Normalization
    min1=min(min(IN_IMG));
    max1=max(max(IN_IMG));
    IN_IMG=((IN_IMG-min1).*255)./(max1-min1);
    %---------------------------------------------------------------------- 
    % - Uncomment to display the normalized cut output.
    % figure;imshow(OutPut);impixelinfo;
    % set(title('Normalized Cut Gray Image'),'color','b');
    %----------------------------------------------------------------------
    
    %----------------------------------------------------------------------
    % - Uncomment to show the Kmeans output.
    % figure;imshow(label2rgb(IMG_ALG));title('k means');impixelinfo;
    %----------------------------------------------------------------------
    % - This is to check the kmeans output result.
    if(max(IN_IMG(:))-min(IN_IMG(:))>0)
        % - Applying Kmeans 
        nRows=size(IN_IMG,1);
        nCols=size(IN_IMG,2);
%         Thre=graythresh(IN_IMG);
%         IN_IMG=im2bw(IN_IMG,Thre);
        IMG = IN_IMG(:);
%         idx = kmeans(IMG,2,'distance','hamming','replicates',10)-1;
        idx = kmeans(IMG,2,'replicates',3)-1;
%         idx = kmedoids(IMG,2)-1;
        IMG_ALG = reshape(idx,nRows,nCols);
        
        B = bwboundaries(IMG_ALG);
        L=[];
        for ii=1:length(B);
            L(ii)=length(cell2mat(B(ii)));
        end
        if(length(B)>1)
            Mean=mean(L);
            T=100; %35
            L(L<T)=inf;
            L1=abs(L-Mean);
            [~,Temp]=min(L1);
            coor=cell2mat(B(Temp));
            New_IMG(:,:,N)=double(roipoly(IMG_ALG,coor(:,2),coor(:,1)));
        else
            New_IMG(:,:,N)=IMG_ALG;
        end
        %------------------------------------------------------------------
        % - Uncomment to display the segmented image
        % figure;
        % imshow(New_IMG);impixelinfo;
        % set(title('Algorithm Image - K-means'),'color','b');
        %------------------------------------------------------------------
    else
        Thre=graythresh(IN_IMG);
        New_IMG(:,:,N)=im2bw(IN_IMG,Thre);
        
        %------------------------------------------------------------------
        % - Uncomment to display the segmented image
        % figure;imshow(New_IMG);
        % set(title('Algorithm Image - otsu'),'color','b');
        %------------------------------------------------------------------
    end
    
    
    New_IMG2 = New_IMG(:,:,N);
    win = 15;
    New_IMG2(1:win,:) = 1; New_IMG2(end-win:end,:) = 1;
    New_IMG2(:,1:win) = 1; New_IMG2(:,end-win:end) = 1;
    New_IMG2 = imclearborder(New_IMG2);
%     SE = strel('disk',3);
%     New_IMG2 = imclose(imopen(New_IMG2,SE),SE);
    New_IMG(:,:,N) = New_IMG2;
%     New_IMG(:,:,N) = imresize(New_IMG2,[Inr,Inc]);
    
    
    [~,name,~] = fileparts(FileName);
    imwrite(New_IMG(:,:,N),['./Results/Step3_Clustering/' name '_Clus' num2str(N) '_Post.jpg'],'jpg');
    
    %----------------------------------------------------------------------
    % - Compute the Area of the segmented lesion
    STATS=regionprops(New_IMG(:,:,N),'Area');
    if(isempty(struct2cell(STATS)))
        AREA(N) = 0;
    else
        A1=cell2mat(struct2cell(STATS));
        AREA(N) = A1(1);
    end
    %----------------------------------------------------------------------
end
AREA
%--------------------------------------------------------------------------
% - Minimum Area Selection
T1=500; %35
% AREA(AREA<(median(AREA)*0.3))=inf;
AREA(AREA<T1)=0;
[~,Ind1]=max(AREA);
%--------------------------------------------------------------------------
% - This is to save the image after the SegmentationStep
%--------------------------------------------------------------------------
OutImage = New_IMG(:,:,Ind1);
[~,name,~] = fileparts(FileName);
imwrite(OutImage,['./Results/Step3_Final/' name '_Post.jpg'],'jpg');