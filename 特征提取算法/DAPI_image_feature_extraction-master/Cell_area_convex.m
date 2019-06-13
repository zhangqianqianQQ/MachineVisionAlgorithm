function [major, minor, area, segout, u, I0, seg, boundary]=Cell_area_convex(fname, K, convex, t1, t2)
cmin=0;
cmax=255;
epsilon=0.01;
%% Read in the image and standardize into [0, 255] interval
addpath InsidePolyFolder
info = imfinfo(fname);
num_images = numel(info);
for k = 1:num_images
    A(:,:,k) = imread(fname, k);
end
target=A(:,:,K);

interval=linspace(double(quantile(target(:),0)), double(quantile(target(:),1-epsilon)), 256);
[bincounts,ind]= histc(double(target), interval);
ind=ind+255*(double(target)>quantile(target(:),1-epsilon));
I=uint8(ind-1);
I0=I;
% % May Enhance contrast using histogram equalization;
% I=histeq(I0,100);
u=1./info(1,1).XResolution; % length of a single pixel
figure;
imshow(I0), title('original image');
% text(size(I0,2),size(I0,1)+15, ...
%     'Image of egg chamber', ...
%     'FontSize',7,'HorizontalAlignment','right');
% text(size(I0,2),size(I0,1)+45, ....
%     'Florida State University, Jia', ...
%     'FontSize',7,'HorizontalAlignment','right');
caxis([cmin, cmax])



% apply the first threshold
if(~exist('t1','var'))
    level1=graythresh(I);
    original=im2bw(I, 0.2*level1);
else
    original = (I>t1);
end



% apply the average filter to get rid of large area of noise
wsize1=floor(size(I,1)./20);
wsize2=floor(size(I,2)./20);
h = fspecial('average', [wsize1,wsize2]);
original1=filter2(h, original);

% apply the second threshold, expect find the large component and several far away component
if(~exist('t2','var'))
    level2=graythresh(original1);
    original2=im2bw(original1, 1*level2);
else
    original2 = (original1>t2);
end


se = strel('disk',max(2, floor(size(I,1)./400)));
afterOpening = imopen(original2,se);

figure;
subplot(2,2,1)
imshow(original)
title('Apply first filter')

%figure;
subplot(2,2,2)
imshow(original1)
title('Apply average filter')

%figure;
subplot(2,2,3)
imshow(original2)
title('Apply second filter')

%figure
subplot(2,2,4)
imshow(afterOpening)
title('Break out components')


%% find the largest components
stats = regionprops(afterOpening, 'Area','ConvexHull','FilledArea','MajorAxisLength',...
    'MinorAxisLength', 'Orientation', 'Eccentricity','PixelIdxList');
AA=struct2cell(stats);
area=zeros(1,size(AA,2));
for i=1:numel(area)
    area(i)=AA{1,i};
end
[trash, index]=max(area);
index_large=AA{8, index};

if(~exist('convex','var'))
    convex=0;
end

if convex==1
    convex_index=AA{6,index};
    [inner(:,2),inner(:,1)]=find(I0>=0);
    xv = [convex_index(:,1);convex_index(1,1)]; yv = [convex_index(:,2);convex_index(2,2)];
    IN = insidepoly(inner(:,1),inner(:,2), xv,yv);
    I(IN)=50;
    I(~IN)=0;
    outline = bwperim(I);
    segout = I;
    segout(outline) = 255;
    I0(segout==0)=0;
    I11=I0;
    I11(outline)=255;
%     figure(100);
%     imshow(I11)
    [coeff,score,latent] = princomp(inner(IN,:));
    area=numel(find(IN==1))*(u)^2;
    minor=sqrt(4*area./pi./sqrt(latent(1)./latent(2)));
    major=sqrt(4*area./pi./sqrt(latent(2)./latent(1)));
    
    %fprintf('This cell has CONVEX size  %4.1f by  %4.1f with area %4.1f\n',major,minor,area)
    
    
else
    
    I(index_large)=50;
    I(setdiff(1:numel(I),index_large))=0;
    final=imfill(I,'holes');
    outline = bwperim(final);
    segout = final;
    segout(outline) = 255;
    I0(segout==0)=0;
    %figure, imshow(I0), hold on; h=imshow(segout); set(h, 'AlphaData', 0.5); title('outlined original image');
    I11=I0;
    I11(outline)=255;
%     figure;
%     imshow(I11)
    major=AA{2,index}*u;
    minor=AA{3,index}*u;
    area=AA{7,index}*(u)^2;
    %fprintf('This cell has size  %4.1f by  %4.1f with area %4.1f\n',major,minor,area)
end


%% second round 
addpath('chanvese')
% chenvese segmentation on the cleaned image
t3=3e-10;
%seg = chenvese(imadjust(histeq(I0,256)),'whole+small',400,t3,'chan');
seg = chenvese(imadjust(I0),'whole+small',1000,t3,'chan');
if numel(find(seg==1))>numel(find(seg==0))
    seg=~seg;
end
figure;
imshow(seg)
title('segmentation mask')

seg = bwareaopen(seg, floor(0.0001*area./(u^2)));

figure;
imshow(seg)
title('segmentation mask minus small parts')
clear inner

[inner1(:,2),inner1(:,1)]=find(seg>=0);
[inner(:,2),inner(:,1)]=find(seg>0);
KK = convhull(inner(:,1),inner(:,2));
figure
imshow(seg)
hold on
plot(inner(KK,1),inner(KK,2),'r-','linewidth',3)
title('segmentation mask with boundary (red)')
boundary=inner(KK,:);
xv = [inner(KK,1) ; inner(KK(1),1)]; yv = [inner(KK,2) ; inner(KK(1),2)];
IN = insidepoly(inner1(:,1),inner1(:,2), xv,yv);

I1=I0;
I1(IN)=50;
I1(~IN)=0;
outline = bwperim(I1);
segout = I1;
segout(outline) = 255;
I0(segout==0)=0;
I11=I0;
I11(outline)=255;
figure (200);
imshow(I11)
title('segmentation in original intensity')

[coeff,score,latent] = princomp(inner1(IN,:));
area=numel(find(IN==1))*(u)^2;
minor=sqrt(4*area./pi./sqrt(latent(1)./latent(2)));
major=sqrt(4*area./pi./sqrt(latent(2)./latent(1)));

fprintf('This cell has CHAN CONVEX size  %4.1f by  %4.1f with area %4.1f um^2\n',major,minor,area)

fprintf('This cell has ratio  %4.2f \n', major./minor)
